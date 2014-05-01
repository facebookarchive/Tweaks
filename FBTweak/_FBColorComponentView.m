/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorComponentView.h"
#import "_FBSliderView.h"

extern CGFloat const FBRGBColorComponentMaxValue;
static CGFloat const _FBColorComponentViewSpacing = 5.0f;
static CGFloat const _FBColorComponentLabelWidth = 60.0f;
static CGFloat const _FBColorComponentTextFieldWidth = 50.0f;

@interface FBColorComponentView () <UITextFieldDelegate>
{

  @private
  
  BOOL _didSetupConstraints;
}

@property(nonatomic, strong, readwrite) UILabel* label;
@property(nonatomic, strong, readwrite) FBSliderView* slider;
@property(nonatomic, strong, readwrite) UITextField* textField;

@end

@implementation FBColorComponentView

+ (BOOL)requiresConstraintBasedLayout
{
  return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self _baseInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self _baseInit];
  }
  return self;
}

- (void)setTag:(NSInteger)tag
{
  [super setTag:tag];
  _textField.tag = tag;
  _slider.tag = tag;
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

- (void)updateConstraints
{
  if (_didSetupConstraints == NO){
    [self _setupConstraints];
    _didSetupConstraints = YES;
  }
  [super updateConstraints];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self setValue:[textField.text floatValue]];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
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

- (void)_baseInit
{
  _format = @"%.f";

  _label = [[UILabel alloc] init];
  _label.translatesAutoresizingMaskIntoConstraints = NO;
  _label.adjustsFontSizeToFitWidth = YES;
  [self addSubview:_label];

  _slider = [[FBSliderView alloc] init];
  _slider.maximumValue = FBRGBColorComponentMaxValue;
  _slider.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:_slider];

  _textField = [[UITextField alloc] init];
  _textField.borderStyle = UITextBorderStyleRoundedRect;
  _textField.translatesAutoresizingMaskIntoConstraints = NO;
  [_textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [self addSubview:_textField];

  [self setValue:0.0f];
  [_slider addTarget:self action:@selector(_didChangeSliderValue:) forControlEvents:UIControlEventValueChanged];
  [_textField setDelegate:self];
}

- (void)_didChangeSliderValue:(FBSliderView*)sender
{
  [self setValue:sender.value];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_setupConstraints
{
  NSDictionary *views = @{ @"label" : _label, @"slider" : _slider, @"textField" : _textField };
  NSDictionary* metrics = @{ @"spacing" : @(_FBColorComponentViewSpacing),
                             @"label_width" : @(_FBColorComponentLabelWidth),
                             @"textfield_width" : @(_FBColorComponentTextFieldWidth) };
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label(label_width)]-spacing-[slider]-spacing-[textField(textfield_width)]|"
                                                               options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|" options:0 metrics:nil views:views]];
}

@end
