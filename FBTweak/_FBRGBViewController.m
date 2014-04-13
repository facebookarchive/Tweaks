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
@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) UIScrollView* view;
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

- (void)loadView
{
  UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  scrollView.contentSize = [[UIScreen mainScreen] bounds].size;
  self.contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.contentView.backgroundColor = [UIColor lightGrayColor];
  [scrollView addSubview:self.contentView];
  self.view = scrollView;

  CGFloat width = CGRectGetWidth(self.view.bounds);

  self.colorSample = [[UIView alloc] initWithFrame:CGRectMake(10, 20, width - 20, 30)];
  self.colorSample.layer.borderColor = [UIColor blackColor].CGColor;
  self.colorSample.layer.borderWidth = .5f;
  self.colorSample.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.contentView addSubview:_colorSample];

  NSMutableArray* tmp = [NSMutableArray array];
  CGFloat y = CGRectGetMaxY(self.colorSample.frame) + 20;
  CGFloat x = CGRectGetMidX(self.colorSample.frame);
  NSArray* titles = @[@"Red", @"Green", @"Blue", @"Alpha"];
  for(int i = 0; i < 4; ++i) {
    UIView* colorComponentView = [self colorComponentViewWithTitle:titles[i] tag:i];
    colorComponentView.center = CGPointMake(x, y);
    [self.contentView addSubview:colorComponentView];
    [tmp addObject:colorComponentView];
    y += CGRectGetHeight(colorComponentView.frame) + 20;
  }
  self.colorComponentViews = [tmp copy];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self updateUIControls];
}

- (UIView*)colorComponentViewWithTitle:(NSString*)title tag:(NSUInteger)tag
{
  CGFloat width = CGRectGetWidth(self.view.bounds);
  FBColorComponentView* colorComponentView = [[FBColorComponentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 30.0f)];
  [colorComponentView.slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  colorComponentView.label.text = title;
  [colorComponentView.label sizeToFit];
  colorComponentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
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
    [self.colorSample setBackgroundColor:[self selectedColor]];
    [self updateSliders];
    if (self.colorValueDidChangeCallback) {
      self.colorValueDidChangeCallback([self selectedColor]);
    }
  }
  return isValid;
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
  CGRect activeFieldFrame = [self.activeField convertRect:self.activeField.bounds fromView:self.view];
  if (!CGRectContainsPoint(aRect, activeFieldFrame.origin) ) {
    [self.view scrollRectToVisible:self.activeField.frame animated:YES];
  }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
  UIEdgeInsets contentInsets = UIEdgeInsetsZero;
  self.view.contentInset = contentInsets;
  self.view.scrollIndicatorInsets = contentInsets;
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
    if (idx < 3) {
      colorComponentView.textField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[idx] * 255)];
    } else {
      colorComponentView.textField.text = [NSString stringWithFormat:@"%d", (NSInteger)(_colorComponents[idx] * 100)];
    }
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
