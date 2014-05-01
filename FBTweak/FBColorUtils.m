/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBColorUtils.h"

CGFloat const FBRGBColorComponentMaxValue = 255.0f;
CGFloat const FBAlphaComponentMaxValue = 100.0f;
CGFloat const FBHSBColorComponentMaxValue = 1.0f;

extern void FBRGB2HSB(RGB rgb, HSB* outHSB)
{
  double rd = (double) rgb.red;
  double gd = (double) rgb.green;
  double bd = (double) rgb.blue;
  double max = fmax(rd, fmax(gd, bd));
  double min = fmin(rd, fmin(gd, bd));
  double h = 0, s, b = max;

  double d = max - min;
  s = max == 0 ? 0 : d / max;

  if (max == min) {
    h = 0; // achromatic
  } else {
    if (max == rd) {
      h = (gd - bd) / d + (gd < bd ? 6 : 0);
    } else if (max == gd) {
      h = (bd - rd) / d + 2;
    } else if (max == bd) {
      h = (rd - gd) / d + 4;
    }
    h /= 6;
  }

  outHSB->hue = h;
  outHSB->saturation = s;
  outHSB->brightness = b;
  outHSB->alpha = rgb.alpha;
}

extern void FBHSB2RGB(HSB hsb, RGB* outRGB)
{
  double r, g, b;

  int i = hsb.hue * 6;
  double f = hsb.hue * 6 - i;
  double p = hsb.brightness * (1 - hsb.saturation);
  double q = hsb.brightness * (1 - f * hsb.saturation);
  double t = hsb.brightness * (1 - (1 - f) * hsb.saturation);

  switch(i % 6){
    case 0: r = hsb.brightness, g = t, b = p; break;
    case 1: r = q, g = hsb.brightness, b = p; break;
    case 2: r = p, g = hsb.brightness, b = t; break;
    case 3: r = p, g = q, b = hsb.brightness; break;
    case 4: r = t, g = p, b = hsb.brightness; break;
    case 5: r = hsb.brightness, g = p, b = q; break;
  }

  outRGB->red = r;
  outRGB->green = g;
  outRGB->blue = b;
  outRGB->alpha = hsb.alpha;
}

extern RGB FBRGBColorComponents(UIColor* color)
{
  RGB result;
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return result;
  }
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
    result.red = result.green = result.blue = components[0];
    result.alpha = components[1];
  } else {
    result.red = components[0];
    result.green = components[1];
    result.blue = components[2];
    result.alpha = components[3];
  }
  return result;
}

extern NSString* FBHexStringFromColor(UIColor* color)
{
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return nil;
  }
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  CGFloat red, green, blue, alpha;
  if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
    red = green = blue = components[0];
    alpha = components[1];
  } else {
    red = components[0];
    green = components[1];
    blue = components[2];
    alpha = components[3];
  }
  NSString *hexColorString = [NSString stringWithFormat:@"#%02X%02X%02X%02X",
                              (NSUInteger)(red * FBRGBColorComponentMaxValue),
                              (NSUInteger)(green * FBRGBColorComponentMaxValue),
                              (NSUInteger)(blue * FBRGBColorComponentMaxValue),
                              (NSUInteger)(alpha * FBRGBColorComponentMaxValue)];
  return hexColorString;
}

extern UIColor* FBColorFromHexString(NSString* hexColor)
{
  if (![hexColor hasPrefix:@"#"]) {
    return nil;
  }

  NSScanner *scanner = [NSScanner scannerWithString:hexColor];
  [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];

  unsigned hexNum;
  if (![scanner scanHexInt: &hexNum]) return nil;

  int r = (hexNum >> 24) & 0xFF;
  int g = (hexNum >> 16) & 0xFF;
  int b = (hexNum >> 8) & 0xFF;
  int a = (hexNum) & 0xFF;

  return [UIColor colorWithRed:r / FBRGBColorComponentMaxValue
                         green:g / FBRGBColorComponentMaxValue
                          blue:b / FBRGBColorComponentMaxValue
                         alpha:a / FBRGBColorComponentMaxValue];
}
