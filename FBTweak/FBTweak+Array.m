//
//  FBTweak+Array.m
//  FBTweak
//
//  Created by John McIntosh on 11/11/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweak+Array.h"
#import "FBTweakStore.h"
#import "FBTweakCollection.h"
#import "FBTweakCategory.h"

@implementation FBTweak (Array)

- (BOOL)isArray {
  return (self.arrayValue != nil);
}

- (NSArray *)arrayValue {
  if ([self.stepValue isKindOfClass:[NSArray class]]) {
    return self.stepValue;
  }
  return nil;
}

- (void)setArrayValue:(NSArray *)arrayValue {
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
