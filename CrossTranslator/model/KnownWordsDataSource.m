// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  KnownWordsDataSource.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "KnownWordsDataSource.h"

@interface KnownWordsDataSource()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *startLanguage;
@property (strong, nonatomic) NSString *destLanguage;

@end
@implementation KnownWordsDataSource


- (id) init
{
    if (self == [super init]) {
        
    }
    return self;
}
- (id) initWithStartLanguage:(NSString*) startLanguage destinationLanguage:(NSString*) destLanguage{
    if (self = [self init]) {
        self.startLanguage = startLanguage;
        self.destLanguage = destLanguage;
    }
    return self;
}

- (void) setMOC:(NSManagedObjectContext*)moc{
    self.managedObjectContext = moc;
}

/**
 Autocomplete for known words
 */
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedResult" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fromText CONTAINS[cd] %@) AND (fromLanguage == %@) AND (toLanguage == %@)",string,self.startLanguage,self.destLanguage];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromText CONTAINS[cd] %@",string];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([results count] > 0) {
        //remove duplicate results
        NSMutableDictionary *unique = [[NSMutableDictionary alloc] init];
        
        for (id obj in results) {
            [unique setObject:obj forKey:[obj valueForKey:@"fromText"]];
        }
        handler([unique allValues]);
    }else{
        handler(@[]);
    }
    
}

@end
