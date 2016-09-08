//
//  UIViewPopSetBrightness.m
//  ChinaBrowser
//
//  Created by David on 14/11/14.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewPopSetBrightness.h"

@implementation UIViewPopSetBrightness
{
    __weak IBOutlet UISlider *_slideBrightness;
    __weak IBOutlet UIImageView *_imageViewMin;
    __weak IBOutlet UIImageView *_imageViewMax;
    
    CGFloat _brightnessOld;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _imageViewMin.image = [UIImage imageWithBundleFile:@"iPhone/Settings/Brightness/light_little.png"];
    _imageViewMax.image = [UIImage imageWithBundleFile:@"iPhone/Settings/Brightness/light_more.png"];
    
    _brightnessOld = [AppSetting shareAppSetting].brightness;
    _slideBrightness.value = _brightnessOld;
}

- (void)onTouchOk
{
    _brightnessOld = _slideBrightness.value;
    [AppSetting shareAppSetting].brightness = _slideBrightness.value;
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)())completion
{
    // 没有还原操作
    [AppSetting shareAppSetting].brightness = _slideBrightness.value;
    
    /*
    // 带有还原操作，点击其他地方还原到原始设置
    [UIView animateWithDuration:0.5 animations:^{
        [BrightnessUtil shareBrightnessUtil].brightness = _brightnessOld;
    }];
     */
    [super dismissWithCompletion:completion];
}

- (IBAction)onValueChanged:(UISlider *)sender
{
    [BrightnessUtil shareBrightnessUtil].brightness = _slideBrightness.value;
}

- (IBAction)onTouchUpside:(UISlider *)sender
{
    [BrightnessUtil shareBrightnessUtil].brightness = _slideBrightness.value;
}

@end