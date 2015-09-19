//
//  CachedResult+CoreDataProperties.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CachedResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface CachedResult (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fromLanguage;
@property (nullable, nonatomic, retain) NSString *toLanguage;
@property (nullable, nonatomic, retain) NSString *fromText;
@property (nullable, nonatomic, retain) NSData *toText;

@end

NS_ASSUME_NONNULL_END
