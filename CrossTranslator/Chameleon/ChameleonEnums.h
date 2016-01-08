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
//  ChameleonEnums.h
//  Chameleon
//
//  Created by Vicc Alexander on 6/8/15.
//  Copyright (c) 2015 Vicc Alexander. All rights reserved.
//

#ifndef Chameleon_ChameleonEnums_h
#define Chameleon_ChameleonEnums_h

/**
 *  Specifies how text-based UI elements and other content such as switch knobs, should be colored.
 *
 *  @since 2.0
 */

typedef NS_ENUM(NSUInteger, UIContentStyle) {
    /**
     *  Automatically chooses and colors text-based elements with the shade that best contrasts its @c backgroundColor.
     *
     *  @since 2.0
     */
    UIContentStyleContrast,
    /**
     *  Colors text-based elements using a light shade.
     *
     *  @since 2.0
     */
    UIContentStyleLight,
    /**
     *  Colors text-based elements using a light shade.
     *
     *  @since 2.0
     */
    UIContentStyleDark
};

#endif
