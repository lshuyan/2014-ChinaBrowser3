//
//  UIScrollViewNews.m
//  ChinaBrowser
//
//  Created by David on 14/12/17.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIScrollViewNews.h"

@interface UIScrollViewNews () <UIScrollViewDelegate>

@end

@implementation UIScrollViewNews
{
    UIButton *_btnClose;
    
    NSInteger _indexOfNews;
    NSTimer *_timerScroll;
    
    NSMutableArray *_arrView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setFrame:(CGRect)frame
{
    NSInteger index = self.contentOffset.x/self.width;
    [super setFrame:frame];
    
    for (NSInteger i=0; i<_arrView.count; i++) {
        UIButton *btnNews = _arrView[i];
        btnNews.frame = CGRectMake(self.width*i, 0, self.width, self.height);
    }
    
    self.contentOffset = CGPointMake(self.width*index, 0);
    _btnClose.center = CGPointMake(self.width-_btnClose.width/2+self.contentOffset.x, self.contentOffset.y+self.height/2);
}

- (void)setup
{
    self.showsHorizontalScrollIndicator =
    self.showsVerticalScrollIndicator = NO;
    self.scrollEnabled = NO;
    self.delegate = self;
    
    _arrView = [NSMutableArray array];
    
    _btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _btnClose.center = CGPointMake(self.width-_btnClose.width+self.contentOffset.x, self.contentOffset.y+self.height/2);
    [_btnClose setImage:[UIImage imageWithBundleFile:@"iPhone/Home/close_0.png"] forState:UIControlStateNormal];
    [_btnClose setImage:[UIImage imageWithBundleFile:@"iPhone/Home/close_1.png"] forState:UIControlStateHighlighted];
    [_btnClose addTarget:self action:@selector(onTouchClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnClose];
    
}

/**
 *  设置滚动新闻数组
 *
 *  @param arrDictNews 数据格式：[{title, refurl}]
 */
- (void)setArrDictNews:(NSArray *)arrDictNews
{
    [_arrView makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_arrView removeAllObjects];
    self.contentSize = CGSizeMake(self.width, self.height);
    self.contentOffset = CGPointZero;
    
    _indexOfNews = 0;
    _arrDictNews = arrDictNews;
    
    for (NSInteger i=0; i<_arrDictNews.count; i++) {
        NSDictionary *dictNews = _arrDictNews[i];
        
        UIButton *btnNews = [[UIButton alloc] initWithFrame:CGRectMake(self.width*i, 0, self.width, self.height)];
        btnNews.tag = i;
        [btnNews setTitleColor:[UIColor colorWithWhite:0.05 alpha:1] forState:UIControlStateNormal];
        [btnNews setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateHighlighted];
        btnNews.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnNews addTarget:self action:@selector(onTouchNews:) forControlEvents:UIControlEventTouchUpInside];
        [btnNews setTitle:dictNews[@"title"] forState:UIControlStateNormal];
        btnNews.backgroundColor = [UIColor whiteColor];
        
        [self insertSubview:btnNews belowSubview:_btnClose];
        [_arrView addObject:btnNews];
    }
    
    [_timerScroll invalidate];
    _timerScroll = nil;
    
    if (_arrDictNews.count>0) {
        _timerScroll = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(doScrollNews) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timerScroll forMode:NSRunLoopCommonModes];
    }
}

- (void)doScrollNews
{
    _indexOfNews++;
    if (_indexOfNews>=_arrDictNews.count) {
        _indexOfNews=0;
    }
    
    [self setContentOffset:CGPointMake(self.width*_indexOfNews, 0) animated:YES];
    _btnClose.center = CGPointMake(self.width-_btnClose.width/2+self.contentOffset.x, self.contentOffset.y+self.height/2);
}

- (void)onTouchNews:(UIButton *)btn
{
    NSDictionary *dictNews = _arrDictNews[btn.tag];
    if (_callbackReqLink) {
        _callbackReqLink(dictNews[@"refurl"]);
    }
}

- (void)onTouchClose
{
    if (_callbackClose) {
        _callbackClose();
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _btnClose.center = CGPointMake(self.width-_btnClose.width/2+self.contentOffset.x, self.contentOffset.y+self.height/2);
}

@end