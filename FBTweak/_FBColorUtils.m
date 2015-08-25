/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorUtils.h"

CGFloat const _FBRGBColorComponentMaxValue = 255.0f;
CGFloat const _FBAlphaComponentMaxValue = 100.0f;
CGFloat const _FBHSBColorComponentMaxValue = 1.0f;
NSUInteger const _FBRGBAColorComponentsSize = 4;
NSUInteger const _FBHSBAColorComponentsSize = 4;

extern HSB _FBRGB2HSB(RGB rgb)
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

  return (HSB){.hue = h, .saturation = s, .brightness = b, .alpha = rgb.alpha};
}

extern RGB _FBHSB2RGB(HSB hsb)
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

  return (RGB){.red = r, .green = g, .blue = b, .alpha = hsb.alpha};
}

extern RGB _FBRGBColorComponents(UIColor *color)
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
