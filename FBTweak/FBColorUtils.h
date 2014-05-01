/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

typedef struct { CGFloat red, green, blue, alpha; } RGB;
typedef struct { CGFloat hue, saturation, brightness, alpha; } HSB;

extern CGFloat const FBRGBColorComponentMaxValue;
extern CGFloat const FBAlphaComponentMaxValue;
extern CGFloat const FBHSBColorComponentMaxValue;

/**
 * Converts an RGB color value to HSV.
 * Assumes r, g, and b are contained in the set [0, 1] and
 * returns h, s, and b in the set [0, 1].
 *
 *  @param rgb   The rgb color values
 *  @param outHSB The hsb color values
 */
extern void FBRGB2HSB(RGB rgb, HSB* outHSB);

/**
 * Converts an HSB color value to RGB.
 * Assumes h, s, and b are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 *  @param outRGB   The rgb color values
 *  @param hsb The hsb color values
 */
extern void FBHSB2RGB(HSB hsb, RGB* outRGB);

/**
 *  Returns the rgb values of the color components.
 *
 *  @param color The color value.
 *
 *  @return The values of the color components (including alpha).
 */
extern RGB FBRGBColorComponents(UIColor* color);

/**
 *  Converts hex string to the UIColor representation.
 *
 *  @param color The color value.
 *
 *  @return The hex string color value.
 */
extern NSString* FBHexStringFromColor(UIColor* color);

/**
 *  Converts UIColor value to the hex string.
 *
 *  @param hexString The hex string color value.
 *
 *  @return The color value.
 */
extern UIColor* FBColorFromHexString(NSString* hexString);
