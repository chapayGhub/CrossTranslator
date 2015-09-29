//
//  DetailViewController.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Translation.h"

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) Tuc *tuc;
@property (strong, nonatomic) NSNumber *uiLangCode;

@end

