// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  ChameleonInternal.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ChameleonConstants.h"
#import "ChameleonEnums.h"
#import "ChameleonMacros.h"

#import "NSArray+Chameleon.h"
#import "UIColor+Chameleon.h"
#import "UINavigationController+Chameleon.h"
#import "UIViewController+Chameleon.h"

@interface Chameleon : NSObject

#pragma mark - Global Theming

/**
 *  Set a global theme using a primary color.
 *
 *  @param primaryColor The primary color to theme all controllers with.
 *  @param contentStyle The contentStyle.
 *
 *  @note By default the secondary color will be a darker shade of the specified primary color.
 *
 *  @since 2.0
 */
+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
                 withContentStyle:(UIContentStyle)contentStyle;

/**
 *  Set a global theme using a primary color.
 *
 *  @param primaryColor   The primary color to theme all controllers with.
 *  @param secondaryColor The secondary color to theme all controllers with.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                  andContentStyle:(UIContentStyle)contentStyle;

/**
 *  Set a global theme using a primary color.
 *
 *  @param primaryColor   The primary color to theme all controllers with.
 *  @param secondaryColor The secondary color to theme all controllers with.
 *  @param fontName       The default font for all text-based UI elements.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
+ (void)setGlobalThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                    usingFontName:(NSString *)fontName
                  andContentStyle:(UIContentStyle)contentStyle;

@end
