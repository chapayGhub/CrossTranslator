//
//  TranslationDelegateProtocol.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TranslationDelegateProtocol <NSObject>

- (void) translationForPhrase:(NSString*)phrase
                           is:(NSString*)translation
                         from:(NSString*)fromLanguage
                           to:(NSString*)toLanguage
                      isLocal:(BOOL)local
                        error:(NSError*)error;

@end
