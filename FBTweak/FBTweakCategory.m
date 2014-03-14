/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakCategory.h"
#import "FBTweakCollection.h"

@implementation FBTweakCategory {
  NSMutableArray *_orderedCollections;
  NSMutableDictionary *_namedCollections;
}

- (instancetype)initWithName:(NSString *)name
{
  if ((self = [super init])) {
    _name = [name copy];
    
    _orderedCollections = [[NSMutableArray alloc] initWithCapacity:4];
    _namedCollections = [[NSMutableDictionary alloc] initWithCapacity:4];
  }
  
  return self;
}

- (FBTweakCollection *)tweakCollectionWithName:(NSString *)name
{
  return _namedCollections[name];
}

- (NSArray *)tweakCollections
{
  return [_orderedCollections copy];
}

- (void)addTweakCollection:(FBTweakCollection *)tweakCollection
{
  [_orderedCollections addObject:tweakCollection];
  [_namedCollections setObject:tweakCollection forKey:tweakCollection.name];
}

- (void)removeTweakCollection:(FBTweakCollection *)tweakCollection
{
  [_orderedCollections removeObject:tweakCollection];
  [_namedCollections removeObjectForKey:tweakCollection.name];
}

@end
