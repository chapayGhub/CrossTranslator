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
//  UIViewController+Chameleon.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChameleonEnums.h"

@interface UIViewController (Chameleon)

/**
 *  Sets the color theme for the specified view controller.
 *
 *  @param primaryColor   The primary color.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
                 withContentStyle:(UIContentStyle)contentStyle;

/**
 *  Sets the color theme for the specified view controller.
 *
 *  @param primaryColor   The primary color.
 *  @param secondaryColor The secondary color.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                  andContentStyle:(UIContentStyle)contentStyle;

/**
 *  Sets the color theme for the specified view controller.
 *
 *  @param primaryColor   The primary color.
 *  @param secondaryColor The secondary color.
 *  @param fontName       The main font to use for all text-based elements.
 *  @param contentStyle   The contentStyle.
 *
 *  @since 2.0
 */
- (void)setThemeUsingPrimaryColor:(UIColor *)primaryColor
               withSecondaryColor:(UIColor *)secondaryColor
                    usingFontName:(NSString *)fontName
                  andContentStyle:(UIContentStyle)contentStyle;

/**
 *  Sets the status bar style for the specified @c UIViewController and all its child controllers.
 *
 *  @param statusBarStyle The style of the device's status bar.
 *
 *  @note Chameleon introduces a new @c statusBarStyle called @c UIStatusBarStyleContrast.
 *
 *  @since 2.0
 */
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end
