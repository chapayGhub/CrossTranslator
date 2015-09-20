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

#import <AudioToolbox/AudioToolbox.h>


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
    [self gtts];
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



- (void) gtts{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"file.mp3"];
    
    NSString *text = @"Hello World"; //@"You are one chromosome away from being a potato.";
    NSString *urlString = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",text];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url] ;
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" forHTTPHeaderField:@"User-Agent"];
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    [data writeToFile:path atomically:YES];
    
    SystemSoundID soundID;
    NSURL *url2 = [NSURL fileURLWithPath:path];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url2, &soundID);
    AudioServicesPlaySystemSound (soundID);
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
