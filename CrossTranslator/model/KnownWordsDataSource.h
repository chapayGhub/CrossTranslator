//
//  KnownWordsDataSource.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLPAutoCompleteTextFieldDataSource.h"

@interface KnownWordsDataSource : NSObject <MLPAutoCompleteTextFieldDataSource>

/**
 *  dependency injection of ManagedObjectContext
 *
 *  @return
 */

- (void) setMOC:(NSManagedObjectContext*)moc;

- (id) initWithStartLanguage:(NSString*) startLanguage destinationLanguage:(NSString*) destLanguage;


@end
