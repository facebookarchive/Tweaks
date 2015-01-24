/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak+Array.h"
#import "FBTweakStore.h"
#import "FBTweakCollection.h"
#import "FBTweakCategory.h"

@implementation FBTweak (Array)

- (BOOL)isArray
{
  return (self.arrayValue != nil);
}

- (NSArray *)arrayValue
{
  if ([self.stepValue isKindOfClass:[NSArray class]]) {
    return self.stepValue;
  }
  return nil;
}

- (void)setArrayValue:(NSArray *)arrayValue
{
  self.stepValue = arrayValue;
}

FBTweak* FBArrayTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSArray *array, id defaultValue)
{
  FBTweakStore *store = [FBTweakStore sharedInstance];
  FBTweakCategory *cat = [store tweakCategoryWithName:categoryName];
  
  if (!cat) {
    cat = [[FBTweakCategory alloc] initWithName:categoryName];
    [store addTweakCategory:cat];
  }
  
  FBTweakCollection *collection = [cat tweakCollectionWithName:collectionName];
  
  if (!collection) {
    collection = [[FBTweakCollection alloc] initWithName:collectionName];
    [cat addTweakCollection:collection];
  }
  
  FBTweak *tweak = [collection tweakWithIdentifier:tweakName];
  
  if (!tweak) {
    tweak = [[FBTweak alloc] initWithIdentifier:tweakName];
    tweak.name = tweakName;
    tweak.arrayValue = array;
    tweak.defaultValue = defaultValue;
    
    [collection addTweak:tweak];
  }
  return tweak;
}

FBTweakValue FBArrayTweakValue(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSArray *array, id defaultValue)
{
  FBTweak *tweak = FBArrayTweak(categoryName, collectionName, tweakName, array, defaultValue);
  return tweak.currentValue ?: tweak.defaultValue;
}

@end
