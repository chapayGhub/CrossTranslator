//
//  CoreDataTranslationManager.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "CoreDataTranslationManager.h"
#import "AppDelegate.h"
#import "TranslationResponse.h"
#import "CachedResult.h"

@interface CoreDataTranslationManager()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation CoreDataTranslationManager

- (id) init
{
    if (self == [super init]) {
        self.managedObjectContext = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
    }
    return self;
}

- (void) translatePhrase:(NSString*)phrase from:(NSString*)fromLang to:(NSString*)toLang{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedResult" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fromText == %@) AND (fromLanguage == %@) AND (toLanguage == %@)",phrase, fromLang, toLang];
    
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([results count] == 1) {
        CachedResult *cr = [results objectAtIndex:0];
        
        NSDictionary *dict = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:cr.toText];
        
        NSError *error;
        TranslationResponse *resp = [[TranslationResponse alloc] initWithDictionary:dict error:&error];
        Translation *translation = [[Translation alloc] init];
        translation.result = resp;
        translation.fromLanguage = fromLang;
        translation.toLanguage = toLang;
        translation.phrase = phrase;
        [self.delegate translation:translation isLocal:YES error:nil];
    }else{
        NSError *error = [NSError errorWithDomain:@"LocalError" code:0 userInfo:nil];
        [self.delegate translation:nil isLocal:YES error:error];
    }
}



@end
