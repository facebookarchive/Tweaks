//
//  FBColorWheel.m
//  FBTweak
//
//  Created by Maksym Shcheglov on 09/04/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "_FBColorWheel.h"

@interface FBColorWheel ()

@property(nonatomic, assign) CGFloat luminance;
@property(nonatomic, assign) CGFloat hue;
@property(nonatomic, assign) CGFloat saturation;
@property(nonatomic, strong) CALayer* indicatorLayer;

@end


@implementation FBColorWheel

- (instancetype)initWithFrame:(CGRect)frame
{
    NSParameterAssert(CGRectGetWidth(frame) == CGRectGetHeight(frame));
    self = [super initWithFrame:frame];
    if (self) {
        _luminance = 1.0f;
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

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.indicatorLayer.position = point;
    self.indicatorLayer.backgroundColor = [self selectedColor].CGColor;
    [CATransaction commit];
}

//- (UIColor*)selectedColor
//{
//    float r, g, b, a;
//    if (self.saturation < 1.0) {
//        // Antialias the edge of the circle.
//        if (self.saturation > 0.99) a = (1.0 - self.saturation) * 100;
//        else a = 1.0;
//        HSL2RGB(self.hue, self.saturation, self.luminance, &r, &g, &b);
//    } else {
//        r = g = b = a = 0.0f;
//    }
//    return [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
//}

- (UIColor*)selectedColor
{
    CGFloat hue = self.hue;
    CGFloat saturation = self.saturation;
    CGFloat brightness = self.luminance;
    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    if(self.saturation == 0.0)
    {
        CGFloat dimension = CGRectGetWidth(self.bounds);
        CGFloat hue, saturation;
        [self colorWheelValueWithPosition:CGPointMake(dimension / 2, dimension / 2) hue:&hue saturation:&saturation];
    }
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
}

- (void)colorWheelBitmap:(out UInt8 *)bitmap withSize:(CGSize)size
{
    // I think maybe you can do 1/3 of the pie, then do something smart to generate the other two parts, but for now we'll brute force it.
    for (int y = 0; y < size.width; y++) {
        for (int x = 0; x < size.height; x++) {
            float h, s, r, g, b, a;
            [self colorWheelValueWithPosition:CGPointMake(x, y) hue:&h saturation:&s];
            if (s < 1.0) {
                // Antialias the edge of the circle.
                if (s > 0.99) a = (1.0 - s) * 100;
                else a = 1.0;

                HSL2RGB(h, s, _luminance, &r, &g, &b);
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
    *hue = acosf((float)dx / d) / M_PI / 2.0f;
    if (dy < 0) *hue = 1.0 - *hue;
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

void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
    //    float temp1, temp2;
    //    float temp[3];
    //    int i;
    //
    //    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    //    if(s == 0.0)
    //    {
    //        *outR = l;
    //        *outG = l;
    //        *outB = l;
    //        return;
    //    }
    //
    //    // Test for luminance and compute temporary values based on luminance and saturation
    //    if(l < 0.5)
    //        temp2 = l * (1.0 + s);
    //    else
    //        temp2 = l + s - l * s;
    //    temp1 = 2.0 * l - temp2;
    //
    //    // Compute intermediate values based on hue
    //    temp[0] = h + 1.0 / 3.0;
    //    temp[1] = h;
    //    temp[2] = h - 1.0 / 3.0;
    //
    //    for(i = 0; i < 3; ++i)
    //    {
    //        // Adjust the range
    //        if(temp[i] < 0.0)
    //            temp[i] += 1.0;
    //        if(temp[i] > 1.0)
    //            temp[i] -= 1.0;
    //
    //
    //        if(6.0 * temp[i] < 1.0)
    //            temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
    //        else {
    //            if(2.0 * temp[i] < 1.0)
    //                temp[i] = temp2;
    //            else {
    //                if(3.0 * temp[i] < 2.0)
    //                    temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
    //                else
    //                    temp[i] = temp1;
    //            }
    //        }
    //    }
    //
    //    // Assign temporary values to R, G, B
    //    *outR = temp[0];
    //    *outG = temp[1];
    //    *outB = temp[2];
    int i = floorf(h * 6);
    float f = h * 6 - i;
    float p = l * (1 - s);
    float q = l * (1 - f * s);
    float t = l * (1 - (1 - f) * s);

    float r, g, b;
    switch(i % 6){
        case 0: r = l, g = t, b = p; break;
        case 1: r = q, g = l, b = p; break;
        case 2: r = p, g = l, b = t; break;
        case 3: r = p, g = q, b = l; break;
        case 4: r = t, g = p, b = l; break;
        case 5: r = l, g = p, b = q; break;
    }
    *outR = r;
    *outG = g;
    *outB = b;
}

@end
