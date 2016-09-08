//
//  RotateUtil.m
//  ChinaBrowser
//
//  Created by David on 14-8-30.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "RotateUtil.h"

#import "BlockUI.h"

static RotateUtil *rotateUtil;

@interface RotateUtil ()

@property (nonatomic, assign) BOOL storeLock;
@property (nonatomic, assign) BOOL storeShouldShow;

@end

@implementation RotateUtil
{
    UIButton *_btnLock;
    /**
     *  处理锁屏按钮消失动画过程中又让其显示出现 而产生的问题
     */
    BOOL _isShowLockBtn;
}

+ (instancetype)shareRotateUtil
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rotateUtil = [[RotateUtil alloc] init];
    });
    return rotateUtil;
}

- (instancetype)init
{
    self = [super init];
    {
        [self _init];
    }
    return self;
}

- (void)didRotateNotification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    UIDeviceOrientation interfaceOrientation = (UIDeviceOrientation)[self interfaceOrientation];
    
    
    if (UIDeviceOrientationUnknown != deviceOrientation
        && UIDeviceOrientationFaceUp != deviceOrientation
        && UIDeviceOrientationFaceDown != deviceOrientation
        && UIDeviceOrientationPortraitUpsideDown != deviceOrientation) {
        
        if (deviceOrientation!=interfaceOrientation) {
            if (!_rotateLock) {
                _interfaceOrientation = (UIInterfaceOrientation)deviceOrientation;
            }
            
            if (_shouldShowRotateLock) {
                [self showLock];
            }
        }
    }
}

- (void)_init
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotateNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    _shouldShowRotateLock = YES;
}

- (UIInterfaceOrientationMask)interfaceOrientationMask
{
    return 1 << _interfaceOrientation;
}

- (void)showLock
{
//    return;
    _isShowLockBtn = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect rc = CGRectMake(0, 0, 50, 50);
        _btnLock = [[UIButton alloc] initWithFrame:rc];
        _btnLock.clipsToBounds = YES;
        _btnLock.alpha = 0;
        _btnLock.backgroundColor = [UIColor clearColor];
        _btnLock.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = _btnLock.bounds;
        layer.contentsScale = 1;
        layer.path = [UIBezierPath bezierPathWithRoundedRect:layer.bounds cornerRadius:8].CGPath;
        _btnLock.layer.mask = layer;
        
        [_btnLock handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            self.rotateLock = !_rotateLock;
            if (_rotateLock) {
                [_btnLock setImage:[UIImage imageWithBundleFile:@"Share/screen_unlock.png"] forState:UIControlStateNormal];
            }
            else {
                [_btnLock setImage:[UIImage imageWithBundleFile:@"Share/screen_lock.png"] forState:UIControlStateNormal];
            }
            
            [AppSetting shareAppSetting].rotateScreen = !_rotateLock;
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissLock) object:nil];
            [self performSelector:@selector(dismissLock) withObject:nil afterDelay:2];
        }];
        
        
    });
    
    if (!_btnLock.superview) {
        CGRect rc = _btnLock.frame;
        UIView *rootView = [[UIApplication sharedApplication].windows[0] rootViewController].view;
        rc.origin.x = (rootView.width-rc.size.width)*0.5;
        rc.origin.y = (rootView.height-rc.size.height)-50;
        _btnLock.frame = rc;
        [rootView addSubview:_btnLock];
    }
    
    if (_rotateLock) {
        [_btnLock setImage:[UIImage imageWithBundleFile:@"Share/screen_unlock.png"] forState:UIControlStateNormal];
    }
    else {
        [_btnLock setImage:[UIImage imageWithBundleFile:@"Share/screen_lock.png"] forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _btnLock.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(dismissLock) withObject:nil afterDelay:2];
}

- (void)dismissLock
{
    _isShowLockBtn = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _btnLock.alpha = 0;
    } completion:^(BOOL finished) {
        if (!_isShowLockBtn) {
            [_btnLock removeFromSuperview];
        }
    }];
}

#pragma mark - + methods
/**
 *  存储当前状态
 */
+ (void)store
{
    [RotateUtil shareRotateUtil].storeLock = [RotateUtil shareRotateUtil].rotateLock;
    [RotateUtil shareRotateUtil].storeShouldShow = [RotateUtil shareRotateUtil].shouldShowRotateLock;
}

/**
 *  恢复已存储的状态
 */
+ (void)restore
{
    [RotateUtil shareRotateUtil].rotateLock = [RotateUtil shareRotateUtil].storeLock;
    [RotateUtil shareRotateUtil].shouldShowRotateLock = [RotateUtil shareRotateUtil].storeShouldShow;
}

@end
