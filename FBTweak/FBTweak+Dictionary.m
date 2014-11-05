//
//  FBTweak+Dictionary.m
//  FBTweak
//
//  Created by John McIntosh on 11/5/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweak+Dictionary.h"
#import "FBTweakStore.h"
#import "FBTweakCollection.h"
#import "FBTweakCategory.h"

@implementation FBTweak (Dictionary)

- (BOOL)isDictionary {
  return (self.dictionaryValue != nil);
}

- (NSDictionary *)dictionaryValue {
  if ([self.stepValue isKindOfClass:[NSDictionary class]]) {
    return self.stepValue;
  }
  return nil;
}

- (void)setDictionaryValue:(NSDictionary *)dictionaryValue {
  self.stepValue = dictionaryValue;
}

- (NSArray *)allKeys {
  return self.dictionaryValue.allKeys;
}

- (NSArray *)allValues {
  return self.dictionaryValue.allValues;
}

FBTweakValue FBDictionaryTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, id defaultKey)
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
  
  return tweak.currentValue ?: tweak.defaultValue;
}

@end
