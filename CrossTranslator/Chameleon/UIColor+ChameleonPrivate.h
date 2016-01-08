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
//  UIColor+ChameleonPrivate.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/6/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIColor (ChameleonPrivate)

@property (nonatomic, readwrite) NSUInteger count;

#pragma mark - Class Methods

+ (UIColor *)colorFromImage:(UIImage *)image atPoint:(CGPoint)point;

- (UIColor *)colorWithMinimumSaturation:(CGFloat)saturation;

#pragma mark - Instance Methods

- (BOOL)isDistinct:(UIColor *)color;

- (BOOL)getValueForX:(CGFloat *)X
           valueForY:(CGFloat *)Y
           valueForZ:(CGFloat *)Z
               alpha:(CGFloat *)alpha;

- (BOOL)getLightness:(CGFloat *)L
           valueForA:(CGFloat *)A
           valueForB:(CGFloat *)B
               alpha:(CGFloat *)alpha;

@end
