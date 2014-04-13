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

@end

@implementation FBColorComponentView

- (id)initWithFrame:(CGRect)frame
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
  CGFloat width = CGRectGetWidth(self.frame);

  self.label = [[UILabel alloc] initWithFrame:CGRectZero];
  self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
  [self addSubview:self.label];

  self.slider = [[FBSliderView alloc] initWithFrame:CGRectMake(50, 0.0f, width - 60 - 50, 0.0f)];
  self.slider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  self.slider.value = 1.0f;
  [self addSubview:self.slider];

  self.textField = [[UITextField alloc] initWithFrame:CGRectMake(width - 40, 0.0f, 0.0f, 0.0f)];
  self.textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.textField setText:@"255"];
  [self.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [self.textField sizeToFit];
  [self addSubview:self.textField];
}

- (void)setTag:(NSInteger)tag
{
  [super setTag:tag];
  self.textField.tag = tag;
  self.slider.tag = tag;
}

@end
