//
//  UIViewMenu.m
//  ChinaBrowser
//
//  Created by David on 14-9-25.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewMenu.h"

#import "UIScrollViewMenu.h"
#import "UIViewMenuPage.h"
#import "SMPageControl.h"
#import "UIControlItem.h"

@interface UIViewMenu () <UIScrollViewDelegate>

@end

@implementation UIViewMenu
{
    IBOutlet UIScrollViewMenu *_scrollViewMenu;
    IBOutlet UIView *_viewContent;
    IBOutlet SMPageControl *_pageControl;
    
    BOOL _animating;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismiss)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    NSArray *arrArrMenuItem = @[
                                @[
                                    @{
                                        @"type":@(MenuItemRefresh),
                                        @"title":@"shuaxin",
                                        @"icon":@"refresh"
                                        },
                                    @{
                                        @"type":@(MenuItemDesktopStyle),
                                        @"title":@"zhuomianyangshi",
                                        @"icon":@"style"
                                        },
                                    @{
                                        @"type":@(MenuItemFindInPage),
                                        @"title":@"yeneichazhao",
                                        @"icon":@"search"
                                        },
                                    @{
                                        @"type":@(MenuItemShare),
                                        @"title":@"fenxiang",
                                        @"icon":@"share"
                                        },
                                    @{
                                        @"type":@(MenuItemScreenshot),
                                        @"title":@"jietutuya",
                                        @"icon":@"screenshot"
                                        },
                                    @{
                                        @"type":@(MenuItemBookmark),
                                        @"title":@"jiarushuqian",
                                        @"icon":@"collect"
                                        },
                                    @{
                                        @"type":@(MenuItemBookmarkHistory),
                                        @"title":@"shuqian_lishi",
                                        @"icon":@"collect_history"
                                        },
                                    @{
                                        @"type":@(MenuItemProfile),
                                        @"title":@"gerenzhongxin",
                                        @"icon":@"users"
                                        },
                                    ],
                                @[
                                    @{
                                        @"type":@(MenuItemSetBrightness),
                                        @"title":@"liangdutiaojie",
                                        @"icon":@"light"
                                        },
                                    @{
                                        @"type":@(MenuItemNoImageMode),
                                        @"title":@"wutumoshi",
                                        @"icon":@"no_picture"
                                        },
                                    @{
                                        @"type":@(MenuItemNoSaveHistory),
                                        @"title":@"wuhenliulan",
                                        @"icon":@"no_trace"
                                        },
                                    @{
                                        @"type":@(MenuItemQRCode),
                                        @"title":@"saoerweima",
                                        @"icon":@"qr_code"
                                        },
                                    @{
                                        @"type":@(MenuItemFullscreenMode),
                                        @"title":@"quanpingmoshi",
                                        @"icon":@"full_screen"
                                        },
                                    @{
                                        @"type":@(MenuItemSkinManage),
                                        @"title":@"pifuguanli",
                                        @"icon":@"skin"
                                        },
                                    @{
                                        @"type":@(MenuItemLanguage),
                                        @"title":@"yuyanshezhi",
                                        @"icon":@"language"
                                        },
                                    @{
                                        @"type":@(MenuItemSystemSettings),
                                        @"title":@"xitongshezhi",
                                        @"icon":@"set_up"
                                        }
                                    ],
                                @[
                                    /*@{
                                        @"type":@(MenuItemDownload),
                                        @"title":@"xiazaiguanli",
                                        @"icon":@"down"
                                        },*/
                                    @{
                                        @"type":@(MenuItemFeedback),
                                        @"title":@"yijianfankui",
                                        @"icon":@"feedback"
                                        }/*,
                                    @{
                                        @"type":@(MenuItemSaveTraffic),
                                        @"title":@"shengliuchaxun",
                                        @"icon":@"query"
                                        }*/,
                                    @{
                                        @"type":@(MenuItemCheckVersion),
                                        @"title":@"jianchagengxin",
                                        @"icon":@"refresh"
                                        }/*,
                                    @{
                                        @"type":@(MenuItemExit),
                                        @"title":@"tuichu",
                                        @"icon":@"20"
                                        }*/
                                    ]
                                ];
    
    for (NSInteger i=0; i<arrArrMenuItem.count; i++) {
        UIViewMenuPage *viewMenuPage = [[UIViewMenuPage alloc] initWithFrame:_scrollViewMenu.bounds];
        viewMenuPage.rowCount = 2;
        viewMenuPage.colCount = 4;
        viewMenuPage.tag = i;
        [_scrollViewMenu addSubview:viewMenuPage];
        
        NSArray *arrMenuItemDic = arrArrMenuItem[i];
        for (NSInteger j=0; j<arrMenuItemDic.count; j++) {
            NSDictionary *dicMenuItem = arrMenuItemDic[j];
            
            UIControlItem *viewMenuItem = [UIControlItem viewFromXibWithType:ControlItemTypeMenu];
            viewMenuItem.labelTitle.text = LocalizedString(dicMenuItem[@"title"]);
            [viewMenuItem setImageNormal:[UIImage imageWithBundleFile:[NSString stringWithFormat:@"iPhone/Menu/%@_0.png", dicMenuItem[@"icon"]]]
                             highlighted:[UIImage imageWithBundleFile:[NSString stringWithFormat:@"iPhone/Menu/%@_1.png", dicMenuItem[@"icon"]]]
                                selected:[UIImage imageWithBundleFile:[NSString stringWithFormat:@"iPhone/Menu/%@_2.png", dicMenuItem[@"icon"]]]];
            [viewMenuItem setTextColorNormal:[UIColor colorWithRed:0.171 green:0.171 blue:0.171 alpha:1.000]
                                 highlighted:[UIColor colorWithRed:0.504 green:0.504 blue:0.504 alpha:1.000]
                                    selected:[UIColor colorWithRed:0.196 green:0.690 blue:1.000 alpha:1.000]];
            [viewMenuItem setBgColorNormal:[UIColor clearColor] highlighted:[UIColor clearColor]];
            
            [viewMenuItem addTarget:self action:@selector(onTouchMenuItem:) forControlEvents:UIControlEventTouchUpInside];
            [viewMenuPage addMenuItem:viewMenuItem];
            
            MenuItem menuItem = [dicMenuItem[@"type"] integerValue];
            viewMenuItem.tag = menuItem;
            
            switch (menuItem) {
                case MenuItemBookmark:
                {
                    _viewMenuItemBookmark = viewMenuItem;
                }break;
                case MenuItemRefresh:
                {
                    _viewMenuItemRefresh = viewMenuItem;
                }break;
                case MenuItemFindInPage:
                {
                    _viewMenuItemFindInPage = viewMenuItem;
                }break;
                case MenuItemNoImageMode:
                {
                    _viewMenuItemNoImageMode = viewMenuItem;
                }break;
                case MenuItemFullscreenMode:
                {
                    _viewMenuItemFullscreen = viewMenuItem;
                }break;
                case MenuItemNoSaveHistory:
                {
                    _viewMenuItemNoSaveHistory = viewMenuItem;
                }break;
                default:
                    break;
            }
        }
    }
    _scrollViewMenu.frame = _scrollViewMenu.frame;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.471 green:0.471 blue:0.471 alpha:1.000];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.235 green:0.608 blue:0.973 alpha:1.000];
    _viewContent.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    
    _viewMenuItemNoImageMode.selected = [AppSetting shareAppSetting].noImageMode;
    _viewMenuItemFullscreen.selected = [AppSetting shareAppSetting].fullscreenMode;
    _viewMenuItemNoSaveHistory.selected = [AppSetting shareAppSetting].noSaveHistory;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _pageControl.numberOfPages = arrArrMenuItem.count;
    });
}

