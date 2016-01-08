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

- (void)loadLanguge {
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

- (id) initWithUILanguage:(NSNumber*) uiLanguage{
    if (self = [self init]) {
        self.uiLanguage = uiLanguage;
        
        [self loadLanguge];
        
    }
    return self;
}

- (void) changeLanguage:(NSNumber*) uiLanguage{
    self.uiLanguage = uiLanguage;
    [self loadLanguge];
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


- (NSString*) getLangNameForCode:(NSString*)code inLanguage:(NSString*)inLanguage{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LangCodeModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", inLanguage];
    
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    LangCodeModel *languageModel;
    
    if ([results count] == 1) {
        languageModel = [results objectAtIndex:0];
        
    }else{
        return nil;
    }
    
    
    predicate = [NSPredicate predicateWithFormat:@"code == %@", code];
    results = [[languageModel.names filteredSetUsingPredicate:predicate] allObjects];
    if ([results count] == 1) {
        LangName * name = (LangName*) [results objectAtIndex:0];
        return name.name;
    }else{
        return nil;
    }
}















@end
