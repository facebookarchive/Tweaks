/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorWheelView.h"
#import "_FBColorUtils.h"

static void _FBColorWheelValue(CGPoint position, CGFloat radius, CGFloat *hue, CGFloat* saturation){
  float dx = (float)(position.x - radius) / radius;
  float dy = (float)(position.y - radius) / radius;
  float d = sqrtf((float)(dx*dx + dy*dy));
  *saturation = d;
  if (d == 0) {
    *hue = 0;
  } else {
    *hue = acosf((float)dx / d) / M_PI / 2.0f;
    if (dy < 0) *hue = 1.0 - *hue;
  }
}

static CGImageRef _FBCreateColorWheelImage(CGRect bounds) {
  CGFloat dimension = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds));
  CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
  CFDataSetLength(bitmapData, dimension * dimension * 4);
  UInt8 * bitmap = CFDataGetMutableBytePtr(bitmapData);
  for (int y = 0; y < dimension; y++) {
    for (int x = 0; x < dimension; x++) {
      CGFloat hue, saturation, a = 0.0f;
      _FBColorWheelValue(CGPointMake(x, y), dimension / 2, &hue, &saturation);
      RGB rgb = {0.0f, 0.0f, 0.0f, 0.0f};
      if (saturation < 1.0) {
        // Antialias the edge of the circle.
        if (saturation > 0.99) a = (1.0 - saturation) * 100;
        else a = 1.0;
        HSB hsb = {hue, saturation, 1.0f, a};
        rgb = _FBHSB2RGB(hsb);
      }

      int i = 4 * (x + y * dimension);
      bitmap[i] = rgb.red * 0xff;
      bitmap[i+1] = rgb.green * 0xff;
      bitmap[i+2] = rgb.blue * 0xff;
      bitmap[i+3] = rgb.alpha * 0xff;
    }
  }

  CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(bitmapData);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGImageRef imageRef = CGImageCreate(dimension, dimension, 8, 32, dimension * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
  CGDataProviderRelease(dataProvider);
  CGColorSpaceRelease(colorSpace);
  CFRelease(bitmapData);
  return imageRef;
}

@implementation _FBColorWheelView {
  CALayer *_indicatorLayer;
  CGFloat _hue;
  CGFloat _saturation;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _hue = 0.0f;
    _saturation = 0.0f;

    _indicatorLayer = [self _createIndicatorLayer];
    [self.layer addSublayer:_indicatorLayer];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];
  }
  return self;
}

- (void)setHue:(CGFloat)hue
{
  _hue = hue;
  [self _setSelectedPoint:[self _selectedPoint]];
  [self setNeedsDisplay];
}

- (void)setSaturation:(CGFloat)saturation
{
  _saturation = saturation;
  [self _setSelectedPoint:[self _selectedPoint]];
  [self setNeedsDisplay];
}

#pragma mark - CALayerDelegate methods

- (void)displayLayer:(CALayer *)layer
{
  self.layer.contents = (__bridge_transfer id)_FBCreateColorWheelImage(self.bounds);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
  if (layer == self.layer) {
    [self _setSelectedPoint:[self _selectedPoint]];
    [self.layer setNeedsDisplay];
  }
}

#pragma mark - Private methods

- (CALayer*)_createIndicatorLayer
{
  CGFloat dimension = 33;
  UIColor *edgeColor = [UIColor colorWithWhite:0.9 alpha:0.8];
  CALayer* indicatorLayer = [CALayer layer];
  indicatorLayer.cornerRadius = dimension / 2;
  indicatorLayer.borderColor = edgeColor.CGColor;
  indicatorLayer.borderWidth = 2;
  indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
  indicatorLayer.bounds = CGRectMake(0, 0, dimension, dimension);
  indicatorLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
  indicatorLayer.shadowColor = [UIColor blackColor].CGColor;
  indicatorLayer.shadowOffset = CGSizeZero;
  indicatorLayer.shadowRadius = 1;
  indicatorLayer.shadowOpacity = 0.5f;
  return indicatorLayer;
}

- (void)_handlePanGesture:(UIPanGestureRecognizer*)panGestureRecognizer
{
  CGPoint position = [panGestureRecognizer locationInView:self];
  CGFloat radius = CGRectGetWidth(self.bounds) / 2;
  CGFloat dist = sqrtf((radius - position.x) * (radius - position.x) + (radius - position.y) * (radius - position.y));

  if (dist <= radius) {
    _FBColorWheelValue(position, radius, &_hue, &_saturation);
    [self _setSelectedPoint:position];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
  }
}

- (void)_setSelectedPoint:(CGPoint)point
{
  UIColor *selectedColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:1.0f alpha:1.0f];
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  _indicatorLayer.position = point;
  _indicatorLayer.backgroundColor = selectedColor.CGColor;
  [CATransaction commit];
}

- (CGPoint)_selectedPoint
{
  CGFloat dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
  CGFloat radius = _saturation * dimension / 2;
  CGFloat x = dimension / 2 + radius * cosf(_hue * M_PI * 2.0f);
  CGFloat y = dimension / 2 + radius * sinf(_hue * M_PI * 2.0f);
  return CGPointMake(x, y);
}

@end
