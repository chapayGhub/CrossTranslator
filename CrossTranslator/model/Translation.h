//
//  Translation.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TranslationResponse.h"

@interface Translation : NSObject

@property (strong, nonatomic) NSString *fromLanguage;
@property (strong, nonatomic) NSString *toLanguage;
@property (strong, nonatomic) NSString *phrase;
@property (strong, nonatomic) TranslationResponse *result;

@end
