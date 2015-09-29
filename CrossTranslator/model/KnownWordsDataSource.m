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
