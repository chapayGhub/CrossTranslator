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
#import "LangName.h"


@interface LanguageNamesDataSource()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSNumber *uiLanguage;
@property (strong, nonatomic) LangCodeModel *languageCodeNames;
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
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LangCodeModel" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@", self.uiLanguage];
        
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([results count] == 1) {
            self.languageCodeNames = [results objectAtIndex:0];
            
        }
        
    }
    return self;
}

/**
 Autocomplete for known languages
 */
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler{
    if (self.languageCodeNames != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", string];
        handler([[self.languageCodeNames.names filteredSetUsingPredicate:predicate] allObjects]);
    }else{
        handler(@[]);
    }
    
}


- (NSString*) getLangNameForCode:(NSString*)code{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    NSArray* results = [[self.languageCodeNames.names filteredSetUsingPredicate:predicate] allObjects];
    if ([results count] == 1) {
        LangName * name = (LangName*) [results objectAtIndex:0];
        return name.name;
    }else{
        return nil;
    }
}
















@end
