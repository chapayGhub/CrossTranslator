//
//  CachedResult.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLPAutoCompletionObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CachedResult : NSManagedObject <MLPAutoCompletionObject>

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "CachedResult+CoreDataProperties.h"
