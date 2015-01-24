/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweak+Dictionary.h"
#import "FBTweakStore.h"
#import "FBTweakCollection.h"
#import "FBTweakCategory.h"

@implementation FBTweak (Dictionary)

- (BOOL)isDictionary
{
  return (self.dictionaryValue != nil);
}

- (NSDictionary *)dictionaryValue
{
  if ([self.stepValue isKindOfClass:[NSDictionary class]]) {
    return self.stepValue;
  }
  return nil;
}

- (void)setDictionaryValue:(NSDictionary *)dictionaryValue
{
  self.stepValue = dictionaryValue;
}

- (NSArray *)allKeys
{
  return self.dictionaryValue.allKeys;
}

FBTweak* FBDictionaryTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, NSString *defaultKey)
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
    tweak.dictionaryValue = dictionary;
    tweak.defaultValue = defaultKey;
    
    [collection addTweak:tweak];
  }
  return tweak;
}

NSString* FBDictionaryTweakValue(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, NSString *defaultKey)
{
  FBTweak *tweak = FBDictionaryTweak(categoryName, collectionName, tweakName, dictionary, defaultKey);
  return tweak.currentValue ?: tweak.defaultValue;
}

FBTweakValue FBDictionaryTweakValueForKey(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, NSString *defaultKey)
{
  FBTweak *tweak = FBDictionaryTweak(categoryName, collectionName, tweakName, dictionary, defaultKey);
  NSString *key = tweak.currentValue ?: tweak.defaultValue;
  return tweak.dictionaryValue[key];
}

@end
