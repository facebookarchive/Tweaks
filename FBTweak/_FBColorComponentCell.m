/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorComponentCell.h"
#import "_FBSliderView.h"

extern CGFloat const _FBRGBColorComponentMaxValue;
static CGFloat const _FBColorComponentMargin = 5.0f;
static CGFloat const _FBColorComponentTextSpacing = 10.0f;
static CGFloat const _FBColorComponentTextFieldWidth = 50.0f;

@interface _FBColorComponentCell () <UITextFieldDelegate>

@end

@implementation _FBColorComponentCell {
  UILabel *_label;
  _FBSliderView *_slider;
  UITextField *_textField;
}

- (instancetype)init
{
  if (self = [super init]) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _format = @"%.f";

    _label = [[UILabel alloc] init];
    _label.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_label];

    _slider = [[_FBSliderView alloc] init];
    _slider.maximumValue = _FBRGBColorComponentMaxValue;
    [self.contentView addSubview:_slider];

    _textField = [[UITextField alloc] init];
    _textField.textAlignment = NSTextAlignmentCenter;
    [_textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [self.contentView addSubview:_textField];

    [self setValue:0.0f];
    [_slider addTarget:self action:@selector(_didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
    [_textField setDelegate:self];
  }

  return self;
}

- (void)setTitle:(NSString *)title
{
  _label.text = title;
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
  _slider.minimumValue = minimumValue;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
  _slider.maximumValue = maximumValue;
}

- (void)setValue:(CGFloat)value
{
  _slider.value = value;
  _textField.text = [NSString stringWithFormat:_format, value];
}

- (NSString *)title
{
  return _label.text;
}

- (CGFloat)minimumValue
{
  return _slider.minimumValue;
}

- (CGFloat)maximumValue
{
  return _slider.maximumValue;
}

- (CGFloat)value
{
  return _slider.value;
}

- (void)setColors:(NSArray *)colors
{
  _slider.colors = colors;
}

- (NSArray *)colors
{
  return _slider.colors;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self setValue:[textField.text floatValue]];
  [self.delegate colorComponentCell:self didChangeValue:self.value];
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
  if ([newString rangeOfCharacterFromSet:[self _invertedDecimalDigitAndDotCharacterSet]].location != NSNotFound) {
    return NO;
  }

  return [newString floatValue] <= _slider.maximumValue;
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  CGFloat cellHeight = CGRectGetHeight(self.bounds);
  CGFloat cellWidth = CGRectGetWidth(self.bounds);
  CGFloat labelWidth = [_label sizeThatFits:CGSizeZero].width;
  _label.frame = CGRectIntegral((CGRect){_FBColorComponentMargin, _FBColorComponentMargin, labelWidth, cellHeight - 2 * _FBColorComponentMargin});
  _textField.frame = CGRectIntegral((CGRect){cellWidth - _FBColorComponentMargin - _FBColorComponentTextFieldWidth, _FBColorComponentMargin, _FBColorComponentTextFieldWidth, cellHeight - 2 * _FBColorComponentMargin});
  CGFloat sliderWidth = CGRectGetMinX(_textField.frame) - CGRectGetMaxX(_label.frame) - 2 * _FBColorComponentTextSpacing;
  _slider.frame = CGRectIntegral((CGRect){CGRectGetMaxX(_label.frame) + _FBColorComponentTextSpacing, _FBColorComponentMargin, sliderWidth, cellHeight - 2 * _FBColorComponentMargin});
}

#pragma mark - Private methods

- (void)_didChangeSliderValue:(_FBSliderView*)sender
{
  [self setValue:sender.value];
  [self.delegate colorComponentCell:self didChangeValue:self.value];
}

- (NSCharacterSet*)_invertedDecimalDigitAndDotCharacterSet
{
  NSMutableCharacterSet *characterSet = [NSMutableCharacterSet decimalDigitCharacterSet];
  [characterSet addCharactersInString:@"."];
  return [[characterSet invertedSet] copy];
}

@end
