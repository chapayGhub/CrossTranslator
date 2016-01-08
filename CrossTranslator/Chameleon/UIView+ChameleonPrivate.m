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
//  UIView+ChameleonPrivate.m
//  Chameleon
//
//  Created by Vicc Alexander on 6/4/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#import "UIView+ChameleonPrivate.h"

@implementation UIView (ChameleonPrivate)

- (BOOL)isTopViewInWindow {
    
    if (!self.window) {
        return NO;
    }
    
    CGPoint centerPointInSelf = CGPointMake(CGRectGetMidX(self.bounds),
                                            CGRectGetMidY(self.bounds));
    
    CGPoint centerPointOfSelfInWindow = [self convertPoint:centerPointInSelf
                                                    toView:self.window];
    
    UIView *view = [self.window findTopMostViewForPoint:centerPointOfSelfInWindow];
    BOOL isTopMost = view == self || [view isDescendantOfView:self];
    
    return isTopMost;
}

- (UIView *)findTopMostViewForPoint:(CGPoint)point {
    
    for (int i = (int)self.subviews.count - 1; i >= 0; i--) {
        
        UIView *subview = [self.subviews objectAtIndex:i];
        
        if (!subview.hidden && CGRectContainsPoint(subview.frame, point) && subview.alpha > 0.01) {
            CGPoint pointConverted = [self convertPoint:point toView:subview];
            return [subview findTopMostViewForPoint:pointConverted];
        }
    }
    
    return self;
}

@end
