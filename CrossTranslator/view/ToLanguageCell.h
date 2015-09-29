//
//  ToLanguageCell.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToLanguageCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *translatePhrase;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorValue;
@property (weak, nonatomic) IBOutlet UIButton *speakLoad;

@end
