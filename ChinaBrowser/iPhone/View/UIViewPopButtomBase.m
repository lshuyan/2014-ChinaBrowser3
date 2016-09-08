//
//  UIViewPopButtomBase.m
//  ChinaBrowser
//
//  Created by David on 14/11/7.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewPopButtomBase.h"

@implementation UIViewPopButtomBase
{
    BOOL _animating;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_animating) {
        return;
    }
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_viewContent.frame, touchPoint)) {
        [self dismissWithCompletion:nil];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // 默认清空标题
    _labelTitle.text = nil;
    
    [_btnRight addTarget:self action:@selector(onTouchOk) forControlEvents:UIControlEventTouchUpInside];
    [_btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRight setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateHighlighted];
    [_btnRight setTitle:LocalizedString(@"queding") forState:UIControlStateNormal];
    
    CGRect rc = _btnRight.frame;
    rc.size.width = self.width-_btnRight.left;
    _btnRight.frame = rc;
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    
    _viewContent.backgroundColor = [UIColor whiteColor];
    _viewTop.backgroundColor = [UIColor colorWithRed:0.173 green:0.694 blue:1.000 alpha:1.000];
    _viewBottom.backgroundColor = [UIColor clearColor];
}

+ (instancetype)viewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
}

- (void)showInView:(UIView *)view completion:(void (^)())completion
{
    self.frame = view.bounds;
    CGRect rc = _viewContent.frame;
    rc.origin.x = 0;
    rc.origin.y = self.height-_viewContent.height;
    rc.size.width = self.width;
    _viewContent.frame = rc;
    
    _viewContent.transform = CGAffineTransformMakeTranslation(0, _viewContent.height);
    self.backgroundColor = [UIColor clearColor];
    [view addSubview:self];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _viewContent.transform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
    
}

- (void)dismissWithCompletion:(void (^)())completion
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _viewContent.transform = CGAffineTransformMakeTranslation(0, _viewContent.height);
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        
        [self removeFromSuperview];
    }];
}

- (void)onTouchOk
{
    
}

@end
