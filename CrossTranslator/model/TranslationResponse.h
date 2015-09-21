//
//  TranslationResponse.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "JSONModel.h"
#import "Tuc.h"

@interface TranslationResponse : JSONModel

@property (strong, nonatomic) NSArray<Tuc> *tuc;
@property (strong, nonatomic) NSString *result;
@property (strong, nonatomic) NSDictionary<Optional> *authors;

@end
