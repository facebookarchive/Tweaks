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

/**
 @abstract The keys of dictionary contained in the tweak.
 @discussion Array containing string values for each of the keys in the dictionary.
 */
@property (nonatomic, copy, readonly) NSArray *allKeys;

/**
 @abstract The dictionary contained by the tweak.
 @discussion The current and default values of the tweak represent a key in
   this dictionary.
 */
@property (nonatomic, copy, readwrite) NSDictionary *dictionaryValue;

/**
 @abstract Indicates whether the tweak instance represents a dictionary tweak.
 @return YES if the instance represents a dictionary tweak.
 */
- (BOOL)isDictionary;

@end


/**
 @abstract Loads a dictionary tweak defined inline.
 @return A {@ref FBTweak} for the dictionary tweak.
 */
FBTweak* FBDictionaryTweak(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, NSString *defaultKey);

/**
 @abstract Loads the key of a dictionary tweak inine.
 @param dictionary A dictionary with string values for keys.
 @return The current string key for the tweak, or the default key if none is set.
 */
NSString* FBDictionaryTweakValue(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, NSString *defaultKey);

/**
 @abstract Loads the dictionary's value associated with the key of a dictionary tweak inine.
 @return The dictionary's value associated with the key for the tweak. If the current key is nil,
   the value associated with the default key will be returned.
 */
FBTweakValue FBDictionaryTweakValueForKey(NSString *categoryName, NSString *collectionName, NSString *tweakName, NSDictionary *dictionary, NSString *defaultKey);