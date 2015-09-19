//
//  CoreDataTranslationManager.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "CoreDataTranslationManager.h"

@implementation CoreDataTranslationManager


- (void) translatePhrase:(NSString*)phrase from:(NSString*)fromLang to:(NSString*)toLang{
    NSError *error = [NSError errorWithDomain:@"LocalError" code:112 userInfo:nil];
    [self.delegate translation:nil isLocal:YES error:error];
}
@end
