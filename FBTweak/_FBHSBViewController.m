/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBHSBViewController.h"
#import "_FBColorWheelView.h"
#import "_FBColorComponentView.h"
#import "_FBSliderView.h"
#import "FBTweak.h"

static CGFloat const _FBColorComponentMaxValue = 255.0f;

@interface FBHSBViewController () <UITextFieldDelegate> {

  FBColorWheelView* _colorWheel;
  FBColorComponentView* _brightnessView;
  FBColorComponentView* _alphaView;
  UIView* _colorSample;
  UIScrollView* _scrollView;
  UIView* _contentView;

  BOOL _keyboardIsShown;
  UITextField* __weak _activeField;

  FBTweak* _tweak;
}

@end

@implementation FBHSBViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;

    self.title = _tweak.name;

    FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
//    [self _setColorComponents:[UIColor colorWithHexString:value]];
  }
  return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  _scrollView = [[UIScrollView alloc] init];
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_scrollView];
  NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views]];

  _contentView = [[UIView alloc] init];
  _contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [_scrollView addSubview:_contentView];
  views = NSDictionaryOfVariableBindings(_contentView);
  [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics:nil views:views]];
  NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_contentView
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:0
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0];
  [self.view addConstraint:leftConstraint];

  NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_contentView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:0
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0];
  [self.view addConstraint:rightConstraint];

  _colorSample = [[UIView alloc] init];
  _colorSample.layer.borderColor = [UIColor blackColor].CGColor;
  _colorSample.layer.borderWidth = .5f;
  _colorSample.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_colorSample];
  views = NSDictionaryOfVariableBindings(_colorSample);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_colorSample]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_colorSample(30)]" options:0 metrics:nil views:views]];

  _colorWheel = [[FBColorWheelView alloc] init];
  [_colorWheel addTarget:self action:@selector(onColorChanged:) forControlEvents:UIControlEventValueChanged];
  _colorWheel.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_colorWheel];
  views = NSDictionaryOfVariableBindings(_colorSample, _colorWheel);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_colorWheel]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_colorSample]-20-[_colorWheel]" options:0 metrics:nil views:views]];
  [_contentView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:_colorWheel
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_colorWheel
                                   attribute:NSLayoutAttributeHeight
                                   multiplier:1.0f
                                   constant:0]];


  _brightnessView = [[FBColorComponentView alloc] init];
  [_brightnessView.slider addTarget:self action:@selector(onBrightnessChanged:) forControlEvents:UIControlEventValueChanged];
  _brightnessView.label.text = @"Brightness";
  _brightnessView.slider.value = 1.0f;
  _brightnessView.translatesAutoresizingMaskIntoConstraints = NO;
  _brightnessView.textField.delegate = self;
  [_contentView addSubview:_brightnessView];
  views = NSDictionaryOfVariableBindings(_colorWheel, _brightnessView);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_brightnessView]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_colorWheel]-20-[_brightnessView]" options:0 metrics:nil views:views]];


  _alphaView = [[FBColorComponentView alloc] init];
  [_alphaView.slider addTarget:self action:@selector(onAlphaChanged:) forControlEvents:UIControlEventValueChanged];
  _alphaView.label.text = @"Alpha";
  _alphaView.slider.value = 1.0f;
  _alphaView.translatesAutoresizingMaskIntoConstraints = NO;
  _alphaView.textField.delegate = self;
  [_contentView addSubview:_alphaView];
  views = @{ @"brightnessView" : _brightnessView, @"alphaView" : _alphaView};
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[alphaView]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brightnessView]-20-[alphaView]-|" options:0 metrics:nil views:views]];
}

- (void)viewWillAppear:(BOOL)animated
{
  // register for keyboard notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_keyboardWillBeShown:)
                                               name:UIKeyboardWillShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
  // unregister for keyboard notifications while not visible.
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];

  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
}

- (void)setColor:(UIColor*)color
{

}

- (UIColor*)selectedColor
{
  HSB hsb = _colorWheel.hsb;
  return [UIColor colorWithHue:hsb.hue saturation:hsb.saturation brightness:_brightnessView.slider.value alpha:_alphaView.slider.value];
}

- (UIColor*)identityColor
{
  HSB hsb = _colorWheel.hsb;
  return [UIColor colorWithHue:hsb.hue saturation:hsb.saturation brightness:1.0f alpha:1.0f];
}

- (IBAction)onColorChanged:(FBColorWheelView*)sender
{
  UIColor* identityColor = [self identityColor];
  [_brightnessView.slider setColors:@[(id)[UIColor blackColor].CGColor, (id)identityColor.CGColor]];
  [self pickedColor:[self selectedColor]];
}

- (IBAction)onBrightnessChanged:(FBSliderView*)sender
{
  [self pickedColor:[self selectedColor]];
}

- (IBAction)onAlphaChanged:(FBSliderView*)sender
{
  [self pickedColor:[self selectedColor]];
}

- (void) pickedColor:(UIColor *)color {

  [_colorSample setBackgroundColor:color];
}


- (void)_keyboardWillBeShown:(NSNotification*)aNotification
{
  NSDictionary* info = [aNotification userInfo];
  NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  CGFloat kbHeight = kbSize.height;
  if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    kbHeight = kbSize.width;
  }
  UIEdgeInsets contentInsets = _scrollView.contentInset;
  contentInsets.bottom = kbHeight;

  CGRect aRect = _scrollView.frame;
  aRect.size.height = aRect.size.height - contentInsets.top - contentInsets.bottom;
  CGRect activeFieldFrame = [_contentView convertRect:_activeField.frame fromView:_activeField.superview];
  CGPoint offset = _scrollView.contentOffset;
  if (!CGRectContainsPoint(aRect, activeFieldFrame.origin) ) {
    offset = CGPointMake(0, CGRectGetMaxY(activeFieldFrame) - contentInsets.bottom);
  }
  __weak typeof(_scrollView) weakScrollView = _scrollView;
  void (^animations)() = ^{
    weakScrollView.contentInset = contentInsets;
    weakScrollView.scrollIndicatorInsets = contentInsets;
    weakScrollView.contentOffset = offset;
  };
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

- (void)_keyboardWillBeHidden:(NSNotification*)aNotification
{
  UIEdgeInsets contentInsets = _scrollView.contentInset;
  contentInsets.bottom = 0;
  _scrollView.contentInset = contentInsets;
  _scrollView.scrollIndicatorInsets = contentInsets;
  _scrollView.contentOffset = CGPointMake(0, -contentInsets.top);
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  _activeField = nil;
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

  BOOL isValid = [newString floatValue] <= _FBColorComponentMaxValue;
  if (isValid) {
//    _colorComponents[textField.tag] = [newString floatValue] / _FBColorComponentMaxValue;
//    UIColor* _selectedColor = [self _selectedColor];
//    [_colorSample setBackgroundColor:_selectedColor];
//    [self _updateSliders];
//    if (_colorValueDidChangeCallback) {
//      _colorValueDidChangeCallback(_selectedColor);
//    }
  }
  return isValid;
}

@end
