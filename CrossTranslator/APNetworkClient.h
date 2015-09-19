//
//  APNetworkClient.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Translator.h"

@interface APNetworkClient : Translator <NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>


@end
