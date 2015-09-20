//
//  GUILanguageManager.h
//  CrossTranslator
//
//  Created by Andi Palo on 20/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GUILanguageManager : NSObject

+ (instancetype) sharedInstance;

+ (NSString*) getUIStringForCode:(NSString*)code;

+ (void) setNewLanguage:(NSString*)code;

@end
