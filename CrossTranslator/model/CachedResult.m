//
//  CachedResult.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "CachedResult.h"

@implementation CachedResult

// Insert code here to add functionality to your managed object subclass
- (NSString *)autocompleteString{
    return self.fromText;
}

@end
