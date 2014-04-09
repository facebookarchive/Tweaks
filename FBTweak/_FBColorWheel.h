//
//  ColorWheel.h
//  VBColorPicker
//
//  Created by Maksym Shcheglov on 06/04/14.
//  Copyright (c) 2014 www.injoit.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface FBColorWheel : UIControl

@property(nonatomic, readonly, assign) CGFloat luminance;
@property(nonatomic, readonly, assign) CGFloat hue;
@property(nonatomic, readonly, assign) CGFloat saturation;
@property(nonatomic, readonly, strong) CALayer* indicatorLayer;

@end

