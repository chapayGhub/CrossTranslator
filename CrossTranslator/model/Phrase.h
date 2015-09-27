//
//  Phrase.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "JSONModel.h"
@protocol Phrase
@end

@interface Phrase : JSONModel

/**
 *  Synthesize custom getter to return HTML free chars from text
 */
@property (strong, nonatomic, getter=getText) NSString *text;
@property (strong, nonatomic) NSString *language;

@end
