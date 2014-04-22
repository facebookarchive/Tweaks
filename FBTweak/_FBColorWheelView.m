/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorWheelView.h"

@interface FBColorWheelView () {

  @private

  CALayer* _indicatorLayer;
  HSB _hsb;
}

@end

@implementation FBColorWheelView

+ (BOOL)requiresConstraintBasedLayout
{
  return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _hsb.hue = 0.0f;
    _hsb.saturation = 0.0f;
    _hsb.brightness = 1.0f;

    self.layer.delegate = self;
    [self.layer addSublayer:[self indicatorLayer]];

//    [self setSelectedPoint:CGPointMake(dimension / 2, dimension / 2)];
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
  _hsb = [self colorWheelValueWithPosition:point];
  UIColor* selectedColor = [UIColor colorWithHue:_hsb.hue saturation:_hsb.saturation brightness:_hsb.brightness alpha:1.0f];
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  self.indicatorLayer.position = point;
  self.indicatorLayer.backgroundColor = selectedColor.CGColor;
  [CATransaction commit];
}

#pragma mark - CALayerDelegate methods

- (void)displayLayer:(CALayer *)layer
{
  CGFloat dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
  CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
  CFDataSetLength(bitmapData, dimension * dimension * 4);
  [self colorWheelBitmap:CFDataGetMutableBytePtr(bitmapData) withSize:CGSizeMake(dimension, dimension)];
  id image = [self imageWithRGBAData:bitmapData width:dimension height:dimension];
  CFRelease(bitmapData);
  self.layer.contents = image;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
  if (layer == self.layer) {
    CGFloat dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGFloat radius = _hsb.saturation * dimension / 2;
    CGFloat x = dimension / 2 + radius * cos(_hsb.hue);
    CGFloat y = dimension / 2 + radius * sin(_hsb.hue);
    [self setSelectedPoint:CGPointMake(x, y)];
    [self.layer setNeedsDisplay];
  }
}

#pragma mark - Private methods

- (void)colorWheelBitmap:(out UInt8 *)bitmap withSize:(CGSize)size
{
  for (int y = 0; y < size.width; y++) {
    for (int x = 0; x < size.height; x++) {
      float a = 0.0f;
      HSB hsb = [self colorWheelValueWithPosition:CGPointMake(x, y)];
      RGB rgb = {0.0f, 0.0f, 0.0f};
      if (hsb.saturation < 1.0) {
        // Antialias the edge of the circle.
        if (hsb.saturation > 0.99) a = (1.0 - hsb.saturation) * 100;
        else a = 1.0;

        HSB2RGB(hsb, &rgb);
      }

      int i = 4 * (x + y * size.width);
      bitmap[i] = rgb.red * 0xff;
      bitmap[i+1] = rgb.green * 0xff;
      bitmap[i+2] = rgb.blue * 0xff;
      bitmap[i+3] = a * 0xff;
    }
  }
}

- (HSB)colorWheelValueWithPosition:(CGPoint)position
{
  CGFloat hue, saturation;
  int c = CGRectGetWidth(self.bounds) / 2;
  float dx = (float)(position.x - c) / c;
  float dy = (float)(position.y - c) / c;
  float d = sqrtf((float)(dx*dx + dy*dy));
  saturation = d;
  if (d == 0) {
    hue = 0;
  } else {
    hue = acosf((float)dx / d) / M_PI / 2.0f;
    if (dy < 0) hue = 1.0 - hue;
  }
  HSB hsb = {hue, saturation, _hsb.brightness};
  return hsb;
}

- (id)imageWithRGBAData:(CFDataRef)data width:(NSUInteger)width  height:(NSUInteger)height
{
  CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  CGColorSpaceRelease(colorSpace);
  return (__bridge_transfer id)imageRef;
}

@end
