/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorComponentView.h"
#import "_FBSliderView.h"

static CGFloat const _FBColorComponentViewSpacing = 5.0f;
static CGFloat const _FBColorComponentLabelWidth = 60.0f;
static CGFloat const _FBColorComponentTextFieldWidth = 45.0f;

@interface FBColorComponentView () {
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

- (void)updateConstraints
{
  if (_didSetupConstraints == NO){
    [self _setupConstraints];
    _didSetupConstraints = YES;
  }
  [super updateConstraints];
}

#pragma mark - Private methods

- (void)_baseInit
{
  _label = [[UILabel alloc] init];
  _label.translatesAutoresizingMaskIntoConstraints = NO;
  _label.adjustsFontSizeToFitWidth = YES;
  [self addSubview:_label];

  _slider = [[FBSliderView alloc] init];
  _slider.value = 1.0f;
  _slider.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:_slider];

  _textField = [[UITextField alloc] init];
  _textField.borderStyle = UITextBorderStyleRoundedRect;
  _textField.translatesAutoresizingMaskIntoConstraints = NO;
  [_textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [self addSubview:_textField];
}

- (void)_setupConstraints
{
  NSDictionary *views = @{ @"label" : _label, @"slider" : _slider, @"textField" : _textField };
  NSDictionary* metrics = @{ @"margin" : @(_FBColorComponentViewSpacing),
                             @"label_width" : @(_FBColorComponentLabelWidth),
                             @"textfield_width" : @(_FBColorComponentTextFieldWidth) };
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label(label_width)]-margin-[slider]-margin-[textField(textfield_width)]|"
                                                               options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|" options:0 metrics:nil views:views]];
}

@end
