/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "UIColor+HEX.h"

@implementation UIColor (HEX)

- (NSString *)hexString
{
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return nil;
  }
  const CGFloat *components = CGColorGetComponents(self.CGColor);
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
                              (NSUInteger)(red * 255), (NSUInteger)(green * 255), (NSUInteger)(blue * 255), (NSUInteger)(alpha * 255)];
  return hexColorString;
}

+ (UIColor*)colorWithHexString:(NSString*)hexColor
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

  return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
}

@end
