//
//  Meaning.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "Meaning.h"
#import "NSString+HTML.h"

@implementation Meaning

- (NSString*) getText{
    return [_text stringByConvertingHTMLToPlainText];
}

@end
