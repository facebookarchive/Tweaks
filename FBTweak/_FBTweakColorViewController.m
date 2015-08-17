/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakColorViewController.h"
#import "_FBTweakColorViewControllerHSBDataSource.h"
#import "_FBTweakColorViewControllerRGBDataSource.h"
#import "_FBKeyboardManager.h"
#import "FBColorUtils.h"
#import "FBTweak.h"

static void * kContext = &kContext;

@interface _FBTweakColorViewController ()
{
  @private

  NSObject <_FBTweakColorViewControllerDataSource>* _rgbDataSource;
  NSObject <_FBTweakColorViewControllerDataSource>* _hsbDataSource;
  FBTweak* _tweak;
  _FBKeyboardManager* _keyboardManager;
  UITableView *_tableView;
}

@end

@implementation _FBTweakColorViewController

- (instancetype)initWithTweak:(FBTweak*)tweak
{
  NSParameterAssert(tweak != nil);
  NSParameterAssert([tweak.possibleValues isKindOfClass:[UIColor class]]);
  self = [super init];
  if (self) {
    _tweak = tweak;
    _rgbDataSource = [[_FBTweakColorViewControllerRGBDataSource alloc] init];
    _hsbDataSource = [[_FBTweakColorViewControllerHSBDataSource alloc] init];
    [_rgbDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
    [_hsbDataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(value)) options:NSKeyValueObservingOptionNew context:kContext];
  }
  return self;
}

- (void)dealloc
{
  [_rgbDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
  [_hsbDataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(value))];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  _tableView.delegate = self;
  _tableView.estimatedRowHeight = 44.0;
  _tableView.rowHeight = UITableViewAutomaticDimension;
  [self.view addSubview:_tableView];

  _keyboardManager = [[_FBKeyboardManager alloc] initWithViewScrollView:_tableView];

  UISegmentedControl* segmentedControl = [self _createSegmentedControl];
  self.navigationItem.titleView = segmentedControl;
  segmentedControl.selectedSegmentIndex = 0;
  [self _segmentControlDidChangeValue:segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [_keyboardManager enable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_keyboardManager disable];
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject<_FBTweakColorViewControllerDataSource>*)dataSource change:(NSDictionary *)change context:(void *)context
{
  if (context != kContext) {
    return;
  }
  _tweak.currentValue = FBHexStringFromColor(dataSource.value);
}

#pragma mark - Private methods

- (UIColor*)_colorValue
{
  FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
  return FBColorFromHexString(value);
}

- (IBAction)_segmentControlDidChangeValue:(UISegmentedControl*)sender
{
  NSObject<_FBTweakColorViewControllerDataSource>* dataSource = sender.selectedSegmentIndex == 0 ? _rgbDataSource : _hsbDataSource;
  dataSource.value = [self _colorValue];
  _tableView.dataSource = dataSource;
  [_tableView reloadData];
}

- (UISegmentedControl*)_createSegmentedControl
{
  UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"RGB", @"HSB"]];
  [segmentedControl addTarget:self action:@selector(_segmentControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  [segmentedControl sizeToFit];
  return segmentedControl;
}

@end
