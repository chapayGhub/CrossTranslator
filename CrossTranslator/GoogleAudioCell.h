//
//  GoogleAudioCell.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleAudioCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *play;

- (IBAction)playAudio:(id)sender;

@end
