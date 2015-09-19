//
//  Translator.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TranslationDelegateProtocol.h"

@interface Translator : NSObject

@property (strong, nonatomic) id<TranslationDelegateProtocol> delegate;

- (void) translatePhrase:(NSString*)phrase from:(NSString*)fromLang to:(NSString*)toLang;

@end