+ (instancetype)viewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:@"UIViewMenu" owner:nil options:nil][0];
}

/**
 *  设置浏览器模式标识，YES为浏览器模式，跟浏览器相关的菜单项随之 启用，否则 禁用；
 *
 *  @param browserMode 是否浏览器模式
 */
- (void)setBrowserMode:(BOOL)browserMode
{
    _viewMenuItemFindInPage.enabled =
    _viewMenuItemRefresh.enabled = browserMode;
    if (!browserMode) {
        _viewMenuItemBookmark.enabled = browserMode;
    }
}

/**
 *  设置书签菜单项是否启用
 *
 *  @param enable 是否启用
 */
- (void)setBookmarkItemEnable:(BOOL)enable
{
    _viewMenuItemBookmark.enabled = enable;
//    if (enable) {
//        _viewMenuItemBookmark.imageViewIcon.image = nil;
//        _viewMenuItemBookmark.imageViewIcon.highlightedImage = nil;
//    }
//    else {
//        _viewMenuItemBookmark.imageViewIcon.image = nil;
//        _viewMenuItemBookmark.imageViewIcon.highlightedImage = nil;
//    }
}

/**
 *  显示面板
 *
 *  @param view         显示在哪个目标视图上
 *  @param centerOfDock 停靠的边栏中点
 *  @param dockDirection 停靠的边栏方向
 */
