/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorComponentCell.h"
#import "_FBSliderView.h"

extern CGFloat const FBRGBColorComponentMaxValue;
static CGFloat const _FBColorComponentMargin = 5.0f;
static CGFloat const _FBColorComponentTextSpacing = 10.0f;
static CGFloat const _FBColorComponentTextFieldWidth = 50.0f;

@interface _FBColorComponentCell () <UITextFieldDelegate>
{

@private

  UILabel* _label;
  _FBSliderView* _slider;
  UITextField* _textField;
}

@end

@implementation _FBColorComponentCell

- (instancetype)init
{
  if ((self = [super init])) {
    [self _init];
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

- (NSString*)title
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
  NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,."] invertedSet];
  if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
    return NO;
  }

  return [newString floatValue] <= _slider.maximumValue;
}

#pragma mark - Private methods

- (void)_init
{
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  _format = @"%.f";

  _label = [[UILabel alloc] init];
  _label.translatesAutoresizingMaskIntoConstraints = NO;
  _label.adjustsFontSizeToFitWidth = YES;
  [self.contentView addSubview:_label];

  _slider = [[_FBSliderView alloc] init];
  _slider.maximumValue = FBRGBColorComponentMaxValue;
  _slider.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:_slider];

  _textField = [[UITextField alloc] init];
  _textField.textAlignment = NSTextAlignmentCenter;
  _textField.translatesAutoresizingMaskIntoConstraints = NO;
  [_textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [self.contentView addSubview:_textField];

  [self setValue:0.0f];
  [_slider addTarget:self action:@selector(_didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
  [_textField setDelegate:self];

  [self _installConstraints];
}

- (void)_didChangeSliderValue:(_FBSliderView*)sender
{
  [self setValue:sender.value];
  [self.delegate colorComponentCell:self didChangeValue:self.value];
}

- (void)_installConstraints
{
  NSDictionary *views = @{ @"label" : _label, @"slider" : _slider, @"textField" : _textField };
  NSDictionary* metrics = @{ @"margin" : @(_FBColorComponentMargin),
                             @"spacing" : @(_FBColorComponentTextSpacing),
                             @"textfield_width" : @(_FBColorComponentTextFieldWidth) };
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[label]-spacing-[slider]-spacing-[textField(textfield_width)]-margin-|"
                                                               options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[label]-margin-|" options:0 metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[textField]-margin-|" options:0 metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[slider]-margin-|" options:0 metrics:metrics views:views]];
}

@end
