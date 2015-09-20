//
//  LangName+CoreDataProperties.h
//  CrossTranslator
//
//  Created by Andi Palo on 20/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LangName.h"
#import "LangCodeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LangName (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) LangCodeModel *belongs;

@end

NS_ASSUME_NONNULL_END
