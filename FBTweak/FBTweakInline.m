/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakInline.h"
#import "FBTweak.h"
#import "FBTweakInlineInternal.h"
#import "FBTweakCollection.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"

#import <libkern/OSAtomic.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>

#if FB_TWEAK_ENABLED

extern NSString *_FBTweakIdentifier(fb_tweak_entry *entry)
{
  return [NSString stringWithFormat:@"FBTweak:%@-%@-%@", *entry->category, *entry->collection, *entry->name];
}

static FBTweak *_FBTweakCreateWithEntry(NSString *identifier, fb_tweak_entry *entry)
{
  FBTweak *tweak = [[FBTweak alloc] initWithIdentifier:identifier];
  tweak.name = *entry->name;

  if (entry->possible != NULL) {
    tweak.possibleValues = fb_tweak_entry_block_field(id, entry, possible);
  }

  if (strcmp(*entry->encoding, FBTweakEncodingAction) == 0) {
    tweak.defaultValue = *(__strong dispatch_block_t *)entry->value;
  } else if (strcmp(*entry->encoding, @encode(BOOL)) == 0) {
    tweak.defaultValue = @(fb_tweak_entry_block_field(BOOL, entry, value));
  } else if (strcmp(*entry->encoding, @encode(float)) == 0) {
    tweak.defaultValue = [NSNumber numberWithFloat:fb_tweak_entry_block_field(float, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(double)) == 0) {
    tweak.defaultValue = [NSNumber numberWithDouble:fb_tweak_entry_block_field(double, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(short)) == 0) {
    tweak.defaultValue = [NSNumber numberWithShort:fb_tweak_entry_block_field(short, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(unsigned short)) == 0) {
    tweak.defaultValue = [NSNumber numberWithUnsignedShort:fb_tweak_entry_block_field(unsigned short, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(int)) == 0) {
    tweak.defaultValue = [NSNumber numberWithInt:fb_tweak_entry_block_field(int, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(unsigned int)) == 0) {
    tweak.defaultValue = [NSNumber numberWithUnsignedInt:fb_tweak_entry_block_field(unsigned int, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(long long)) == 0) {
    tweak.defaultValue = [NSNumber numberWithLongLong:fb_tweak_entry_block_field(long long, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(unsigned long long)) == 0) {
    tweak.defaultValue = [NSNumber numberWithUnsignedLongLong:fb_tweak_entry_block_field(unsigned long long, entry, value)];
  } else if (*entry->encoding[0] == '[') {
    // Assume it's a C string.
    tweak.defaultValue = [NSString stringWithUTF8String:fb_tweak_entry_block_field(char *, entry, value)];
  } else if (strcmp(*entry->encoding, @encode(id)) == 0) {
    tweak.defaultValue = fb_tweak_entry_block_field(id, entry, value);
  } else {
    NSCAssert(NO, @"Unknown encoding %s for tweak %@. Value was %p.", *entry->encoding, _FBTweakIdentifier(entry), entry->value);
    tweak = nil;
  }
  
  return tweak;
}

@interface _FBTweakInlineLoader : NSObject
@end

@implementation _FBTweakInlineLoader

+ (void)load
{
  static uint32_t _tweaksLoaded = 0;
  if (OSAtomicTestAndSetBarrier(1, &_tweaksLoaded)) {
    return;
  }
  
#ifdef __LP64__
  typedef uint64_t fb_tweak_value;
  typedef struct section_64 fb_tweak_section;
#define fb_tweak_getsectbynamefromheader getsectbynamefromheader_64
#else
  typedef uint32_t fb_tweak_value;
  typedef struct section fb_tweak_section;
#define fb_tweak_getsectbynamefromheader getsectbynamefromheader
#endif
  
  FBTweakStore *store = [FBTweakStore sharedInstance];
  
  Dl_info info;
  dladdr(&_FBTweakIdentifier, &info);
  
  const fb_tweak_value mach_header = (fb_tweak_value)info.dli_fbase;
  const fb_tweak_section *section = fb_tweak_getsectbynamefromheader((void *)mach_header, FBTweakSegmentName, FBTweakSectionName);
  
  if (section == NULL) {
    return;
  }
  
  for (fb_tweak_value addr = section->offset; addr < section->offset + section->size; addr += sizeof(fb_tweak_entry)) {
    fb_tweak_entry *entry = (fb_tweak_entry *)(mach_header + addr);
    
    FBTweakCategory *category = [store tweakCategoryWithName:*entry->category];
    if (category == nil) {
      category = [[FBTweakCategory alloc] initWithName:*entry->category];
      [store addTweakCategory:category];
    }
    
    FBTweakCollection *collection = [category tweakCollectionWithName:*entry->collection];
    if (collection == nil) {
      collection = [[FBTweakCollection alloc] initWithName:*entry->collection];
      [category addTweakCollection:collection];
    }
    
    NSString *identifier = _FBTweakIdentifier(entry);
    if ([collection tweakWithIdentifier:identifier] == nil) {
      FBTweak *tweak = _FBTweakCreateWithEntry(identifier, entry);

      if (tweak != nil) {
        [collection addTweak:tweak];
      }
    }
  }
}

@end

#endif
