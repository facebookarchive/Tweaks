/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCollection.h"
#import "FBTweakCategory.h"
#import "FBTweak.h"
#import "_FBTweakCollectionViewController.h"
#import "_FBTweakTableViewCell.h"
#import "_FBRGBViewController.h"

@interface UIColor (Utils)

- (NSString *)hexString;

@end

@implementation UIColor (Utils)

- (NSString *)hexString
{
  const CGFloat *components = CGColorGetComponents(self.CGColor);
  CGFloat r = components[0];
  CGFloat g = components[1];
  CGFloat b = components[2];
  CGFloat a = components[3];
  NSString *hexColorString = [NSString stringWithFormat:@"#%02X%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255), (int)(a * 255)];
  return hexColorString;
}

+ (UIColor*)colorWithHexString:(NSString*)hexColor
{
  if (![hexColor hasPrefix:@"#"]) {
    return nil;
  }

  NSScanner *scanner = [NSScanner scannerWithString:hexColor];
  [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];

  unsigned hexNum;
  if (![scanner scanHexInt: &hexNum]) return nil;

  int r = (hexNum >> 24) & 0xFF;
  int g = (hexNum >> 16) & 0xFF;
  int b = (hexNum >> 8) & 0xFF;
  int a = (hexNum) & 0xFF;

  return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
}

@end

@interface _FBTweakCollectionViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation _FBTweakCollectionViewController {
  UITableView *_tableView;
}

- (instancetype)initWithTweakCategory:(FBTweakCategory *)category
{
  if ((self = [super init])) {
    _tweakCategory = category;
    
    self.title = _tweakCategory.name;
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  [self.view addSubview:_tableView];
}

- (void)dealloc
{
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:animated];
  [_tableView reloadData];
}

- (void)_keyboardFrameChanged:(NSNotification *)notification
{
  CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  endFrame = [self.view.window convertRect:endFrame fromWindow:nil];
  endFrame = [self.view convertRect:endFrame fromView:self.view.window];
  
  NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  
  void (^animations)() = ^{
    UIEdgeInsets contentInset = _tableView.contentInset;
    contentInset.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
    _tableView.contentInset = contentInset;
    
    UIEdgeInsets scrollIndicatorInsets = _tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (self.view.bounds.size.height - CGRectGetMinY(endFrame));
    _tableView.scrollIndicatorInsets = scrollIndicatorInsets;
  };
  
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  
  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _tweakCategory.tweakCollections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  FBTweakCollection *collection = _tweakCategory.tweakCollections[section];
  return collection.tweaks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  FBTweakCollection *collection = _tweakCategory.tweakCollections[section];
  return collection.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakCollectionViewControllerCellIdentifier = @"_FBTweakCollectionViewControllerCellIdentifier";
  _FBTweakTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[_FBTweakTableViewCell alloc] initWithReuseIdentifier:_FBTweakCollectionViewControllerCellIdentifier];
  }
  
  FBTweakCollection *collection = _tweakCategory.tweakCollections[indexPath.section];
  FBTweak *tweak = collection.tweaks[indexPath.row];
  cell.tweak = tweak;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  _FBTweakTableViewCell *cell = (_FBTweakTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  if ([cell mode] == _FBTweakTableViewCellModeColor) {
    FBTweakValue value = (cell.tweak.currentValue ?: cell.tweak.defaultValue);
    FBRGBViewController *rgbViewController = [[FBRGBViewController alloc] init];
    [rgbViewController setColor:[UIColor colorWithHexString:value]];

    FBTweakCollection *collection = _tweakCategory.tweakCollections[indexPath.section];
    FBTweak *tweak = collection.tweaks[indexPath.row];
    rgbViewController.colorValueDidChangeCallback = ^(UIColor* color) {
      tweak.currentValue = [color hexString];
    };

    [self.navigationController pushViewController:rgbViewController animated:YES];
  }
}

@end
