//
//  TranslationDelegateProtocol.h
//  CrossTranslator
//
//  Created by Andi Palo on 19/09/15.
//  Copyright © 2015 Andi Palo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Translation.h"

@protocol TranslationDelegateProtocol <NSObject>

- (void) translation:(Translation*)result
             isLocal:(BOOL)local
               error:(NSError*)error;

@end
