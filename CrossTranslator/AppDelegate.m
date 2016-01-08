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
//  AppDelegate.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "MasterViewController.h"

#import "LangName.h"
#import "LangCodeModel.h"
#import "CHCSVParser.h"
#import "Constants.h"
#import "GUILanguageManager.h"

@interface AppDelegate () <CHCSVParserDelegate>

@property (strong, nonatomic) NSMutableArray *lines;
@property (strong, nonatomic) NSMutableArray *currentLine;
@property (strong, nonatomic) NSMutableArray * langs;


/**
 *  this managed object context is used essentially for testing.
 *  so we pass it during test
 */
@property (strong, nonatomic) NSManagedObjectContext *saveObjectMOC;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSArray* objs = [[NSArray alloc] initWithObjects:
                     [NSNumber numberWithInt:0],
                     nil];
    NSArray* keys = [[NSArray alloc] initWithObjects:
                     kCurrentLang,
                     nil];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:objs forKeys:keys];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    
    
    //Load language codes in Core Data the first time app runs
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [self loadLangCodesInMOC:self.managedObjectContext];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    //load ui strings
    [self loadUIStrings];
    
    [NSThread sleepForTimeInterval:0.5];
    
    
    MasterViewController *controller = (MasterViewController *)[(UINavigationController*)self.window.rootViewController topViewController];
    controller.managedObjectContext = self.managedObjectContext;
    return YES;
}
/**
 *  Loads the localized String that populate the UI elements
 */
- (void) loadUIStrings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *column = [prefs objectForKey:kCurrentLang];
    [GUILanguageManager sharedInstance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LangCodeModel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@", column];
    
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] == 1) {
        LangCodeModel *model = [results objectAtIndex:0];
        [GUILanguageManager setNewLanguage:model.code];
        
    }
}
/*!
 *  This method load the available languages in Core Data.
 */
- (void) loadLangCodesInMOC:(NSManagedObjectContext*)moc;{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codes" ofType:@"csv"];
    NSURL *url = [NSURL fileURLWithPath:path];
    CHCSVParser *parser = [[CHCSVParser alloc] initWithContentsOfDelimitedURL:url delimiter:';'];
    parser.delegate = self;
    
    //Set in which moc to save objects
    _saveObjectMOC = moc;
    [parser parse];
}

#pragma mark - Parsing Delegate Methods

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    self.lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    self.currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    NSLog(@"%@", field);
    [self.currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [self.lines addObject:_currentLine];
    
    
    //In the first line we find supported UI Languages:
    if ([self.lines count] == 1) {
        self.langs = [[NSMutableArray alloc] init];
        LangCodeModel *language;
        for (int i = 0; i < [self.currentLine count] - 1; i++) {
            language = [NSEntityDescription insertNewObjectForEntityForName:@"LangCodeModel" inManagedObjectContext:_saveObjectMOC];
            [language setValue:[self.currentLine objectAtIndex:i] forKey:@"code"];
            
            [language setValue:[NSNumber numberWithInt:i] forKey:@"index"];
            [self.langs addObject:language];
        }
        
        
        return;
    }else{
        // The other lines contain the code of the language and
        // the respective Language Name in each UI language
        LangName * langName;
        for (int i = 0; i < [self.currentLine count] - 1; i++) {
            langName = [NSEntityDescription insertNewObjectForEntityForName:@"LangName" inManagedObjectContext:_saveObjectMOC];
            [langName setValue:[self.currentLine objectAtIndex:[self.currentLine count] - 1]
                        forKey:@"code"];
            [langName setValue:[self.currentLine objectAtIndex:i] forKey:@"name"];
            [(LangCodeModel*)[self.langs objectAtIndex:i] addNamesObject:langName];
            
        }
    }    
    self.currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"HANDLE ERROR WHEN SAVING THE OBJECT");
    }
    NSLog(@"parser ended");
}

#pragma mark - Application Delegate Methods

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.crossover.CrossTranslator" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CrossTranslator" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CrossTranslator.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
