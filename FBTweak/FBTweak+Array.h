//
//  FBTweak+Array.h
//  FBTweak
//
//  Created by John McIntosh on 11/11/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweak.h"


/**
 Implementation works by storing the dictionary in the tweak's `stepValue`.
 */
@interface FBTweak (Array)

@property (nonatomic, copy, readwrite) NSArray *arrayValue;

- (BOOL)isArray;

@end

FBTweak* FBArrayTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSArray *array, id defaultValue);

FBTweakValue FBArrayTweakValue(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSArray *array, id defaultValue);