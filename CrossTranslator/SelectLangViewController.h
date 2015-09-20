//
//  SelectLangViewController.h
//  CrossTranslator
//
//  Created by Andi Palo on 20/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol LanguageChangedDelegate <NSObject>

- (void) languageChangedTo:(NSNumber*)newLanguage;

@end

@interface SelectLangViewController : UITableViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) id<LanguageChangedDelegate> delegate;
@property (strong, nonatomic) NSNumber *currentLanguage;
@end
