/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBRGBViewController.h"
#import "_FBSliderView.h"

@interface RGBViewController () <UITextFieldDelegate>
{
  CGFloat _colorComponents[4];
}

@property(nonatomic, strong) FBSliderView* redSlider;
@property(nonatomic, strong) FBSliderView* greenSlider;
@property(nonatomic, strong) FBSliderView* blueSlider;
@property(nonatomic, strong) FBSliderView* alphaSlider;

@property(nonatomic, strong) UITextField* redTextField;
@property(nonatomic, strong) UITextField* greenTextField;
@property(nonatomic, strong) UITextField* blueTextField;
@property(nonatomic, strong) UITextField* alphaTextField;

@property(nonatomic, strong) UIView* colorSample;
@property(nonatomic, assign) BOOL skipCallback;

@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) UIScrollView* view;

@property(nonatomic, assign) BOOL keyboardIsShown;
@property(nonatomic, weak) UITextField* activeField;

@end

@implementation RGBViewController

- (void)loadView
{
  UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.contentSize = [[UIScreen mainScreen] bounds].size;
  self.contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [scrollView addSubview:self.contentView];
  self.view = scrollView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.contentView = self.view;
  self.view.backgroundColor = [UIColor lightGrayColor];

  CGFloat width = CGRectGetWidth(self.view.bounds);

  _colorSample = [[UIView alloc] initWithFrame:CGRectMake(10, 80, width - 20, 30)];
  _colorSample.layer.borderColor = [UIColor blackColor].CGColor;
  _colorSample.layer.borderWidth = .5f;
  _colorSample.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.contentView addSubview:_colorSample];

  UILabel* redLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(_colorSample.frame) + 20, 0.0f, 0.0f)];
  redLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
  [redLabel setText:@"Red"];
  [redLabel sizeToFit];
  [self.contentView addSubview:redLabel];

  _redSlider = [[FBSliderView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(_colorSample.frame) + 20, width - 60 - 50, 0.0f)];
  [_redSlider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  _redSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _redSlider.value = 1.0f;
  _redSlider.tag = 0;
  [self.contentView addSubview:_redSlider];

  _redTextField = [[UITextField alloc] initWithFrame:CGRectMake(width - 40, CGRectGetMaxY(_colorSample.frame) + 20, 0.0f, 0.0f)];
  _redTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  _redTextField.tag = 0;
  [_redTextField setText:@"255"];
  [_redTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [_redTextField sizeToFit];
  [_redTextField setDelegate:self];
  [self.contentView addSubview:_redTextField];

  UILabel* greenLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(_redSlider.frame) + 20, 0.0f, 0.0f)];
  greenLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
  [greenLabel setText:@"Green"];
  [greenLabel sizeToFit];
  [self.contentView addSubview:greenLabel];

  _greenSlider = [[FBSliderView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(_redSlider.frame) + 20, width - 60 - 50, 0.0f)];
  [_greenSlider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  _greenSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _greenSlider.value = 1.0f;
  _greenSlider.tag = 1;
  [self.contentView addSubview:_greenSlider];

  _greenTextField = [[UITextField alloc] initWithFrame:CGRectMake(width - 40, CGRectGetMaxY(_redSlider.frame) + 20, 0.0f, 0.0f)];
  _greenTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  _greenTextField.tag = 1;
  [_greenTextField setText:@"255"];
  [_greenTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [_greenTextField sizeToFit];
  [_greenTextField setDelegate:self];
  [self.contentView addSubview:_greenTextField];

  UILabel* blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(_greenSlider.frame) + 20, 0.0f, 0.0f)];
  blueLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
  [blueLabel setText:@"Blue"];
  [blueLabel sizeToFit];
  [self.contentView addSubview:blueLabel];

  _blueSlider = [[FBSliderView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(_greenSlider.frame) + 20, width - 60 - 50, 0.0f)];
  [_blueSlider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  _blueSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _blueSlider.value = 1.0f;
  _blueSlider.tag = 2;
  [self.contentView addSubview:_blueSlider];

  _blueTextField = [[UITextField alloc] initWithFrame:CGRectMake(width - 40, CGRectGetMaxY(_greenSlider.frame) + 20, 0.0f, 0.0f)];
  _blueTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  _blueTextField.tag = 2;
  [_blueTextField setText:@"255"];
  [_blueTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [_blueTextField sizeToFit];
  [_blueTextField setDelegate:self];
  [self.contentView addSubview:_blueTextField];

  UILabel* alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(_blueSlider.frame) + 20, 0.0f, 0.0f)];
  alphaLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
  [alphaLabel setText:@"Alpha"];
  [alphaLabel sizeToFit];
  [self.contentView addSubview:alphaLabel];

  _alphaSlider = [[FBSliderView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(_blueSlider.frame) + 20, width - 60 - 50, 0.0f)];
  [_alphaSlider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  _alphaSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  _alphaSlider.value = 1.0f;
  _alphaSlider.tag = 3;
  [self.contentView addSubview:_alphaSlider];

  _alphaTextField = [[UITextField alloc] initWithFrame:CGRectMake(width - 40, CGRectGetMaxY(_blueSlider.frame) + 20, 0.0f, 0.0f)];
  _alphaTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  _alphaTextField.tag = 3;
  [_alphaTextField setText:@"255"];
  [_alphaTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [_alphaTextField sizeToFit];
  [_alphaTextField setDelegate:self];
  [self.contentView addSubview:_alphaTextField];

  [self setColor:[UIColor whiteColor]];
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
  [self updateColors];
}

- (IBAction)onSliderValueChanged:(FBSliderView*)slider
{
  int colorIndex = slider.tag;
  _colorComponents[colorIndex] = slider.value;
  [self updateColors];
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
    self.skipCallback = YES;
    FBSliderView* slider = [self sliderWithTag:textField.tag];
    [slider setValue:[newString floatValue] / 255.0f];
  }
  return isValid;
}

