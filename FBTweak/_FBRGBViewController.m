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

static CGFloat const _FBColorComponentMaxValue = 255.0f;
static CGFloat const _FBColorComponentViewSpacing = 5.0f;
static NSUInteger const _FBColorComponentsNumber = 4;

@interface FBRGBViewController () <UITextFieldDelegate>
{
  CGFloat _colorComponents[_FBColorComponentsNumber];
  UIView* _colorSample;
  UIScrollView* _scrollView;
  UIView* _contentView;
  NSArray* _colorComponentViews;

  BOOL _keyboardIsShown;
  UITextField* __weak _activeField;
}

@end

@implementation FBRGBViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self setColor:[UIColor whiteColor]];
  }
  return self;
}

- (void)loadView
{
  self.view = [self _createRGBView];
  [self _setupAutolayoutConstraints];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self _updateUIControls];
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

- (void)setColor:(UIColor *)color
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
  if ([self isViewLoaded]) {
    [self _updateUIControls];
  }
}

- (IBAction)onSliderValueChanged:(FBSliderView*)slider
{
  _colorComponents[slider.tag] = slider.value;
  [self _updateUIControls];
  if (_colorValueDidChangeCallback) {
    _colorValueDidChangeCallback([self _selectedColor]);
  }
}

- (void)dealloc
{
  [_colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    colorComponentView.textField.delegate = nil;
    [colorComponentView.slider removeTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  }];
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
    _colorComponents[textField.tag] = [newString floatValue] / _FBColorComponentMaxValue;
    UIColor* _selectedColor = [self _selectedColor];
    [_colorSample setBackgroundColor:_selectedColor];
    [self _updateSliders];
    if (_colorValueDidChangeCallback) {
      _colorValueDidChangeCallback(_selectedColor);
    }
  }
  return isValid;
}

#pragma mark - Private methods

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

- (UIView*)_createRGBView
{
  UIView* view = [[UIView alloc] init];
  _scrollView = [[UIScrollView alloc] init];
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [view addSubview:_scrollView];

  _contentView = [[UIView alloc] init];
  _contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [_scrollView addSubview:_contentView];

  _colorSample = [[UIView alloc] init];
  _colorSample.layer.borderColor = [UIColor blackColor].CGColor;
  _colorSample.layer.borderWidth = .5f;
  _colorSample.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_colorSample];

  NSMutableArray* tmp = [NSMutableArray array];
  NSArray* titles = @[@"Red", @"Green", @"Blue", @"Alpha"];
  for(int i = 0; i < _FBColorComponentsNumber; ++i) {
    UIView* colorComponentView = [self _colorComponentViewWithTitle:titles[i] tag:i];
    [_contentView addSubview:colorComponentView];
    [tmp addObject:colorComponentView];
  }
  _colorComponentViews = [tmp copy];
  return view;
}

- (void)_setupAutolayoutConstraints
{
  __block NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views]];

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

  views = NSDictionaryOfVariableBindings(_colorSample);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_colorSample]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_colorSample(30)]" options:0 metrics:nil views:views]];

  __block UIView* previousView = _colorSample;
  [_colorComponentViews enumerateObjectsUsingBlock:^(UIView* colorComponentView, NSUInteger idx, BOOL *stop) {
    views = NSDictionaryOfVariableBindings(previousView, colorComponentView);
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[colorComponentView]-10-|" options:0 metrics:nil views:views]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-20-[colorComponentView]" options:0 metrics:nil views:views]];
    previousView = colorComponentView;
  }];
  views = NSDictionaryOfVariableBindings(previousView);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-10-|" options:0 metrics:nil views:views]];
}


- (UIView*)_colorComponentViewWithTitle:(NSString*)title tag:(NSUInteger)tag
{
  FBColorComponentView* colorComponentView = [[FBColorComponentView alloc] init];
  [colorComponentView.slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  colorComponentView.label.text = title;
  colorComponentView.translatesAutoresizingMaskIntoConstraints = NO;
  colorComponentView.textField.delegate = self;
  colorComponentView.tag  = tag;
  return colorComponentView;
}

- (UIColor*)_selectedColor
{
  return [UIColor colorWithRed:_colorComponents[0] green:_colorComponents[1] blue:_colorComponents[2] alpha:_colorComponents[3]];
}

- (void)_updateUIControls
{
  [_colorSample setBackgroundColor:[self _selectedColor]];
  [self _updateSliders];
  [self _updateTextFields];
}

- (void)_updateSliders
{
  [_colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    FBSliderView* slider = colorComponentView.slider;
    if (idx < 3) {
      [self _updateSlider:slider];
    }
    [slider setValue:_colorComponents[slider.tag]];
  }];
}

- (void)_updateTextFields
{
  [_colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
      colorComponentView.textField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[idx] * _FBColorComponentMaxValue)];
  }];
}

- (void)_updateSlider:(FBSliderView*)slider
{
  NSUInteger colorIndex = slider.tag;
  float currentColorValue = _colorComponents[colorIndex];
  float colors[12];
  for (int i = 0; i < 4 ; i++)
  {
    colors[i] = _colorComponents[i];
    colors[i + 4] = _colorComponents[i];
    colors[i + 8] = _colorComponents[i];
  }
  colors[colorIndex] = 0;
  colors[colorIndex + 4] = currentColorValue;
  colors[colorIndex + 8] = 1.0;
  UIColor* start = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:1.0f];
  UIColor* middle = [UIColor colorWithRed:colors[4] green:colors[5] blue:colors[6] alpha:1.0f];
  UIColor* end = [UIColor colorWithRed:colors[8] green:colors[9] blue:colors[10] alpha:1.0f];
  [slider setColors:@[(id)start.CGColor, (id)middle.CGColor, (id)end.CGColor]];
}

@end
