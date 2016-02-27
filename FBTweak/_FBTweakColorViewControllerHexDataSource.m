/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakColorViewControllerHexDataSource.h"
#import "_FBTweakTableViewCell.h"
#import "FBTweak.h"

@interface _FBTweakColorViewControllerHexDataSource () <FBTweakObserver>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) FBTweak *tweak;

@end

@implementation _FBTweakColorViewControllerHexDataSource {
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  }
  return self;
}

- (void)dealloc
{
  [self.tweak removeObserver:self];
}

- (UIColor *)value
{
  return self.color;
}

- (void)setValue:(UIColor *)value
{
  _color = value;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    _colorSampleCell.backgroundColor = self.value;
    return _colorSampleCell;
  }
  return [self hexCell];
}

/**
 *  By using _FBTweakTableViewCell, it allows us to internally observe changes and configure the tableViewCell without
 *  having to create a new subclass. So while not a tweak in itself, it provides us the desired behaviour.
 */
- (_FBTweakTableViewCell *)hexCell
{
  _FBTweakTableViewCell *hexCell = [[_FBTweakTableViewCell alloc] initWithReuseIdentifier:@"hexCell"];
  self.tweak = [[FBTweak alloc] initWithIdentifier:@"hex"];
  self.tweak.name = @"Hex Value";
  self.tweak.defaultValue = @"FFFFFF";
  self.tweak.currentValue = [self.class colorToHexString:self.color];
  [self.tweak addObserver:self];
  hexCell.tweak = self.tweak;
  return hexCell;
}

- (void)tweakDidChange:(FBTweak *)tweak
{
  UIColor *colorFromHex = [self.class colorFromHexString:tweak.currentValue];
  [self setValue:colorFromHex];
  _colorSampleCell.backgroundColor = colorFromHex;
}

#pragma mark - hex colour converters

+ (NSString *)colorToHexString:(UIColor *)uiColor
{
  CGFloat red, green, blue, alpha;
  [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
  red = roundf(red * 255);
  green = roundf(green * 255);
  blue = round(blue * 255);
  NSString *hexString  = [NSString stringWithFormat:@"#%02x%02x%02x", ((int)red), ((int)green), ((int)blue)];
  return hexString.uppercaseString;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
  if (hexString.length == 0) {
    return [UIColor blackColor];
  }
  NSUInteger rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1]; // bypass '#' character
  [scanner scanHexInt:&rgbValue];
  CGFloat redComponent = ((rgbValue & 0xFF0000) >> 16) / 255.0;
  CGFloat blueComponent = ((rgbValue & 0xFF00) >> 8) / 255.0;
  CGFloat greenComponent = (rgbValue & 0xFF) / 255.0;
  return [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:1.0];
}


@end
