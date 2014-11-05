//
//  _FBTweakDictionaryViewController.m
//  FBTweak
//
//  Created by John McIntosh on 11/5/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "_FBTweakDictionaryViewController.h"
#import "FBTweak.h"
#import "FBTweak+Dictionary.h"

@interface _FBTweakDictionaryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation _FBTweakDictionaryViewController

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
  return self.tweak.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *_FBTweakDictionaryViewControllerCellIdentifier = @"_FBTweakDictionaryViewControllerCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:_FBTweakDictionaryViewControllerCellIdentifier];
  }
  
  NSArray *allKeys = [self allTweakKeys];
  NSString *key = allKeys[indexPath.row];
  NSString *value = self.tweak.dictionaryValue[key];
  cell.textLabel.text = key;
  cell.detailTextLabel.text = value;
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  NSString *selectedKey = (self.tweak.currentValue ?: self.tweak.defaultValue);
  if ([selectedKey isEqualToString:key]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *allKeys = [self allTweakKeys];
  NSString *key = allKeys[indexPath.row];
  
  self.tweak.currentValue = key;
  [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)allTweakKeys {
  return [self.tweak.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return [obj1 compare:obj2];
  }];
}

@end