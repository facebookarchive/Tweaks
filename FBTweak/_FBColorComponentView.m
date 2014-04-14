/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorComponentView.h"
#import "_FBSliderView.h"

@interface FBColorComponentView ()

@property(nonatomic, strong) UILabel* label;
@property(nonatomic, strong) FBSliderView* slider;
@property(nonatomic, strong) UITextField* textField;
@property(nonatomic, assign) BOOL didSetupConstraints;

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
    [self baseInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self baseInit];
  }
  return self;
}

- (void)baseInit
{
  self.label = [[UILabel alloc] init];
  self.label.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:self.label];

  self.slider = [[FBSliderView alloc] init];
  self.slider.value = 1.0f;
  self.slider.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:self.slider];

  self.textField = [[UITextField alloc] init];
  self.textField.borderStyle = UITextBorderStyleRoundedRect;
  self.textField.translatesAutoresizingMaskIntoConstraints = NO;
  [self.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [self addSubview:self.textField];
}

- (void)setTag:(NSInteger)tag
{
  [super setTag:tag];
  self.textField.tag = tag;
  self.slider.tag = tag;
}

- (void)updateConstraints
{
  if (self.didSetupConstraints == NO){
    [self setupConstraints];
    self.didSetupConstraints = YES;
  }
  [super updateConstraints];
}

- (void)setupConstraints
{
  NSDictionary *views = @{ @"label" : self.label, @"slider" : self.slider, @"textField" : self.textField };
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label(50)]-10-[slider]-10-[textField(50)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|" options:0 metrics:nil views:views]];
}

@end
