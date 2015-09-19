//
//  NSDictionary+QueryString.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "NSDictionary+QueryString.h"

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


@implementation NSDictionary (QueryString)

-(NSString*) queryString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSLog(@"Key is %@ and value is %@", key, value);
        NSString *part;
        if ([value isKindOfClass:[NSArray class]]){
            NSLog(@"Key %@ is array", key);
            for (id innerValue in value) {
                part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(innerValue)];
                [parts addObject:part];
            }
        }else{
            part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
            [parts addObject: part];
        }
    }
    return [parts componentsJoinedByString: @"&"];
}

@end
