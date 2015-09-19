//
//  FromLanguageCell.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextField.h"

@interface FromLanguageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *inputText;

@property (weak, nonatomic) IBOutlet UILabel *fromLang;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *fromLangValue;

@property (weak, nonatomic) IBOutlet UILabel *toLang;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *toLangValue;

@property (weak, nonatomic) IBOutlet UIButton *translate;

- (IBAction)translateAction:(id)sender;
@end
