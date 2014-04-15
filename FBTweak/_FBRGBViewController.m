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

@interface FBRGBViewController () <UITextFieldDelegate>
{
  CGFloat _colorComponents[4];
}

@property(nonatomic, strong) UIView* colorSample;
@property(nonatomic, strong) UIScrollView* scrollView;
@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) NSArray* colorComponentViews;

@property(nonatomic, assign) BOOL keyboardIsShown;
@property(nonatomic, weak) UITextField* activeField;

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

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.scrollView];
  NSDictionary *views = @{ @"scrollView" : self.scrollView};
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views]];

  self.contentView = [[UIView alloc] init];
  self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.scrollView addSubview:self.contentView];
  views = @{ @"contentView" : self.contentView};
  [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
  NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:0
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0];
  [self.view addConstraint:leftConstraint];

  NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:0
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0];
  [self.view addConstraint:rightConstraint];

  self.colorSample = [[UIView alloc] init];
  self.colorSample.layer.borderColor = [UIColor blackColor].CGColor;
  self.colorSample.layer.borderWidth = .5f;
  self.colorSample.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:self.colorSample];
  views = @{ @"colorSample" : self.colorSample};
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[colorSample]-10-|" options:0 metrics:nil views:views]];
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[colorSample(30)]" options:0 metrics:nil views:views]];

  NSMutableArray* tmp = [NSMutableArray array];
  NSArray* titles = @[@"Red", @"Green", @"Blue", @"Alpha"];
  UIView* previousView = self.colorSample;
  for(int i = 0; i < 4; ++i) {
    UIView* colorComponentView = [self colorComponentViewWithTitle:titles[i] tag:i];
    [self.contentView addSubview:colorComponentView];
    [tmp addObject:colorComponentView];
    views = NSDictionaryOfVariableBindings(previousView, colorComponentView);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[colorComponentView]-10-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-20-[colorComponentView]" options:0 metrics:nil views:views]];
    previousView = colorComponentView;
  }
  views = NSDictionaryOfVariableBindings(previousView);
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-10-|" options:0 metrics:nil views:views]];
  self.colorComponentViews = [tmp copy];

  [self updateUIControls];
}

- (UIView*)colorComponentViewWithTitle:(NSString*)title tag:(NSUInteger)tag
{
  FBColorComponentView* colorComponentView = [[FBColorComponentView alloc] init];
  [colorComponentView.slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  colorComponentView.label.text = title;
  colorComponentView.translatesAutoresizingMaskIntoConstraints = NO;
  colorComponentView.textField.delegate = self;
  colorComponentView.tag  = tag;
  return colorComponentView;
}

- (void)viewWillAppear:(BOOL)animated
{
  // register for keyboard notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
  // unregister for keyboard notifications while not visible.
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardDidShowNotification
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
    [self updateUIControls];
  }
}

- (IBAction)onSliderValueChanged:(FBSliderView*)slider
{
  _colorComponents[slider.tag] = slider.value;
  [self updateUIControls];
  if (self.colorValueDidChangeCallback) {
    self.colorValueDidChangeCallback([self selectedColor]);
  }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  self.activeField = nil;
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

  BOOL isValid = [newString floatValue] <= 255.0f;
  if (isValid) {
    _colorComponents[textField.tag] = [newString floatValue] / 255.0f;
    UIColor* selectedColor = [self selectedColor];
    [self.colorSample setBackgroundColor:selectedColor];
    [self updateSliders];
    if (self.colorValueDidChangeCallback) {
      self.colorValueDidChangeCallback(selectedColor);
    }
  }
  return isValid;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  CGFloat kbHeight = kbSize.height;
  if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    kbHeight = kbSize.width;
  }

  UIEdgeInsets contentInsets = self.scrollView.contentInset;
  contentInsets.bottom = kbHeight;
  self.scrollView.contentInset = contentInsets;
  self.scrollView.scrollIndicatorInsets = contentInsets;

  // If active text field is hidden by keyboard, scroll it so it's visible
  // Your app might not need or want this behavior.
  CGRect aRect = self.scrollView.frame;
  aRect.size.height = aRect.size.height - contentInsets.top - contentInsets.bottom;
  CGRect activeFieldFrame = [self.contentView convertRect:self.activeField.frame fromView:self.activeField];
  if (!CGRectContainsPoint(aRect, activeFieldFrame.origin) ) {
    CGPoint offset = CGPointMake(0, activeFieldFrame.origin.y - kbHeight);
    [self.scrollView setContentOffset:offset animated:YES];
  }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
  UIEdgeInsets contentInsets = self.scrollView.contentInset;
  contentInsets.bottom = 0;
  self.scrollView.contentInset = contentInsets;
  self.scrollView.scrollIndicatorInsets = contentInsets;
  self.scrollView.contentOffset = CGPointMake(0, -contentInsets.top);
}

#pragma mark - Private methods

- (UIColor*)selectedColor
{
  return [UIColor colorWithRed:_colorComponents[0] green:_colorComponents[1] blue:_colorComponents[2] alpha:_colorComponents[3]];
}

- (void)updateUIControls
{
  [self.colorSample setBackgroundColor:[self selectedColor]];
  [self updateSliders];
  [self updateTextFields];
}

- (void)updateSliders
{
  [self.colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    FBSliderView* slider = colorComponentView.slider;
    if (idx < 3) {
      [self updateSlider:slider];
    }
    [slider setValue:_colorComponents[slider.tag]];
  }];
}

- (void)updateTextFields
{
  [self.colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
      colorComponentView.textField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[idx] * 255)];
  }];
}

- (void)updateSlider:(FBSliderView*)slider
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

- (void)dealloc
{
  [self.colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    colorComponentView.textField.delegate = nil;
    [colorComponentView.slider removeTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  }];
}

@end