- (void)showInView:(UIView *)view centerOfDock:(CGPoint)centerOfDock dockDirection:(DockDirection)dockDirection
{
    _animating = YES;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.frame = view.bounds;
    [view addSubview:self];
    
    CGRect rc = _viewContent.frame;
    switch (dockDirection) {
        case DockDirectionTop:
        {
            rc.size.width = 320;
            rc.origin.y = centerOfDock.y;
            rc.origin.x = centerOfDock.x-rc.size.width/2;
            if (rc.origin.x+rc.size.width>self.width) {
                rc.origin.x = self.width-rc.size.width;
            }
            else if (rc.origin.x<0) {
                rc.origin.x = 0;
            }
            _viewContent.frame = CGRectIntegral(rc);
            
            _viewContent.layer.anchorPoint = CGPointMake((centerOfDock.x-_viewContent.left)/_viewContent.width, 0);
            _viewContent.layer.position = centerOfDock;
        }break;
        case DockDirectionBottom:
        {
            rc.size.width = self.width;
            rc.origin.y = centerOfDock.y-rc.size.height;
            rc.origin.x = centerOfDock.x-rc.size.width/2;
            if (rc.origin.x+rc.size.width>self.width) {
                rc.origin.x = self.width-rc.size.width;
            }
            else if (rc.origin.x<0) {
                rc.origin.x = 0;
            }
            _viewContent.frame = CGRectIntegral(rc);
            
            _viewContent.layer.anchorPoint = CGPointMake((centerOfDock.x-_viewContent.left)/_viewContent.width, 1);
            _viewContent.layer.position = centerOfDock;
        }break;
            
        default:
            break;
    }
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.001, 0.001, 1)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    anim.keyTimes = @[@(0), @(0.75), @(1)];
    anim.duration = 0.35;
    anim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [_viewContent.layer addAnimation:anim forKey:@"transform"];
    
    CABasicAnimation *animOpacity = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animOpacity.fromValue = (id)[UIColor clearColor].CGColor;
    animOpacity.toValue = (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor;
    animOpacity.duration = 0.35;
    animOpacity.delegate = self;
    [animOpacity setValue:^{
        _animating = NO;
    } forKey:@"handle"];
    [self.layer addAnimation:animOpacity forKey:@"backgroundColor"];
    
    _viewContent.layer.transform = CATransform3DMakeScale(1, 1, 1);
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
}

/**
 *  消失
 */
- (void)dismiss
{
    // self dismisss
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void(^)(void))completion
{
    if (_animating) {
        return;
    }
    
    _animating = YES;
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.001, 0.001, 1)]];
    anim.keyTimes = @[@(0), @(0.25), @(1)];
    anim.duration = 0.35;
    anim.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [_viewContent.layer addAnimation:anim forKey:@"transform"];
    
    CABasicAnimation *animOpacity = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animOpacity.toValue = (id)[UIColor clearColor].CGColor;
    animOpacity.fromValue = (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor;
    animOpacity.duration = 0.35;
    animOpacity.delegate = self;
    [animOpacity setValue:^{
        if (completion) completion();
        
        _animating = NO;
        [self removeFromSuperview];
    } forKey:@"handle"];
    [self.layer addAnimation:animOpacity forKey:@"backgroundColor"];
    
    _viewContent.layer.transform = CATransform3DMakeScale(0.001, 0.001, 1);
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void (^handle)() = [anim valueForKey:@"handle"];
    if (handle) {
        handle();
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_animating) {
        return;
    }
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(_viewContent.frame, touchPoint)) {
        [self dismiss];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x/scrollView.width;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (IBAction)onValueChanged:(SMPageControl *)pageControl
{
    [_scrollViewMenu setContentOffset:CGPointMake(_scrollViewMenu.width*pageControl.currentPage, 0) animated:YES];
}

- (void)onTouchMenuItem:(UIControlItem *)viewMenuItem
{
    MenuItem menuItem = (MenuItem)viewMenuItem.tag;
    [self dismissWithCompletion:^{
        [_delegate viewMenu:self seletedMenuItem:menuItem];
    }];
}

@end