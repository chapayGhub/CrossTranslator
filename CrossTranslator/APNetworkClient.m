// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  APNetworkClient.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APNetworkClient.h"
#import "NSData+Base64.h"
#import "TranslationResponse.h"

static NSString *TRANSLATE_URL = @"https://glosbe.com/gapi/translate";

@interface  APNetworkClient()

@property (strong, nonatomic) NSURLSession *session;
@end

@implementation APNetworkClient

- (id) init{
    if (self = [super init]){
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.session =[NSURLSession sessionWithConfiguration:sessionConfig
                                                    delegate:self
                                               delegateQueue:nil];

    }
    return self;
}

- (void) translatePhrase:(NSString*)phrase from:(NSString*)fromLang to:(NSString*)toLang{

    NSURLComponents *components = [NSURLComponents componentsWithString:TRANSLATE_URL];
    NSURLQueryItem *item1 = [NSURLQueryItem queryItemWithName:@"from" value:fromLang];
    NSURLQueryItem *item2 = [NSURLQueryItem queryItemWithName:@"dest" value:toLang];
    NSURLQueryItem *item3 = [NSURLQueryItem queryItemWithName:@"format" value:@"json"];
    NSURLQueryItem *item4 = [NSURLQueryItem queryItemWithName:@"phrase" value:phrase];
    
    components.queryItems = @[item1, item2, item3, item4];
    NSURL *url = components.URL;
    NSLog(@"URL is %@", url);
    
    NSURLSessionDataTask *translateTask = [self.session dataTaskWithURL:url
                                                              completionHandler:^(NSData* data,
                                                                                  NSURLResponse* response,
                                                                                  NSError *error){
          if (error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.delegate translation:nil isLocal:NO error:error];
              });
              return;
          }
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
          
          if (httpResponse.statusCode == 200){
              NSError *jsonError = nil;
              TranslationResponse *resp = [[TranslationResponse alloc] initWithData:data error:&jsonError];
              Translation *translation = [[Translation alloc] init];
              translation.result = resp;
              translation.fromLanguage = fromLang;
              translation.toLanguage = toLang;
              translation.phrase = phrase;
              
              if (!jsonError) {                    
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.delegate translation:translation isLocal:NO error:nil];
                      
                  });
              }else{
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.delegate translation:nil isLocal:NO error:jsonError];
                  });
              }
          }else{
              NSError *requestError;
              NSMutableDictionary* details = [NSMutableDictionary dictionary];
              [details setValue:@"Network API call error" forKey:NSLocalizedDescriptionKey];
              requestError = [NSError errorWithDomain:@"NetworkAPI" code:httpResponse.statusCode userInfo:details];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.delegate translation:nil isLocal:NO error:requestError];
              });
          }
                                                                  
    }];
    [translateTask resume];
}





#pragma mark - NSURLSessionDownloadDelegate

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%f / %f", (double)totalBytesWritten,(double)totalBytesExpectedToWrite);
    
//    ALog("Total tasks %lu",(unsigned long)self.totalImageTasks);
//    ALog("Remaining image tasks %lu", (unsigned long)self.remainingImageTasks);
    
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"Dowload");


}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    //Handle only error here, normally 'URLSession:downloadTask:didFinishDownloadingToURL:' fires before
    if (error) {
        NSLog(@"Error");
    }
}


@end
