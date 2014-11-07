//
//  FBTweak+Dictionary.h
//  FBTweak
//
//  Created by John McIntosh on 11/5/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweak.h"

/**
 Implementation works by storing the dictionary in the tweak's `stepValue`.
 */
@interface FBTweak (Dictionary)

@property (nonatomic, copy, readonly) NSArray *allKeys;
@property (nonatomic, copy, readonly) NSArray *allValues;
@property (nonatomic, copy, readwrite) NSDictionary *dictionaryValue;

- (BOOL)isDictionary;

@end

FBTweak* FBDictionaryTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, id defaultKey);
FBTweakValue FBDictionaryTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, id defaultKey);