//
//  UIViewBottomBar.m
//  ChinaBrowser
//
//  Created by David on 14-9-1.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewBottomBar.h"

@implementation UIViewBottomBar
{
    UILabel *_labelNumber;
}

#pragma mark - property
- (void)setNumberOfWinds:(NSInteger)numberOfWinds
{
    [self setNumberOfWinds:numberOfWinds animated:NO];
}

- (void)setNumberOfWinds:(NSInteger)numberOfWinds animated:(BOOL)animated
{
    if (animated) {
        CATransition *anim = [CATransition animation];
        anim.type = kCATransitionPush;
        if (numberOfWinds>_numberOfWinds) {
            // 增加
            anim.subtype = kCATransitionFromTop;
        }
        else {
            // 减少
            anim.subtype = kCATransitionFromBottom;
        }
        anim.duration = 0.25;
        anim.fillMode = kCAFillModeForwards;
        [_labelNumber.layer addAnimation:anim forKey:@"moveIn"];
        
        _numberOfWinds = numberOfWinds;
        _labelNumber.text = [@(_numberOfWinds) stringValue];
    }
    else {
        _numberOfWinds = numberOfWinds;
        _labelNumber.text = [@(_numberOfWinds) stringValue];
    }
}

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
    
    [_btnWinds addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 14, 14)];
    {
        view.backgroundColor = [UIColor clearColor];
        view.clipsToBounds = YES;
        view.userInteractionEnabled = NO;
        _labelNumber = [[UILabel alloc] initWithFrame:view.bounds];
        _labelNumber.font = [UIFont systemFontOfSize:10];
        _labelNumber.textAlignment = NSTextAlignmentCenter;
        _labelNumber.backgroundColor = [UIColor clearColor];
        [_btnWinds addSubview:view];
        [view addSubview:_labelNumber];
        
        _labelNumber.textColor = [UIColor colorWithWhite:0.1 alpha:1];
        _labelNumber.highlightedTextColor = [UIColor colorWithWhite:0.3 alpha:1.000];
    }
    
    NSArray *arrBtn = @[_btnGoBack, _btnGoForward, _btnMenu, _btnWinds, _btnGoHome];
    NSArray *arrImg = @[@"arrow_left", @"arrow_right", @"list", @"multi_label", @"home"];
    [arrBtn enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        [btn setImage:[UIImage imageWithBundleFile:[NSString stringWithFormat:@"iPhone/Home/%@_0.png", arrImg[idx]]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageWithBundleFile:[NSString stringWithFormat:@"iPhone/Home/%@_1.png", arrImg[idx]]] forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageWithBundleFile:[NSString stringWithFormat:@"iPhone/Home/%@_3.png", arrImg[idx]]] forState:UIControlStateDisabled];
    }];
    UIImageView *imageViewLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1.5)];
    imageViewLine.image = [UIImage imageWithBundleFile:@"iPhone/Home/line_tab.png"];
    imageViewLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self insertSubview:imageViewLine atIndex:0];
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
}

- (void)dealloc
{
    [_btnWinds removeObserver:self forKeyPath:@"highlighted"];
}

- (void)setFrame:(CGRect)frame
{
    _DEBUG_LOG(@"%s", __FUNCTION__);
    [super setFrame:frame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"]) {
        BOOL highlighted = [change[NSKeyValueChangeNewKey] boolValue];
        _labelNumber.highlighted = highlighted;
    }
}

- (IBAction)onTouchBarItem:(UIView *)barItem
{
    if (barItem==_btnGoBack) {
        [_delegate view:self barEvent:BarEventGoBack barItem:barItem];
    }
    else if (barItem==_btnGoForward) {
        [_delegate view:self barEvent:BarEventGoForward barItem:barItem];
    }
    else if (barItem==_btnGoHome) {
        [_delegate view:self barEvent:BarEventHome barItem:barItem];
    }
    else if (barItem==_btnMenu) {
        [_delegate view:self barEvent:BarEventMenu barItem:barItem];
    }
    else if (barItem==_btnWinds) {
        [_delegate view:self barEvent:BarEventWindows barItem:barItem];
    }
    /*
    else if (barItem==_btnRefresh) {
        [_delegate view:self barEvent:BarEventRefresh barItem:barItem];
    }
    else if (barItem==_btnStop) {
        [_delegate view:self barEvent:BarEventStop barItem:barItem];
    }
    else if (barItem==_rightBtnQRCode) {
        [_delegate view:self barEvent:BarEventQRCode barItem:barItem];
    }
    else if (barItem==_leftViewBookmark) {
        [_delegate view:self barEvent:BarEventBookmark barItem:barItem];
    }
    else if (barItem==_leftViewSearchOption) {
        [_delegate view:self barEvent:BarEventSearchOption barItem:barItem];
    }
     */
}

@end
