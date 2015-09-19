//
//  LangCodeModel+CoreDataProperties.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LangCodeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LangCodeModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *names;
@property (nullable, nonatomic, retain) NSNumber *index;

@end

@interface LangCodeModel (CoreDataGeneratedAccessors)

- (void)addNamesObject:(NSManagedObject *)value;
- (void)removeNamesObject:(NSManagedObject *)value;
- (void)addNames:(NSSet<NSManagedObject *> *)values;
- (void)removeNames:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
