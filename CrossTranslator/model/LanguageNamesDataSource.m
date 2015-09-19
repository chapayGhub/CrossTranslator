//
//  LanguageNamesDataSource.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "LanguageNamesDataSource.h"
#import "LangCodeModel.h"
#import "AppDelegate.h"
#import "MLPAutoCompleteTextField.h"


@interface LanguageNamesDataSource()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSNumber *uiLanguage;
@end
@implementation LanguageNamesDataSource

- (id) init
{
    if (self == [super init]) {
        self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    }
    return self;
}

- (id) initWithUILanguage:(NSNumber*) uiLanguage{
    if (self = [self init]) {
        self.uiLanguage = uiLanguage;
    }
    return self;
}

/**
 Autocomplete for known languages
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
    
    if ([results count] == 1) {
        LangCodeModel *lcm = [results objectAtIndex:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", string];
        
        handler([[lcm.names filteredSetUsingPredicate:predicate] allObjects]);
    }
    
}



















@end
