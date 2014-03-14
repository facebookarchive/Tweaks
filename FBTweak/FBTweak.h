/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@protocol FBTweakObserver;

/**
  @abstract Represents a possible value of a tweak.
  @discussion Should be able to be persisted in user defaults.
    For minimum and maximum values, should implement -compare:.
 */
typedef id FBTweakValue;

/**
  @abstract Represents a unqie, named tweak.
  @discussion A tweak contains a persistent, editable value.
 */
@interface FBTweak : NSObject

/**
  @abstract Creates a new tweak model.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
  @abstract This tweak's unique identifier.
  @discussion Used when reading and writing the tweak's value.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
  @abstract The human-readable name of the tweak.
  @discussion Show the name when displaying the tweak.
 */
@property (nonatomic, copy, readwrite) NSString *name;

/**
 @abstract The default value of the tweak.
 @discussion Use this when the current value is unset.
 */
@property (nonatomic, strong, readwrite) FBTweakValue defaultValue;

/**
  @abstract The current value of the tweak. Can be nil.
  @discussion Changes to this property will be propagated to disk.
 */
@property (nonatomic, strong, readwrite) FBTweakValue currentValue;

/**
  @abstract The minimum value of the tweak.
  @discussion Optional. If nil, there is no minimum.
 */
@property (nonatomic, strong, readwrite) FBTweakValue minimumValue;

/**
  @abstract The maximum value of the tweak.
  @discussion Optional. If nil, there is no maximum.
 */
@property (nonatomic, strong, readwrite) FBTweakValue maximumValue;

/**
  @abstract Adds an observer to the tweak.
  @param object The observer. Must not be nil.
  @discussion A weak reference is taken on the observer.
 */
- (void)addObserver:(id<FBTweakObserver>)observer;

/**
  @abstract Removes an observer from the tweak.
  @param observer The observer to remove. Must not be nil.
  @discussion Optional, removing an observer isn't required.
 */
- (void)removeObserver:(id<FBTweakObserver>)observer;

@end

/**
  @abstract Responds to updates when a tweak changes.
 */
@protocol FBTweakObserver <NSObject>

/**
  @abstract Called when a tweak's value changes.
  @param tweak The tweak which changed in value.
 */
- (void)tweakDidChange:(FBTweak *)tweak;

@end
