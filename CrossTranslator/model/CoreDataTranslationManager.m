//
//  CoreDataTranslationManager.m
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import "CoreDataTranslationManager.h"
#import "AppDelegate.h"

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
    
#warning TODO error code
    NSError *error = [NSError errorWithDomain:@"LocalError" code:0 userInfo:nil];
    [self.delegate translation:nil isLocal:YES error:error];
}



@end
