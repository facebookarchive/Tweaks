/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBRGBViewController.h"
#import "_FBSliderView.h"
#import "_FBColorComponentView.h"
#import "_FBRGBView.h"
#import "_FBKeyboardManager.h"
#import "FBTweak.h"
#import "UIColor+HEX.h"

static CGFloat const _FBColorComponentMaxValue = 255.0f;

@interface FBRGBViewController () <UITextFieldDelegate, FBRGBViewDataSource>
{
  CGFloat _colorComponents[4];

  FBKeyboardManager* _keyboardManager;
  FBTweak* _tweak;
}

@property(nonatomic, strong) FBRGBView* view;

@end

@implementation FBRGBViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;

    self.title = _tweak.name;

    FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
    [self _setColorComponents:[UIColor colorWithHexString:value]];
    _keyboardManager = [[FBKeyboardManager alloc] init];
  }
  return self;
}

- (void)loadView
{
  self.view = [[FBRGBView alloc] init];
  self.view.dataSource = self;
  [self.view.colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* view, NSUInteger idx, BOOL *stop) {
    [view.slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view.textField setDelegate:self];
  }];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [_keyboardManager enable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [_keyboardManager disable];
}

- (IBAction)onSliderValueChanged:(FBSliderView*)slider
{
  _colorComponents[slider.tag] = slider.value;
  [self.view reloadData];
  _tweak.currentValue = [self _hexColorString];
}

- (void)dealloc
{
  [self.view.colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    colorComponentView.textField.delegate = nil;
    [colorComponentView.slider removeTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  }];
}

#pragma mark - FBRGBViewDataSource methods

- (CGFloat*)colorComponents
{
  return _colorComponents;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  _colorComponents[textField.tag] = [textField.text floatValue] / _FBColorComponentMaxValue;
  _tweak.currentValue = [self _hexColorString];
  [self.view reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

  //first, check if the new string is numeric only. If not, return NO;
  NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,."] invertedSet];
  if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
    return NO;
  }

  return [newString floatValue] <= _FBColorComponentMaxValue;
}

#pragma mark - Private methods

- (void)_setColorComponents:(UIColor *)color
{
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
  if (colorSpaceModel != kCGColorSpaceModelRGB && colorSpaceModel != kCGColorSpaceModelMonochrome) {
    return;
  }
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
    _colorComponents[0] = _colorComponents[1] = _colorComponents[2] = components[0];
    _colorComponents[3] = components[1];
  } else {
    _colorComponents[0] = components[0];
    _colorComponents[1] = components[1];
    _colorComponents[2] = components[2];
    _colorComponents[3] = components[3];
  }
}

- (NSString*)_hexColorString
{
  UIColor* selectedColor = [UIColor colorWithRed:_colorComponents[0] green:_colorComponents[1] blue:_colorComponents[2] alpha:_colorComponents[3]];
  return [selectedColor hexString];
}

@end
