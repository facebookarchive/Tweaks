/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBTweakEnabled.h"
#import "FBTweak.h"
#import "FBTweakStore.h"
#import "FBTweakCategory.h"
#import "FBTweakCollection.h"
#import "_FBTweakBindObserver.h"

#if !FB_TWEAK_ENABLED

#define __FBTweakDefault(default, ...) default
#define _FBTweakInline(category_, collection_, name_, ...) nil
#define _FBTweakValue(category_, collection_, name_, ...) (__FBTweakDefault(__VA_ARGS__, _))
#define _FBTweakBind(object_, property_, category_, collection_, name_, ...) (object_.property_ = __FBTweakDefault(__VA_ARGS__, _))

#else

#ifdef __cplusplus
extern "C" {
#endif

#define FBTweakSegmentName "__DATA"
#define FBTweakSectionName "FBTweak"

typedef __unsafe_unretained NSString *FBTweakLiteralString;
  
typedef struct {
  FBTweakLiteralString *category;
  FBTweakLiteralString *collection;
  FBTweakLiteralString *name;
  void *value;
  void *min;
  void *max;
  char **encoding;
} fb_tweak_entry;

extern NSString *_FBTweakIdentifier(fb_tweak_entry *entry);
  
#if __has_feature(objc_arc)
#define _FBTweakRelease(x)
#else
#define _FBTweakRelease(x) [x release]
#endif
  
#define __FBTweakConcat_(X, Y) X ## Y
#define __FBTweakConcat(X, Y) __FBTweakConcat_(X, Y)

#define __FBTweakIndex(_1, _2, _3, value, ...) value
#define __FBTweakIndexCount(...) __FBTweakIndex(__VA_ARGS__, 3, 2, 1)
  
#define __FBTweakHasRange1(__withoutRange, __withRange, ...) __withoutRange
#define __FBTweakHasRange2(__withoutRange, __withRange, ...) __FBTweakInvalidNumberOfArgumentsPassed
#define __FBTweakHasRange3(__withoutRange, __withRange, ...) __withRange
#define _FBTweakHasRange(__withoutRange, __withRange, ...) __FBTweakConcat(__FBTweakHasRange, __FBTweakIndexCount(__VA_ARGS__))(__withoutRange, __withRange)
  
#define _FBTweakInlineWithoutRange(category_, collection_, name_, default_) \
  _FBTweakInlineWithRangeInternal(category_, collection_, name_, default_, NO, NULL, NO, NULL)
#define _FBTweakInlineWithRange(category_, collection_, name_, default_, min_, max_) \
  _FBTweakInlineWithRangeInternal(category_, collection_, name_, default_, YES, min_, YES, max_)
#define _FBTweakInlineWithRangeInternal(category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_) \
((^{ \
  /* store the tweak data in the binary at compile time. */ \
  __attribute__((used)) static FBTweakLiteralString category__ = category_; \
  __attribute__((used)) static FBTweakLiteralString collection__ = collection_; \
  __attribute__((used)) static FBTweakLiteralString name__ = name_; \
  __attribute__((used)) static __typeof__(default_) default__ = default_; \
  __attribute__((used)) static __typeof__(min_) min__ = min_; \
  __attribute__((used)) static __typeof__(max_) max__ = max_; \
  __attribute__((used)) static char *encoding__ = (char *)@encode(__typeof__(default_)); \
  __attribute__((used)) __attribute__((section (FBTweakSegmentName "," FBTweakSectionName))) static fb_tweak_entry entry = \
    { &category__, &collection__, &name__, &default__, hasmin_ ? &min__ : NULL, hasmax_ ? &max__ : NULL, &encoding__ }; \
\
  /* find the registered tweak with the given identifier. */ \
  FBTweakStore *store = [FBTweakStore sharedInstance]; \
  FBTweakCategory *category = [store tweakCategoryWithName:*entry.category]; \
  FBTweakCollection *collection = [category tweakCollectionWithName:*entry.collection]; \
\
  NSString *identifier = _FBTweakIdentifier(&entry); \
  FBTweak *tweak = [collection tweakWithIdentifier:identifier]; \
\
  return tweak; \
})())
#define _FBTweakInline(category_, collection_, name_, ...) _FBTweakHasRange(_FBTweakInlineWithoutRange, _FBTweakInlineWithRange, __VA_ARGS__)(category_, collection_, name_, __VA_ARGS__)
  
#define _FBTweakValueInternal(tweak_, category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_) \
((^{ \
  /* returns a correctly typed version of the current tweak value */ \
  FBTweakValue currentValue = tweak_.currentValue ?: tweak_.defaultValue; \
  return _Generic(default_, \
    float: [currentValue floatValue], \
    double: [currentValue doubleValue], \
    NSInteger: [currentValue integerValue], \
    NSUInteger: [currentValue unsignedIntegerValue], \
    BOOL: [currentValue boolValue], \
    id: currentValue, \
    /* assume char * as the default. */ \
    /* constant strings are typed as char[N] */ \
    /* and we can't enumerate all of those. */ \
    /* luckily, we only need one fallback */ \
    default: [currentValue UTF8String] \
  ); \
})())

#define _FBTweakValueWithoutRange(category_, collection_, name_, default_) _FBTweakValueWithRangeInternal(category_, collection_, name_, default_, NO, NULL, NO, NULL)
#define _FBTweakValueWithRange(category_, collection_, name_, default_, min_, max_) _FBTweakValueWithRangeInternal(category_, collection_, name_, default_, YES, min_, YES, max_)
#define _FBTweakValueWithRangeInternal(category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_) \
((^{ \
  FBTweak *tweak = _FBTweakInlineWithRangeInternal(category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_); \
  return _FBTweakValueInternal(tweak, category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_); \
})())
#define _FBTweakValue(category_, collection_, name_, ...) _FBTweakHasRange(_FBTweakValueWithoutRange, _FBTweakValueWithRange, __VA_ARGS__)(category_, collection_, name_, __VA_ARGS__)

#define _FBTweakBindWithoutRange(object_, property_, category_, collection_, name_, default_) \
  _FBTweakBindWithRangeInternal(object_, property_, category_, collection_, name_, default_, NO, NULL, NO, NULL)
#define _FBTweakBindWithRange(object_, property_, category_, collection_, name_, default_, min_, max_) \
  _FBTweakBindWithRangeInternal(object_, property_, category_, collection_, name_, default_, YES, min_, YES, max_)
#define _FBTweakBindWithRangeInternal(object_, property_, category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_) \
((^{ \
  FBTweak *tweak = _FBTweakInlineWithRangeInternal(category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_); \
  object_.property_ = _FBTweakValueInternal(tweak, category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_); \
\
  _FBTweakBindObserver *observer__ = [[_FBTweakBindObserver alloc] initWithTweak:tweak block:^(id object__) { \
    __typeof__(object_) object___ = object__; \
    object___.property_ = _FBTweakValueInternal(tweak, category_, collection_, name_, default_, hasmin_, min_, hasmax_, max_); \
  }]; \
  [observer__ attachToObject:object_]; \
})())
#define _FBTweakBind(object_, property_, category_, collection_, name_, ...) _FBTweakHasRange(_FBTweakBindWithoutRange, _FBTweakBindWithRange, __VA_ARGS__)(object_, property_, category_, collection_, name_, __VA_ARGS__)
  
#ifdef __cplusplus
}
#endif

#endif

