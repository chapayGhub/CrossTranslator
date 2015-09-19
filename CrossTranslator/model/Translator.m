//
//  Translator.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "Translator.h"

@implementation Translator

- (void) translatePhrase:(NSString*)phrase from:(NSString*)fromLang to:(NSString*)toLang{
    //this must not be called in super class, error for developer
    [self doesNotRecognizeSelector:_cmd];
    return;
}

@end
