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
#import <CommonCrypto/CommonDigest.h>

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
                  
              });
              return;
          }
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
          
          if (httpResponse.statusCode == 200){
              NSError *jsonError = nil;
              NSDictionary *translationJSON =
              [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:&jsonError];
              
              if (!jsonError) {                    
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                  });
              }
              
              
              
          }else{
              dispatch_async(dispatch_get_main_queue(), ^{
                  
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
