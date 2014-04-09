/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorWheelView.h"

static void HSL2RGB(float hue, float saturation, float brightness, float* outR, float* outG, float* outB)
{
  int r = 0, g = 0, b = 0;
  if (saturation == 0) {
    r = g = b = (int) (brightness * 255.0f + 0.5f);
  } else {
    float h = (hue - (float)floorf(hue)) * 6.0f;
    float f = h - (float)floorf(h);
    float p = brightness * (1.0f - saturation);
    float q = brightness * (1.0f - saturation * f);
    float t = brightness * (1.0f - (saturation * (1.0f - f)));
    switch ((int) h) {
      case 0:
        r = (int) (brightness * 255.0f + 0.5f);
        g = (int) (t * 255.0f + 0.5f);
        b = (int) (p * 255.0f + 0.5f);
        break;
      case 1:
        r = (int) (q * 255.0f + 0.5f);
        g = (int) (brightness * 255.0f + 0.5f);
        b = (int) (p * 255.0f + 0.5f);
        break;
      case 2:
        r = (int) (p * 255.0f + 0.5f);
        g = (int) (brightness * 255.0f + 0.5f);
        b = (int) (t * 255.0f + 0.5f);
        break;
      case 3:
        r = (int) (p * 255.0f + 0.5f);
        g = (int) (q * 255.0f + 0.5f);
        b = (int) (brightness * 255.0f + 0.5f);
        break;
      case 4:
        r = (int) (t * 255.0f + 0.5f);
        g = (int) (p * 255.0f + 0.5f);
        b = (int) (brightness * 255.0f + 0.5f);
        break;
      case 5:
        r = (int) (brightness * 255.0f + 0.5f);
        g = (int) (p * 255.0f + 0.5f);
        b = (int) (q * 255.0f + 0.5f);
        break;
    }
  }
  *outR = r / 255.0f;
  *outG = g / 255.0f;
  *outB = b / 255.0f;
}

@interface FBColorWheelView ()

@property(nonatomic, assign) CGFloat brightness;
@property(nonatomic, assign) CGFloat hue;
@property(nonatomic, assign) CGFloat saturation;
@property(nonatomic, strong) CALayer* indicatorLayer;

@end

@implementation FBColorWheelView

- (instancetype)initWithFrame:(CGRect)frame
{
  NSParameterAssert(CGRectGetWidth(frame) == CGRectGetHeight(frame));
  self = [super initWithFrame:frame];
  if (self) {
    _hue = 0.0f;
    _saturation = 0.0f;
    _brightness = 1.0f;
    CGFloat dimension = CGRectGetWidth(self.bounds); // should always be square.
    CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
    CFDataSetLength(bitmapData, dimension * dimension * 4);
    [self colorWheelBitmap:CFDataGetMutableBytePtr(bitmapData) withSize:CGSizeMake(dimension, dimension)];
    CGImageRef img = [self imageWithRGBAData:bitmapData width:dimension height:dimension];
    self.layer.contents = (__bridge_transfer id)img;
    CFRelease(bitmapData);

    [self.layer addSublayer:[self indicatorLayer]];

    [self setSelectedPoint:CGPointMake(dimension / 2, dimension / 2)];
  }
  return self;
}

- (CALayer*)indicatorLayer
{
  if (!_indicatorLayer) {
    CGFloat dimension = 33;
    UIColor *edgeColor = [UIColor colorWithWhite:0.9 alpha:0.8];
    _indicatorLayer = [CALayer layer];
    _indicatorLayer.cornerRadius = dimension / 2;
    _indicatorLayer.borderColor = edgeColor.CGColor;
    _indicatorLayer.borderWidth = 2;
    _indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _indicatorLayer.bounds = CGRectMake(0, 0, dimension, dimension);
    _indicatorLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    _indicatorLayer.shadowColor = [UIColor blackColor].CGColor;
    _indicatorLayer.shadowOffset = CGSizeZero;
    _indicatorLayer.shadowRadius = 1;
    _indicatorLayer.shadowOpacity = 0.5f;
  }
  return _indicatorLayer;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self onTouchEventWithPosition:position];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self onTouchEventWithPosition:position];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self onTouchEventWithPosition:position];
}

- (void)onTouchEventWithPosition:(CGPoint)point {
  CGFloat radius = CGRectGetWidth(self.bounds) / 2;
  CGFloat dist = sqrtf((radius - point.x) * (radius - point.x) + (radius - point.y) * (radius - point.y));

  if (dist <= radius) {
    [self setSelectedPoint:point];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (void)setSelectedPoint:(CGPoint)point
{
  [self colorWheelValueWithPosition:point hue:&_hue saturation:&_saturation];
  UIColor* selectedColor = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1.0f];
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  self.indicatorLayer.position = point;
  self.indicatorLayer.backgroundColor = selectedColor.CGColor;
  [CATransaction commit];
}

- (void)colorWheelBitmap:(out UInt8 *)bitmap withSize:(CGSize)size
{
  for (int y = 0; y < size.width; y++) {
    for (int x = 0; x < size.height; x++) {
      float h, s, r, g, b, a;
      [self colorWheelValueWithPosition:CGPointMake(x, y) hue:&h saturation:&s];
      if (s < 1.0) {
        // Antialias the edge of the circle.
        if (s > 0.99) a = (1.0 - s) * 100;
        else a = 1.0;

        HSL2RGB(h, s, _brightness, &r, &g, &b);
      } else {
        r = g = b = a = 0.0f;
      }

      int i = 4 * (x + y * size.width);
      bitmap[i] = r * 0xff;
      bitmap[i+1] = g * 0xff;
      bitmap[i+2] = b * 0xff;
      bitmap[i+3] = a * 0xff;
    }
  }
}

- (void)colorWheelValueWithPosition:(CGPoint)position hue:(out CGFloat*)hue saturation:(out CGFloat*)saturation
{
  int c = CGRectGetWidth(self.bounds) / 2;
  float dx = (float)(position.x - c) / c;
  float dy = (float)(position.y - c) / c;
  float d = sqrtf((float)(dx*dx + dy*dy));
  *saturation = d;
  if (d == 0) {
    hue = 0;
  } else {
    *hue = acosf((float)dx / d) / M_PI / 2.0f;
    if (dy < 0) *hue = 1.0 - *hue;
  }
}

- (CGImageRef)imageWithRGBAData:(CFDataRef)data width:(NSUInteger)width  height:(NSUInteger)height
{
  CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  CGColorSpaceRelease(colorSpace);
  return imageRef;
}

@end
