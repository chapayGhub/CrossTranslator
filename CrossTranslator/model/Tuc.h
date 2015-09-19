//
//  Tuc.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "JSONModel.h"

#import "Phrase.h"
#import "Meaning.h"

@protocol Tuc
@end

@interface Tuc : JSONModel

@property (strong, nonatomic) Phrase<Optional> *phrase;
@property (strong, nonatomic) NSArray<Meaning, Optional> *meanings;

@end
