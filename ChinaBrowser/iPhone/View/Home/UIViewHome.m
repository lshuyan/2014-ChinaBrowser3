//
//  UIViewHome.m
//  ChinaBrowser
//
//  Created by David on 14-9-27.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewHome.h"

#import "SMPageControl.h"
#import "UIScrollViewHome.h"

#import "KTAnimationKit.h"

@interface UIViewHome () <UIScrollViewDelegate>

@end

@implementation UIViewHome
{
    IBOutlet SMPageControl *_pageControl;
    IBOutlet UIScrollViewHome *_scrollViewHome;
    
    UIView *_pushedView;
}

#pragma mark - property
- (void)setPageIndex:(NSInteger)pageIndex
{
    [self setPageIndex:pageIndex animated:NO];
}

- (NSInteger)numberOfPages
{
    return _scrollViewHome.subviews.count;
}

#pragma mark - super methods
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _scrollViewHome.frame = _scrollViewHome.frame;
        _pageControl.numberOfPages = _scrollViewHome.subviews.count;
    });
}

- (void)dealloc
{
    
}

- (void)setFrame:(CGRect)frame
{
    _DEBUG_LOG(@"%s", __FUNCTION__);
    [super setFrame:frame];
}

#pragma mark - IBAction
- (IBAction)onPageChanged:(SMPageControl *)pageControl
{
    [_scrollViewHome setContentOffset:CGPointMake(_scrollViewHome.width*pageControl.currentPage, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x/scrollView.width;
    _pageIndex = _pageControl.currentPage;
}

#pragma mark - public method
/**
 *  翻页
 *
 *  @param pageIndex pageIndex description
 *  @param animated  animated description
 */
- (void)setPageIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
    if (pageIndex<_scrollViewHome.subviews.count) {
        _pageIndex = pageIndex;
        _pageControl.currentPage = _pageIndex;
        [_scrollViewHome setContentOffset:CGPointMake(self.width*_pageIndex, 0) animated:animated];
    }
}

- (void)prevPage
{
    if (0==_pageIndex) {
        _pageIndex = _scrollViewHome.subviews.count-1;
    }
    else {
        _pageIndex--;
    }
    [self setPageIndex:_pageIndex animated:YES];
}

- (void)nextPage
{
    if ((_scrollViewHome.subviews.count-1)==_pageIndex) {
        _pageIndex=0;
    }
    else {
        _pageIndex++;
    }
    [self setPageIndex:_pageIndex animated:YES];
}

/**
 *  设置是否可滚动
 *
 *  @param enable BOOL
 */
- (void)setScrollEnable:(BOOL)enable
{
    _pageControl.hidden = !enable;
    _scrollViewHome.scrollEnabled = enable;
}

/**
 *  push 一个View进来
 *
 *  @param view     UIView
 *  @param animated  是否动画
 *  @param completion
 */
- (void)pushView:(UIView *)view animated:(BOOL)animated completion:(void(^)(void))completion;
{
    if (_pushedView) {
        if (completion) {
            completion();
        }
        return;
    }
    _pushedView = view;
    _pushedView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    _pushedView.frame = CGRectOffset(self.bounds, animated?self.width:0, 0);
    [self addSubview:_pushedView];
    
    if (!animated) {
        [_scrollViewHome removeFromSuperview];
        _canPop = YES;
        if (completion) completion();
    }
    
    self.userInteractionEnabled = NO;
    
    CAMediaTimingFunction *func = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.85 :0.5 :0.9];
    double duration = 0.35;
    
    CABasicAnimation *animOut = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animOut.delegate = self;
    animOut.duration = duration;
    animOut.timingFunction = func;
    animOut.fromValue = @(self.width*0.5);
    animOut.toValue = @(self.width*0.125);
    [animOut setValue:^{
        self.userInteractionEnabled = YES;
        [_scrollViewHome removeFromSuperview];
        _canPop = YES;
        if (completion) completion();
    } forKey:@"handle"];
    
    CABasicAnimation *animIn = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animIn.duration = duration;
    animIn.timingFunction = func;
    animIn.fromValue = @(self.width*1.5);
    animIn.toValue = @(self.width*0.5);
    
    [_pushedView.layer addAnimation:animIn forKey:@"in"];
    _pushedView.layer.position = CGPointMake(self.width*0.5, self.height*0.5);
    
    [_scrollViewHome.layer addAnimation:animOut forKey:@"out"];
}

/**
 *  pop 出来
 *
 *  @param animated   animated description
 *  @param completion completion description
 */
- (void)popToRootWithAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    if (!_canPop) {
        if (completion) {
            completion();
        }
        return;
    }
    _canPop = NO;
    
    _scrollViewHome.frame = CGRectMake(0, 0, self.width, _pageControl.top);
    [self insertSubview:_scrollViewHome belowSubview:_pushedView];
    
    if (!animated) {
        [_pushedView removeFromSuperview];
        _pushedView = nil;
        if (completion) completion();
        return;
    }
    
    self.userInteractionEnabled = NO;
    
    CAMediaTimingFunction *func = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.85 :0.5 :0.9];
    double duration = 0.35;
    
    CABasicAnimation *animOut = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animOut.delegate = self;
    animOut.duration = duration;
    animOut.timingFunction = func;
    animOut.fromValue = @(self.width*0.5);
    animOut.toValue = @(self.width*1.5);
    [animOut setValue:^{
        self.userInteractionEnabled = YES;
        [_pushedView removeFromSuperview];
        _pushedView = nil;
        if (completion) completion();
    } forKey:@"handle"];
    
    CABasicAnimation *animIn = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animIn.duration = duration;
    animIn.timingFunction = func;
    animIn.fromValue = @(self.width*0.125);
    animIn.toValue = @(self.width*0.5);
    
    [_pushedView.layer addAnimation:animOut forKey:@"out"];
    _pushedView.layer.position = CGPointMake(self.width*1.5, _pushedView.layer.position.y);
    
    [_scrollViewHome.layer addAnimation:animIn forKey:@"in"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void(^handle)() = [anim valueForKey:@"handle"];
    if (handle) {
        handle();
    }
}

@end