#pragma mark - Private

- (FBSliderView*)sliderWithTag:(NSUInteger)tag
{
  switch (tag) {
    case 0:
      return self.redSlider;
      break;
    case 1:
      return self.greenSlider;
      break;
    case 2:
      return self.blueSlider;
      break;
    default:
      return self.alphaSlider;
      break;
  }
}

- (void)updateColors
{
  [self setSlider:_redSlider colorIndex:0];
  [self setSlider:_greenSlider colorIndex:1];
  [self setSlider:_blueSlider colorIndex:2];

  UIColor *currentColor = [UIColor colorWithRed:_colorComponents[0] green:_colorComponents[1] blue:_colorComponents[2] alpha:_colorComponents[3]];
  [self.colorSample setBackgroundColor:currentColor];
  if (self.colorValueDidChangeCallback) {
    self.colorValueDidChangeCallback(currentColor);
  }
  if (self.skipCallback) {
    self.skipCallback = NO;
    return;
  }
  self.redTextField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[0] * 255)];
  self.greenTextField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[1] * 255)];
  self.blueTextField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[2] * 255)];
  self.alphaTextField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[3] * 100)];
}

- (void)setSlider:(FBSliderView*)slider colorIndex:(NSInteger)colorIndex
{
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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
  self.view.contentInset = contentInsets;
  self.view.scrollIndicatorInsets = contentInsets;

  // If active text field is hidden by keyboard, scroll it so it's visible
  // Your app might not need or want this behavior.
  CGRect aRect = self.view.frame;
  aRect.size.height -= kbSize.height;
  if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
    [self.view scrollRectToVisible:self.activeField.frame animated:YES];
  }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
  UIEdgeInsets contentInsets = UIEdgeInsetsZero;
  self.view.contentInset = contentInsets;
  self.view.scrollIndicatorInsets = contentInsets;
}

@end
