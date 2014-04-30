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
#import "FBTweak.h"
#import "UIColor+HEX.h"

@interface FBRGBViewController () <UITextFieldDelegate, FBRGBViewDataSource>
{
  RGB _colorComponents;
  FBTweak* _tweak;
  NSArray* _colorComponentMaxValues;
}

@property(nonatomic, strong) FBRGBView* view;

@end

@implementation FBRGBViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;
    _colorComponentMaxValues = @[@(255.0f), @(255.0f), @(255.0f),
                                 @(100.0f)];

    self.title = _tweak.name;

    FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
    _colorComponents = RGBColorComponents([UIColor colorWithHexString:value]);
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

- (IBAction)onSliderValueChanged:(FBSliderView*)slider
{
  [self _setColorComponentValue:slider.value atIndex:slider.tag];
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

- (RGB)colorComponents
{
  return _colorComponents;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  CGFloat maxValue = [_colorComponentMaxValues[textField.tag] floatValue];
  [self _setColorComponentValue:[textField.text floatValue] / maxValue atIndex:textField.tag];
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
  CGFloat maxValue = [_colorComponentMaxValues[textField.tag] floatValue];
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

  //first, check if the new string is numeric only. If not, return NO;
  NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,."] invertedSet];
  if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
    return NO;
  }

  return [newString floatValue] <= maxValue;
}

#pragma mark - Private methods

- (NSString*)_hexColorString
{
  UIColor* selectedColor = [UIColor colorWithRed:_colorComponents.red green:_colorComponents.green blue:_colorComponents.green alpha:_colorComponents.alpha];
  return [selectedColor hexString];
}

- (void)_setColorComponentValue:(CGFloat)value atIndex:(NSUInteger)index
{
  switch (index) {
    case 0:
      _colorComponents.red = value;
      break;
    case 1:
      _colorComponents.green = value;
      break;
    case 2:
      _colorComponents.blue = value;
      break;
    default:
      _colorComponents.alpha = value;
      break;
  }
}

@end
