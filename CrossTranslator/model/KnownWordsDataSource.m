//
//  KnownWordsDataSource.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "KnownWordsDataSource.h"
#import "AppDelegate.h"

@interface KnownWordsDataSource()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *startLanguage;
@property (strong, nonatomic) NSString *destLanguage;

@end
@implementation KnownWordsDataSource


- (id) init
{
    if (self == [super init]) {
        self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
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

/**
 Autocomplete for known words
 */
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LangCodeModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@", self.uiLanguage];
    
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
}

@end
