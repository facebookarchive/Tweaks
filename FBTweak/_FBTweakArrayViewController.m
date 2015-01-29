/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakArrayViewController.h"
#import "FBTweak.h"
#import "FBTweak+Array.h"

@interface _FBTweakArrayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation _FBTweakArrayViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.tweak.arrayValue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakDictionaryViewControllerCellIdentifier = @"_FBTweakDictionaryViewControllerCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  }

  FBTweakValue rowValue = self.tweak.arrayValue[indexPath.row];
  NSString *stringValue = [rowValue description];
  cell.textLabel.text = stringValue;

  cell.accessoryType = UITableViewCellAccessoryNone;
  FBTweakValue selectedValue = (self.tweak.currentValue ?: self.tweak.defaultValue);
  if ([selectedValue isEqual:rowValue]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *value = self.tweak.arrayValue[indexPath.row];
  self.tweak.currentValue = value;
  [self.navigationController popViewControllerAnimated:YES];
}

@end
