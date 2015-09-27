//
//  Phrase.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "Phrase.h"
#import "NSString+HTML.h"

@implementation Phrase


- (NSString*) getText{
    return [_text stringByConvertingHTMLToPlainText];
}
@end
