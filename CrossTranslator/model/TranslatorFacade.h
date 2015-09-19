//
//  TranslatorFacade.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TranslationDelegateProtocol.h"

@interface TranslatorFacade : NSObject<TranslationDelegateProtocol>


- (void) translatePhrase:(NSString*) phrase
                    from:(NSString*) startLanguage
                      to:(NSString*) endLanguage
            completition:(void (^)(NSError *error, NSString* translation))completition;

@end
