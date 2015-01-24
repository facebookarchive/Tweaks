//
//  FBTweak+Array.h
//  FBTweak
//
//  Created by John McIntosh on 11/11/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "FBTweak.h"


/**
 Implementation works by storing the array in the tweak's `stepValue`. The values of the array are
 exposed through the Tweaks UI through the value's `description`. 
 */
@interface FBTweak (Array)

/**
 @abstract The array contained by the tweak.
 @discussion The current and default values of the tweak contain an item in this array.
 */
@property (nonatomic, copy, readwrite) NSArray *arrayValue;

/**
 @abstract Indicates whether the tweak instance represents an array tweak.
 @return YES if the instance represents an array tweak.
 */
- (BOOL)isArray;

@end


/**
 @abstract Loads an array tweak defined inline.
 @return A {@ref FBTweak} for the array tweak.
 */
FBTweak* FBArrayTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSArray *array, id defaultValue);

/**
 @abstract Loads the array's value of an array tweak inine.
 @return The array's value of the tweak. If the current value is nil, the default value will be 
   returned.
 */
FBTweakValue FBArrayTweakValue(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSArray *array, id defaultValue);