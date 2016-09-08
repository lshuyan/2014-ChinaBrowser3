//
//  UIControllerMain.m
//  ChinaBrowser
//
//  Created by David on 14-8-30.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerMain.h"

#import "UIViewLaunch.h"

#import "UIViewHome.h"
#import "UIScrollViewHome.h"
#import "UIScrollViewTrans.h"
#import "UIScrollViewTravel.h"
#import "UIScrollViewRecommend.h"
#import "UIScrollViewApp.h"
#import "UITableViewMode.h"

#import "UIViewNews.h"
#import "UIViewRecommendSubCate.h"

#import "UIViewTopBar.h"
#import "UIViewBottomBar.h"
#import "UIViewBarEventDelegate.h"

#import "UIViewMenu.h"
#import "UIViewBookmarkPopAction.h"
#import "UIViewSearchOption.h"
#import "UIViewSearchPanel.h"
#import "UIViewPopSetBrightness.h"
#import "UIViewFindInWebPage.h"
#import "UIViewPopShareOption.h"
#import "UIViewPopBookmark.h"

#import "UIControlItemApp.h"

#import "UIControllerLanguage.h"
#import "UIControllerTrans.h"
#import "UIControllerQRCode.h"
#import "UIControllerScreenshot.h"
#import "UIControllerDrawView.h"
#import "UIControllerLogin.h"
#import "UIControllerSetSkin.h"
#import "UIControllerTravelDetail.h"
#import "UIControllerUserInfo.h"
#import "UIControllerDesktopStyle.h"
#import "UIControllerBookmarkHistory.h"
#import "UIControllerSysSettings.h"
#import "UIControllerLabelsList.h"
#import "UIControllerManuallyAdd.h"
#import "UIControllerAddProgram.h"
#import "UIControllerRename.h"
#import "UIControllerModeDetail.h"
#import "UIControllerWebview.h"

#import "ModelTravelProvince.h"

#import "QRCodeProtocol.h"
#import "CheckVersion.h"
#import "ADOApp.h"
#import "ADOHistory.h"
#import "ADOBookmark.h"
#import "ADOLinkIcon.h"
#import "ADOSyncDelete.h"

#import "UserManager.h"

#import "ModelSearchEngine.h"
#import "ModelApp.h"
#import "ModelMode.h"
#import "ModelProgram.h"
#import "ModelPlayItem.h"
#import "ModelSyncDelete.h"
#import "ModelUserSettings.h"

#import "UIImage+Resize.h"
#import "UIWebViewAdditions.h"

#import "CBAudioPlayer.h"

#import "UIWebPage.h"
#import "WebPageManage.h"
#import "UIViewScrollPreviewTab.h"
#import "UIViewTabBottom.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#import "APService.h"
#import "BlockUI.h"
#import "KTAnimationKit.h"

#import "FMLocalNotificationManager.h"

@interface UIControllerMain ()
<
UIViewBarEventDelegate,
UIViewMenuDelegate,
UIViewBookmarkPopActionDelegate,
UIViewSearchOptionDelegate,
UIScrollViewTransDelegate,
UIScrollViewTravelDelegate,
UIScrollViewRecommendDelegate,
UIScrollViewAppDelegate,
UITableViewModeDelegate,
UIViewNewsDelegate,
UIViewRecommendSubCateDelegate,
QRCodeProtocol,
UIControllerScreenshotDelegate,
UIControllerSetSkinDelegate,
UIControllerTravelDetailDelegate,
UIControllerBookmarkHistoryDelegate,
UIViewSearchPanelDelegate,
UIViewFindInWebPageDelegate,
AppLaunchDelegate,
WebPageManageDelegate,
UIViewScrollPreviewTabDelegate
>

@end

@implementation UIControllerMain
{
    IBOutlet UIViewTopBar *_viewTopBar;
    IBOutlet UIViewBottomBar *_viewBottomBar;
    
    IBOutlet UIViewHome *_viewHome;
    IBOutlet UIScrollViewTrans *_scrollViewTrans;
    IBOutlet UIScrollViewTravel *_scrollViewTravel;
    IBOutlet UIScrollViewRecommend *_scrollViewRecommend;
    IBOutlet UIScrollViewApp *_scrollViewApp;
    IBOutlet UITableViewMode *_tableViewMode;
    
    /**
     *  使用 __weak 的好处：_viewMenu 显示的时候有值，消失后自动变为 nil
     */
    __weak UIViewMenu *_viewMenu;
    __weak UIViewSearchPanel *_viewSearchPanel;
    __weak UIViewFindInWebPage *_viewFindInWebPage;
    
    // 取消编辑
    UIButton *_btnCancelEditApp;
    
    // -------- 网页相关
    WebPageManage *_webManager;
    UIWebPage *_webPage;
    UIViewScrollPreviewTab *_viewScrollPreviewTab;
    UIImage *_imageHomeScreenshot;
    __weak UIViewTabBottom *_viewTabBottom;
    
    // -------- 正在滚动调整 全屏模式
    BOOL _scrollToChangeFullscreenEnable;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppLaunchUtil shareAppLaunch].delegate = self;;
    
    // Do any additional setup after loading the view.
    /**
     *  从服务器下载 搜索引擎配置文件
     */
    [AppSetting fetchSeachEngineWithCompletion:^{
        _viewTopBar.searchEngine = [AppSetting shareAppSetting].searchEngine;
    }];
    /**
     *  从服务器下载 分享选项
     */
    [AppSetting fetchShareItemWithCompletion:nil];
    
    // ----------------------
    [self.view setBgImageWithScaleAspectFillImage:[AppSetting shareAppSetting].skinImage];
    
    _viewTopBar.alpha =
    _viewBottomBar.alpha =
    _viewHome.alpha = 0;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangedLanguageNotification:)
                                                 name:kNotificationDidChangedAppLan
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangedSearchEngineNotification:)
                                                 name:KNotificationDidChangedSearchEngine
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoginNotification:)
                                                 name:KNotificationDidLogin
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogoutNotification:)
                                                 name:KNotificationDidLogout
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangedFontSizeNotification:)
                                                 name:KNotificationDidChangedFontSize
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncReminderNotification:)
                                                 name:KNotificationDidSyncReminder
                                               object:nil];
    
    
    _webManager = [[WebPageManage alloc] init];
    _webManager.delegate = self;
    _webManager.fontScale = [AppSetting shareAppSetting].fontScale;
    _webManager.noImageMode = [AppSetting shareAppSetting].noImageMode;
    
    [self newWebPageWithLink:nil toBeActive:YES animated:NO];
    
    // 设置进度条颜色
    [[UIWebPage appearance] setProgressColor:RGBCOLOR(255, 12, 100)];
    
    _viewTopBar.numberOfWinds =
    _viewBottomBar.numberOfWinds = _webManager.numberOfWebPage;
    
    [self updateControlState];
    
    if ([AppLaunchUtil shareAppLaunch].shouldLaunchProgram) {
        // 启动节目(可能是：播放电台、打开新闻列表、打开网站)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fadeInMainViewWithCompletionBlock:^{
                switch ([AppLaunchUtil shareAppLaunch].program.srcType) {
                    case ProgramSrcTypeFM:
                    {
                        [CBAudioPlayer playWithItem:[ModelPlayItem modelWithTitle:[AppLaunchUtil shareAppLaunch].program.title
                                                                             link:[AppLaunchUtil shareAppLaunch].program.link
                                                                               fm:[AppLaunchUtil shareAppLaunch].program.fm
                                                                             icon:nil]];
                    }break;
                    case ProgramSrcTypeRecommendCate:
                    {
                        [[AppLaunchUtil shareAppLaunch].delegate appLaunchOpenRecommendCateId:[AppLaunchUtil shareAppLaunch].program.recommendCateId
                                                                                     cateName:[AppLaunchUtil shareAppLaunch].program.title];
                    }break;
                    case ProgramSrcTypeWeb:
                    {
                        [[AppLaunchUtil shareAppLaunch].delegate appLaunchOpenLink:[AppLaunchUtil shareAppLaunch].program.link];
                    }break;
                    default:
                        break;
                }
            }];
        });
    }
    else if ([AppLaunchUtil shareAppLaunch].dictRemoteNotificationInfo) {
        // 远程通知启动
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fadeInMainViewWithCompletionBlock:^{
                NSString *link = [AppLaunchUtil shareAppLaunch].dictRemoteNotificationInfo[@"link"];
                if (link.length>0) {
                    [[AppLaunchUtil shareAppLaunch].delegate appLaunchOpenLink:link];
                }
            }];
        });
    }
    else {
        // 启动显示大图
        UIViewLaunch *viewLaunch = [[UIViewLaunch alloc] init];
        [viewLaunch showInView:self.view duration:4 didDimissCompletion:^{
            [self fadeInMainViewWithCompletionBlock:nil];
        }];
    }
    
    if ([UserManager shareUserManager].currUser) {
        [[SyncHelper shareSync] syncAllIfNeededWithCompletion:^{
            _DEBUG_LOG(@"%s", __FUNCTION__);
        } fail:^(NSError *error) {
            
        } syncDataTypeCompletion:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  根据电池栏方向 重新 布局视图
 *
 *  @param orientation 电池栏方向
 */
- (void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([self isWebPageMode]&&[AppSetting shareAppSetting].fullscreenMode) {
        [self enterFullscreenMode];
        return;
    }
    // _viewTopBar
    CGRect rc = _viewTopBar.frame;
    rc.origin = CGPointZero;
    rc.size.width = self.view.width;
    rc.size.height = 44;
    if (IsiOS7|IsiOS8) {
        if (![UIApplication sharedApplication].statusBarHidden) {
            CGSize sizeStatusBar = [UIApplication sharedApplication].statusBarFrame.size;
            rc.size.height += MIN(sizeStatusBar.width, sizeStatusBar.height);
        }
    }
    _viewTopBar.frame = rc;
    
    // _btnCancelEditApp
    if (_scrollViewApp.edit) {
        // _viewBottomBar
        rc = _viewBottomBar.frame;
        rc.origin.x = 0;
        rc.size.width = self.view.width;
        rc.origin.y = self.view.height;
        _viewBottomBar.frame = rc;
        
        rc = _btnCancelEditApp.frame;
        rc.origin.x = 0;
        rc.size.height = IsPortrait?_viewBottomBar.height:32;
        rc.size.width = self.view.width;
        rc.origin.y = self.view.height-rc.size.height;
        _btnCancelEditApp.frame = rc;
    }
    else {
        // _viewBottomBar
        rc = _viewBottomBar.frame;
        rc.origin.x = 0;
        rc.size.width = self.view.width;
        rc.origin.y = self.view.height-_viewBottomBar.height;
        if (!IsPortrait || _viewFindInWebPage) {
            // 横屏状态、页内查找功能启用 时，底部工具栏在屏幕底部，不在可视区
            rc.origin.y = self.view.height;
        }
        _viewBottomBar.frame = rc;
    }
    
    _webPage.frame = [self mainFrame];
    _viewHome.frame = [self mainFrame];
    
    if (_viewSearchPanel) {
        _viewSearchPanel.frame = [self mainFrame];
    }
}

#pragma mark - private methods
// ---------------------------------- 各种通知 事件 -----------------
- (void)didChangedLanguageNotification:(NSNotification *)notification
{
    // 重新设置通知标签
    [APService setTags:[NSSet setWithObjects:[[LocalizationUtil currLanguage] stringByReplacingOccurrencesOfString:@"-" withString:@""], nil]
      callbackSelector:nil
                object:nil];
    
    [_viewTopBar updateByLanguage];
    [_scrollViewTrans updateByLanguage];
    [_scrollViewTravel updateByLanguage];
    [_scrollViewRecommend updateByLanguage];
    [_scrollViewApp updateByLanguage];
    [_tableViewMode updateByLanguage];
    
    [AppSetting fetchSeachEngineWithCompletion:^{
        _viewTopBar.searchEngine = [AppSetting shareAppSetting].searchEngine;
    }];
    [AppSetting fetchShareItemWithCompletion:nil];
}

- (void)didChangedSearchEngineNotification:(NSNotification *)notification
{
    _viewTopBar.searchEngine = [AppSetting shareAppSetting].searchEngine;
}

- (void)didLoginNotification:(NSNotification *)notification
{
    [_scrollViewApp reloadCustomApp];
    [_tableViewMode reloadCustomMode];
    
    [[SyncHelper shareSync] syncAllIfNeededWithCompletion:^{
        _DEBUG_LOG(@"%s", __FUNCTION__);
    } fail:^(NSError *error) {
        
    } syncDataTypeCompletion:nil];
}

- (void)didLogoutNotification:(NSNotification *)notification
{
    [_scrollViewApp reloadCustomApp];
    [_tableViewMode reloadCustomMode];
}

- (void)didChangedFontSizeNotification:(NSNotification *)notification
{
    _webManager.fontScale = [AppSetting shareAppSetting].fontScale;
}

- (void)didSyncReminderNotification:(NSNotification *)notification
{
    [_tableViewMode reloadCustomMode];
    [FMLocalNotificationManager resetNotificationWithModePkid:_tableViewMode.currModePkid];
}

// ---------------------------------- 私有 事件 -----------------
/**
 *  主视图渐入
 *
 *  @param block 动画完成回调
 */
- (void)fadeInMainViewWithCompletionBlock:(void(^)())block
{
    [UIView animateWithDuration:0.5 animations:^{
        _viewTopBar.hidden =
        _viewBottomBar.hidden =
        _viewHome.hidden = NO;
        
        _viewTopBar.alpha =
        _viewBottomBar.alpha =
        _viewHome.alpha = 1;
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

/**
 *  得到主体内容的显示区域
 *
 *  @return CGRect
 */
- (CGRect)mainFrame
{
    CGRect rc = CGRectZero;
    if (_scrollViewApp.edit) {
        rc = CGRectMake(0, _viewTopBar.bottom, self.view.width, _btnCancelEditApp.top-_viewTopBar.bottom);
    }
    else {
        rc = CGRectMake(0, _viewTopBar.bottom, self.view.width, _viewBottomBar.top-_viewTopBar.bottom);
    }
    return rc;
}

- (UIView *)mainView
{
    return [self isWebPageMode]?_webPage:_viewHome;
}

/**
 *  是否 网页模式（是否正在浏览网页）
 *
 *  @return
 */
- (BOOL)isWebPageMode
{
    return _webPage.show&&_webPage.superview;
}

/**
 *  记录某个网页控件的历史记录
 *
 *  @param webPage UIWebPage 控件
 */
- (void)recordHistoryWithWebPage:(UIWebPage *)webPage
{
    if ([AppSetting shareAppSetting].noSaveHistory) return;
    
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    NSInteger userId = [UserManager shareUserManager].currUser.uid;
    
    ModelHistory *modelHistory = [ADOHistory queryWithLink:webPage.link userId:userId];
    
    if (modelHistory) {
        BOOL retVal = [ADOHistory updateTitle:webPage.title time:time updateTime:time withLink:webPage.link userId:userId];
        /**
         *  是否可以自动同步到服务器上去
         */
        if (retVal && modelHistory.pkid_server>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeHistory]) {
            modelHistory.title = webPage.title;
            modelHistory.time = time;
            modelHistory.updateTime = time;
            [[SyncHelper shareSync] syncUpdateArrHistory:@[modelHistory] async:YES completion:^{
                _DEBUG_LOG(@"%d,%s", __LINE__, __FUNCTION__);
            } fail:^(NSError *error) {
                _DEBUG_LOG(@"%d,%s,%@", __LINE__, __FUNCTION__, error?:@"");
            }];
        }
    }
    else {
        ModelHistory *modelHistory = [ModelHistory model];
        modelHistory.time = time;
        modelHistory.times = 1;
        modelHistory.title = webPage.title;
        modelHistory.link = webPage.link;
        modelHistory.icon = FaviconWithLink(modelHistory.link);
        modelHistory.updateTime = time;
        modelHistory.pkid = [ADOHistory addModel:modelHistory];
        if (modelHistory.pkid>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeHistory]) {
            [[SyncHelper shareSync] syncAddArrHistory:@[modelHistory] completion:^{
                _DEBUG_LOG(@"%d,%s", __LINE__, __FUNCTION__);
            } fail:^(NSError *error) {
                _DEBUG_LOG(@"%d,%s,%@", __LINE__, __FUNCTION__, error?:@"");
            }];
        }
    }
    
    
}

- (void)handleLink:(NSString *)link urlOpenStyle:(UrlOpenStyle)style;
{
    switch (style) {
        case UrlOpenStyleCurrent:
        {
            [_webPage load:link];
            if (![self isWebPageMode]) {
                [self backToWebPage];
            }
        }break;
        case UrlOpenStyleNewTab:
        {
            [self newWebPageWithLink:link toBeActive:YES animated:YES];
        }break;
        case UrlOpenStyleBackground:
        {
            [self newWebPageWithLink:link toBeActive:NO animated:NO];
        }break;
            
        default:
            break;
    }
}

/**
 *  新建一个网页
 *
 *  @param link       链接地址
 *  @param toBeActive 是否激活(设置为当前正在浏览器的网页)
 *  @param animated   是否动画执行
 */
- (void)newWebPageWithLink:(NSString *)link toBeActive:(BOOL)toBeActive animated:(BOOL)animated
{
    UIWebPage *webPage = [_webManager newWebPageAndReturnWithFrame:self.mainFrame];
    
    if (link.length>0) {
        webPage.show = YES;
        [webPage load:link];
    }
    
    if (toBeActive) {
        UIWebPage *webPageFrom = _webPage;
        UIWebPage *webPageTo = webPage;
        
        UIView *viewTo = webPageTo.show?webPageTo:_viewHome;
        
        if (webPageTo.show) {
            [_viewHome removeFromSuperview];
        }
        
        if (!_viewScrollPreviewTab.show) {
            [webPageFrom removeFromSuperview];
        }
        
        if (!viewTo.superview) {
            if (!CGRectEqualToRect(viewTo.frame, self.mainFrame)) {
                viewTo.frame = self.mainFrame;
            }
            
            [self.view insertSubview:viewTo belowSubview:_viewBottomBar];
        }
        
        if (animated) {
            // 创建影子(截图，假象)
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainFrame];
            imageView.image = [UIImage imageFromView:webPageFrom.show?webPageFrom:_viewHome];
            [self.view insertSubview:imageView belowSubview:_viewBottomBar];
            
            CGAffineTransform tfScale = CGAffineTransformMakeScale(kSwipeAnimScale, kSwipeAnimScale);
            CGAffineTransform tfTransLeft = CGAffineTransformConcat(tfScale, CGAffineTransformMakeTranslation(-viewTo.bounds.size.width, 0));
            CGAffineTransform tfTransRight = CGAffineTransformConcat(tfScale, CGAffineTransformMakeTranslation(viewTo.bounds.size.width, 0));
            
            viewTo.transform = tfTransRight;
            [UIView animateWithDuration:kSwipeAnimDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                viewTo.transform = CGAffineTransformIdentity;
                imageView.transform = tfTransLeft;
                imageView.alpha = kSwipeAnimAlpha;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                
                // 网页数量大于限制数量，将会删除当前浏览的网页
                if (_webManager.numberOfWebPage>kMaxWebViewNumber) {
                    [_webManager removeWebPage:_webPage];
                    [_webPage removeFromSuperview];
                    _webPage = nil;
                }
                
                _webPage = webPage;
                _webManager.currWebPage = _webPage;
                [self updateControlState];
                
                _viewBottomBar.numberOfWinds =
                _viewTopBar.numberOfWinds = _webManager.numberOfWebPage;
            }];
        }
        else {
            if (_webManager.numberOfWebPage>kMaxWebViewNumber) {
                [_webManager removeWebPage:_webPage];
                [_webPage removeFromSuperview];
                _webPage = nil;
            }
            
            _webPage = webPage;
            _webManager.currWebPage = _webPage;
            [self updateControlState];
            
            _viewBottomBar.numberOfWinds =
            _viewTopBar.numberOfWinds = _webManager.numberOfWebPage;
        }
    }
    else {
        // 网页数量大于限制数量，将会删除头部排除当前网页的第一个
        if (_webManager.numberOfWebPage>kMaxWebViewNumber) {
            [_webManager removeAtTopExceptCurrWebPage];
        }
        
        _viewBottomBar.numberOfWinds =
        _viewTopBar.numberOfWinds = _webManager.numberOfWebPage;
    }
}

- (void)backToHome
{
    [self backToHomeWithAnimated:YES completion:nil];
}

- (void)backToHomeWithAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    if (animated) {
        if (_webPage.show) {
            [_webPage removeFromSuperview];
            _webPage.show = NO;
            [self updateControlState];
            
            // 创建影子(截图，假象)
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainFrame];
            imageView.image = [UIImage imageFromView:_webPage];
            [self.view insertSubview:imageView belowSubview:_viewBottomBar];
            [self.view insertSubview:_viewHome belowSubview:_viewBottomBar];
            
            CGAffineTransform tfScale = CGAffineTransformMakeScale(1, 1);
            CGAffineTransform tfTransLeft = CGAffineTransformConcat(tfScale, CGAffineTransformMakeTranslation(-_viewHome.bounds.size.width, 0));
            CGAffineTransform tfTransRight = CGAffineTransformConcat(tfScale, CGAffineTransformMakeTranslation(_viewHome.bounds.size.width, 0));
            
            _viewHome.transform = tfTransLeft;
            [UIView animateWithDuration:kSwipeAnimDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _viewHome.transform = CGAffineTransformIdentity;
                imageView.transform = tfTransRight;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                _webPage = [_webManager replaceWithNewWebPage:_webPage];
                
                if(completion) completion();
            }];
        }
        else {
            if (!_viewHome.superview) {
                [self.view insertSubview:_viewHome belowSubview:_viewBottomBar];
            }
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            if ([AppSetting shareAppSetting].fullscreenMode) {
                [self exitFullscreenMode];
            }
            else {
                _viewHome.frame = [self mainFrame];
            }
        }];
    }
    else {
        [_webPage removeFromSuperview];
        _webPage = [_webManager replaceWithNewWebPage:_webPage];
        _webPage.show = NO;
        [self updateControlState];
        
        if ([AppSetting shareAppSetting].fullscreenMode) {
            [self exitFullscreenMode];
        }
        else {
            _viewHome.frame = [self mainFrame];
        }
        
        if(completion) completion();
    }
}

- (void)backToWebPage
{
    [_viewHome removeFromSuperview];
    [self.view insertSubview:_webPage belowSubview:_viewBottomBar];
    _webPage.show = YES;
    
    [self updateControlState];
    
    // 切换到网页模式，需要检查是否全屏，并设置对应的frame
    [UIView animateWithDuration:0.35 animations:^{
        if ([AppSetting shareAppSetting].fullscreenMode) {
            [self enterFullscreenMode];
        }
        else {
            _webPage.frame = [self mainFrame];
        }
    }];
}

- (void)updateControlState
{
    [self updateControlStateWithWebPage:_webPage];
}

- (void)updateControlStateWithWebPage:(UIWebPage *)webPage
{
    if (webPage.show) {
        // 浏览网页模式
        _viewTopBar.btnGoBack.enabled =
        _viewBottomBar.btnGoBack.enabled = YES;
        _viewTopBar.btnGoForward.enabled =
        _viewBottomBar.btnGoForward.enabled = webPage.canForward;
        
        _viewTopBar.btnRefresh.hidden = webPage.isLoading;
        _viewTopBar.btnStop.hidden = !webPage.isLoading;
        
        if (![_viewTopBar.textField isFirstResponder]) {
            // 非输入状态下才更新
            _viewTopBar.viewTopBarStatus = ViewTopBarStatusWeb;
            _viewTopBar.textField.text = kUrlBarShowTitle?webPage.titleOfShow:webPage.link;
        }
        
        [_viewTopBar setBookmarkIconHighlighted:[ADOBookmark isExistWithLink:webPage.link userId:[UserManager shareUserManager].currUser.uid]];
    }
    else {
        // 首页模式
        _viewTopBar.textField.text = nil;
        _viewTopBar.btnGoBack.enabled =
        _viewBottomBar.btnGoBack.enabled = [_viewHome canPop];
        _viewTopBar.btnGoForward.enabled =
        _viewBottomBar.btnGoForward.enabled = NO;
        
        _viewTopBar.btnRefresh.hidden =
        _viewTopBar.btnStop.hidden = YES;
        
        _viewTopBar.viewTopBarStatus = ViewTopBarStatusHome;
    }
}

/**
 *  进入全屏模式
 */
- (void)enterFullscreenMode
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    CGRect rc = _viewTopBar.frame;
    rc.size.width = self.view.width;
    rc.size.height = 44;
    if (IsiOS7|IsiOS8) {
        if (![UIApplication sharedApplication].statusBarHidden) {
            CGSize sizeStatusBar = [UIApplication sharedApplication].statusBarFrame.size;
            rc.size.height += MIN(sizeStatusBar.width, sizeStatusBar.height);
        }
    }
    rc.origin = CGPointMake(0, -rc.size.height);
    _viewTopBar.frame = rc;
    
    rc.origin = CGPointMake(0, self.view.height);
    rc.size.width = self.view.width;
    rc.size.height = _viewBottomBar.height;
    _viewBottomBar.frame = rc;
    
    _viewHome.frame =
    _webPage.frame = [self mainFrame];
}

/**
 *  退出全屏模式
 */
- (void)exitFullscreenMode
{
    if (IsPortrait) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        CGRect rc = _viewTopBar.frame;
        rc.size.width = self.view.width;
        rc.size.height = 44;
        if (IsiOS7|IsiOS8) {
            if (![UIApplication sharedApplication].statusBarHidden) {
                CGSize sizeStatusBar = [UIApplication sharedApplication].statusBarFrame.size;
                rc.size.height += MIN(sizeStatusBar.width, sizeStatusBar.height);
            }
        }
        rc.origin = CGPointMake(0, 0);
        _viewTopBar.frame = rc;
        
        rc.origin = CGPointMake(0, self.view.height-_viewBottomBar.height);
        rc.size.width = self.view.width;
        rc.size.height = _viewBottomBar.height;
        _viewBottomBar.frame = rc;
    }
    else {
        CGRect rc = _viewTopBar.frame;
        rc.size.width = self.view.width;
        rc.size.height = 44;
        if (IsiOS7|IsiOS8) {
            if (![UIApplication sharedApplication].statusBarHidden) {
                CGSize sizeStatusBar = [UIApplication sharedApplication].statusBarFrame.size;
                rc.size.height += MIN(sizeStatusBar.width, sizeStatusBar.height);
            }
        }
        rc.origin = CGPointMake(0, 0);
        _viewTopBar.frame = rc;
        
        rc.origin = CGPointMake(0, self.view.height);
        rc.size.width = self.view.width;
        rc.size.height = _viewBottomBar.height;
        _viewBottomBar.frame = rc;
    }
    
    [self mainView].frame = [self mainFrame];
}

/**
 *  显示多标签
 *
 *  @param show 是否显示
 */
- (void)showTabs:(BOOL)show
{
    if (show) {
        [RotateUtil store];
        [RotateUtil shareRotateUtil].rotateLock = YES;
        [RotateUtil shareRotateUtil].shouldShowRotateLock = NO;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _viewScrollPreviewTab = [[UIViewScrollPreviewTab alloc] initWithFrame:self.view.bounds];
            _viewScrollPreviewTab.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:0.3];
            _viewScrollPreviewTab.alwaysBounceHorizontal = YES;
            _viewScrollPreviewTab.showsHorizontalScrollIndicator = NO;
            _viewScrollPreviewTab.showsVerticalScrollIndicator = NO;
            _viewScrollPreviewTab.alwaysBounceVertical = NO;
            _viewScrollPreviewTab.delegatePreviewTab = self;
            _viewScrollPreviewTab.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            _viewScrollPreviewTab.previewTabScale = 0.6;
            _viewScrollPreviewTab.previewTabSpace = 10;
        });
        
        [_webManager.currWebPage removeFromSuperview];
        if (!CGRectEqualToRect(self.mainFrame, _viewHome.frame)) {
            _viewHome.frame = self.mainFrame;
        }
        [self.view insertSubview:_viewHome belowSubview:_viewBottomBar];
        _imageHomeScreenshot = [UIImage imageFromView:self.view rect:self.mainFrame];
        
        NSArray *arrWebPage = [_webManager arrWebPage];
        NSMutableArray *arrThumbView = [NSMutableArray arrayWithCapacity:arrWebPage.count];
        [arrWebPage enumerateObjectsUsingBlock:^(UIWebPage *webPage, NSUInteger idx, BOOL *stop) {
            if (webPage.show) {
                [arrThumbView addObject:webPage];
            }
            else {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainFrame];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                imageView.image = _imageHomeScreenshot;
                [arrThumbView addObject:imageView];
            }
        }];
        
        [_viewHome removeFromSuperview];
        
        CGRect rc = CGRectMake(0, 0, self.view.width, 0);
        rc.size.height = IsPortrait?44:32;
        rc.origin.y = self.view.height-rc.size.height;
        UIViewTabBottom *viewTabBottom = nil;
        {
            viewTabBottom = [UIViewTabBottom viewFromXib];
            viewTabBottom.frame = rc;
            viewTabBottom.alpha = 0;
            viewTabBottom.callbackBack = ^{
                [_viewScrollPreviewTab dismissWithCompletion:nil];
            };
            viewTabBottom.callbackNewWindow  = ^{
                [self newWebPageWithLink:nil toBeActive:YES animated:NO];
                
                _viewScrollPreviewTab.alpha = 0;
                [self.view addSubview:_viewHome];
                _imageHomeScreenshot = [UIImage imageFromView:self.view rect:self.mainFrame];
                [_viewHome removeFromSuperview];
                _viewScrollPreviewTab.alpha = 1;
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainFrame];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                imageView.image = _imageHomeScreenshot;
                [_viewHome removeFromSuperview];
                [_viewScrollPreviewTab newThumbWithPreviewView:imageView];
                
                [_viewTabBottom setAllowNew:_webManager.numberOfWebPage<kMaxWebViewNumber];
            };
            viewTabBottom.hidden = NO;
            
            // 根据当前网页数量设置是否允许新建网页
            [viewTabBottom setAllowNew:_webManager.numberOfWebPage<kMaxWebViewNumber];
        }
        
        _viewScrollPreviewTab.frame = CGRectMake(0, 0, self.view.width, self.view.height-viewTabBottom.height);
        
        [_viewScrollPreviewTab showInView:self.view arrView:arrThumbView selectIndex:_webManager.currWebPageIndex rcOrigin:self.mainFrame completion:^{
        }];
        
        [self.view addSubview:viewTabBottom];
        _viewTabBottom = viewTabBottom;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            _viewTopBar.alpha =
            _viewBottomBar.alpha = 0;
            _viewTabBottom.alpha = 1;
        }];
    }
    else {
        [RotateUtil restore];
        _imageHomeScreenshot = nil;
        [UIView animateWithDuration:0.3 animations:^{
            _viewTopBar.alpha =
            _viewBottomBar.alpha = 1;
            _viewTabBottom.alpha = 0;
            [_viewTabBottom removeFromSuperview];
        }];
    }
}

// ---------------------------------- 工具栏事件 -----------------
#pragma mark - UIViewBarEventDelegate
- (void)view:(UIView *)view barEvent:(BarEvent)barEvent barItem:(UIView *)barItem
{
    _scrollViewApp.edit = NO;
    
    switch (barEvent) {
        // --------- _viewTopBar、_viewBottomBar公共事件
        case BarEventGoBack:
        {
            if ([self isWebPageMode]) {
                if (_webPage.canBack) {
                    [_webPage goBack];
                }
                else {
                    [self backToHome];
                }
            }
            else {
                [_viewHome popToRootWithAnimated:YES completion:^{
                    [self updateControlState];
                }];
            }
        }break;
        case BarEventGoForward:
        {
            if ([self isWebPageMode]) {
                [_webPage goForward];
            }
            else {
                [self backToWebPage];
            }
        }break;
        case BarEventHome:
        {
            if ([self isWebPageMode]) {
                if (0!=_viewHome.pageIndex) {
                    _viewHome.pageIndex = 0;
                }
                
                if([_viewHome canPop]) {
                    [_viewHome popToRootWithAnimated:NO completion:nil];
                }
                
                [self backToHome];
            }
            else {
                [_viewHome nextPage];
            }
        }break;
        case BarEventMenu:
        {
            UIViewMenu *viewMenu = [UIViewMenu viewFromXib];
            _viewMenu = viewMenu;
            viewMenu.delegate = self;
            CGRect rc = [barItem convertRect:barItem.bounds toView:barItem.window.rootViewController.view];
            CGPoint point;
            DockDirection dockDirection;
            if (IsPortrait) {
                point = CGPointMake(CGRectGetMidX(rc), _viewBottomBar.top);
                dockDirection = DockDirectionBottom;
            }
            else {
                point = CGPointMake(CGRectGetMidX(rc), _viewTopBar.bottom);
                dockDirection = DockDirectionTop;
            }
            [viewMenu showInView:self.view centerOfDock:point dockDirection:dockDirection];
            
            [viewMenu setBrowserMode:[self isWebPageMode]];
            if ([self isWebPageMode]) {
                [viewMenu setBookmarkItemEnable:![ADOBookmark isExistWithLink:_webPage.link userId:[UserManager shareUserManager].currUser.uid]];
            }
        }break;
        case BarEventWindows:
        {
            [self showTabs:YES];
        }break;
            
        // ------------------------
        case BarEventRefresh:
        {
            [_webPage reload];
        }break;
        case BarEventStop:
        {
            [_webPage stop];
        }break;
        case BarEventQRCode:
        {
            UIControllerQRCode *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UIControllerQRCode"];
            controller.title = LocalizedString(@"saoerweima");
            controller.delegateQRCode = self;
            [self presentViewController:controller animated:YES completion:nil];
            [self presentViewController:controller animated:YES completion:nil];
        }break;
        case BarEventBookmark:
        {
            UIViewBookmarkPopAction *viewBookmarkPopAction = [UIViewBookmarkPopAction viewFromXib];
            viewBookmarkPopAction.delegate = self;
            NSInteger userId = [UserManager shareUserManager].currUser.uid;
            NSString *link = _webPage.link;
            [viewBookmarkPopAction setBookmarkIsExist:[ADOBookmark isExistWithLink:link userId:userId]];
            [viewBookmarkPopAction setHomeAppIsExist:[ADOApp isExistWithAppType:AppTypeWeb link:link urlSchemes:nil userId:userId]];
            CGRect rc = [barItem convertRect:barItem.bounds toView:barItem.window.rootViewController.view];
            CGPoint point  = CGPointMake(CGRectGetMidX(rc), _viewTopBar.bottom);
            [viewBookmarkPopAction showInView:self.view centerOfDock:point];
        }break;
        case BarEventSearchOption:
        {
            [_viewTopBar.textField resignFirstResponder];
            
            UIViewSearchOption *viewSearchOption = [UIViewSearchOption viewFromXib];
            viewSearchOption.delegate = self;
            CGRect rc = [barItem convertRect:barItem.bounds toView:barItem.window.rootViewController.view];
            CGPoint point  = CGPointMake(CGRectGetMidX(rc), _viewTopBar.bottom);
            [viewSearchOption showInView:self.view centerOfDock:point];
        }break;
        
        // ---------- 地址栏输入框事件
        case BarEventDidBeginInputUrl:
        {
            _viewTopBar.viewTopBarStatus = ViewTopBarStatusInput;
            if (_webPage.show) {
                _viewTopBar.textField.text = _webPage.link;
            }
            
            if (_viewSearchPanel) return;
            
            CGRect rc = [self mainFrame];
            rc.size.height+=_viewBottomBar.height;
            _viewSearchPanel = [UIViewSearchPanel viewFromXib];
            _viewSearchPanel.delegate = self;
            _viewSearchPanel.frame = rc;
            // 防止动画未结束就点击取消
            _viewTopBar.btnCancel.userInteractionEnabled = NO;
            [_viewSearchPanel showInView:self.view completion:^{
                _viewTopBar.btnCancel.userInteractionEnabled = YES;
                if (_viewTopBar.viewTopBarStatus!=ViewTopBarStatusWeb) {
                    [_viewHome removeFromSuperview];
                    [_webPage removeFromSuperview];
                }
            }];
        }break;
        case BarEventDidEndInputUrl:
        {
            _viewTopBar.viewTopBarStatus = ViewTopBarStatusWeb;
            [_viewSearchPanel dismiss];
            
            NSString *link = _viewTopBar.textField.text;
            if ([link isURLString]) {
                link = [link urlEncodeNormal];
                if (![[link lowercaseString] hasPrefix:@"http://"] && ![[link lowercaseString] hasPrefix:@"https://"]) {
                    link = [@"http://" stringByAppendingString:link];
                }
            }
            else {
                link = [_viewTopBar.searchEngine.link stringByAppendingString:[link urlEncodeNormal]];
            }
            
            [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
        }break;
        case BarEventCancelInputUrl:
        {
            // 将搜索面板给隐藏了
            _viewTopBar.viewTopBarStatus = _viewTopBar.viewTopBarStatusBeforeInput;
            [_viewTopBar.textField resignFirstResponder];
            [_viewSearchPanel dismiss];
            
            if (ViewTopBarStatusHome==_viewTopBar.viewTopBarStatus) {
                [self backToHome];
            }
            else if (ViewTopBarStatusWeb==_viewTopBar.viewTopBarStatus) {
                [self backToWebPage];
            }
        }break;
            
        default:
            break;
    }
}

// ---------------------------------- 菜单事件 -----------------
#pragma mark - UIViewMenuDelegate
- (void)viewMenu:(UIViewMenu *)viewMenu seletedMenuItem:(MenuItem)menuItem
{
    switch (menuItem) {
        case MenuItemBookmark:
        {
            UIViewPopBookmark *viewPop = [UIViewPopBookmark viewFromXib];
            [viewPop showInView:self.view completion:nil];
            [viewPop setCallbackWillAddToBookmark:^{
                if ([ADOBookmark isExistWithLink:_webPage.link userId:[UserManager shareUserManager].currUser.uid]) {
                    [SVProgressHUD showErrorWithStatus:LocalizedString(@"shuqianyicunzai")];
                    return;
                }
                
                ModelBookmark *model = [ModelBookmark model];
                model.userid = [UserManager shareUserManager].currUser.uid;
                model.lan = [LocalizationUtil currLanguage];
                model.title = _webPage.title;
                model.link = _webPage.link;
                model.isFolder = NO;
                model.parent_pkid = 0;
                model.updateTime = [[NSDate date] timeIntervalSince1970];
                /**
                 *  放在根目录
                 */
                model.sortIndex = [ADOBookmark queryMaxSortIndexWithParentPkid:model.parent_pkid userId:[UserManager shareUserManager].currUser.uid]+1;
                model.icon = FaviconWithLink(model.link);
                
                NSInteger pkid = [ADOBookmark addModel:model];
                if (pkid>0) {
                    model.pkid = pkid;
                    
                    // 同步添加 书签
                    if ([SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeBookmark]) {
                        [[SyncHelper shareSync] syncAddArrBookmark:@[model] completion:^{
                            
                        } fail:^(NSError *error) {
                            
                        }];
                    }
                    
                    [SVProgressHUD showImage:nil status:LocalizedString(@"yitianjiadaoshuqian")];
                    [_viewTopBar setBookmarkIconHighlighted:YES];
                }
            }];
            [viewPop setCallbackWillAddToHomeApp:^{
                if ([_scrollViewApp canAdd]) {
                    ModelApp *model = [ModelApp model];
                    model.lan = [LocalizationUtil currLanguage];
                    model.userid = [UserManager shareUserManager].currUser.uid;
                    model.title = _webPage.title;
                    model.link = _webPage.link;
                    model.appType = AppTypeWeb;
                    model.icon = [ADOLinkIcon queryWithLink:HostWithLink(model.link)];
                    NSInteger pkid = [ADOApp addModel:model];
                    if (pkid>0) {
                        model.pkid = pkid;
                        [_scrollViewApp addAppWithModel:model animated:YES];
                        
                        [SVProgressHUD showImage:nil status:LocalizedString(@"yitianjiadaoshouyeyingyongping")];
                    }
                }
                else {
                    [SVProgressHUD showImage:nil status:LocalizedString(@"shouyeyingyongshuliangyidadaoshangxian")];
                }
            }];
        }break;
        case MenuItemBookmarkHistory:
        {
            UIControllerBookmarkHistory * controller = [UIControllerBookmarkHistory controllerFromXib];
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
        }break;
        case MenuItemLanguage:
        {
            UIControllerLanguage *controller = [UIControllerLanguage controllerFromXib];
            controller.title = LocalizedString(@"yuyanshezhi");
            [self.navigationController pushViewController:controller animated:YES];
        }break;
        case MenuItemRefresh:
        {
            [_webPage reload];
        }break;
        case MenuItemStop:
        {
            [_webPage stop];
        }break;
        case MenuItemScreenshot:
        {
            UIControllerScreenshot *controller = [UIControllerScreenshot controllerFromXib];
            controller.delegate = self;
            controller.screenshotType = ScreenshotDraw;
            controller.imageOriginal = [UIImage imageFromView:self.view];
            [self.navigationController pushViewController:controller animated:NO];
        }break;
        case MenuItemFindInPage:
        {
            UIViewFindInWebPage *viewFindInWebPage = [UIViewFindInWebPage viewFromXib];
            viewFindInWebPage.delegate = self;
            [viewFindInWebPage showInView:_viewTopBar completion:^{
                [viewFindInWebPage.textField becomeFirstResponder];
            }];
            _viewFindInWebPage = viewFindInWebPage;
        }break;
        case MenuItemShare:
        {
            UIViewPopShareOption *viewPop = [UIViewPopShareOption viewFromXib];
            viewPop.labelTitle.text = LocalizedString(@"fenxiangdao");
            [viewPop setCallbackSelectShareType:^(ShareType shareType) {
                NSString *title = _webPage.show?_webPage.title:LocalizedString(@"zhonghualiulanqi");
                NSString *content = _webPage.show?[_webPage.title stringByAppendingFormat:@" %@", _webPage.link]:[LocalizedString(@"zhonghualiulanqi") stringByAppendingFormat:@" %@", kShareDefaultWebsite];
                SendShareContent(shareType,
                                 [UIImage imageFromView:_webPage.superview?_webPage:self.view opaque:YES],
                                 title,
                                 content,
                                 _webPage.show?_webPage.link:kShareDefaultWebsite);
            }];
            [viewPop showInView:self.view completion:nil];
        }break;
        case MenuItemProfile:
        {
            //个人中心
            //如果有用户信息 直接跳转到个人中心 否则进入登陆
            if ([UserManager shareUserManager].currUser) {
               
                UIControllerUserInfo *controllerUserInfo = [UIControllerUserInfo controllerFromXib];
                controllerUserInfo.fromController = FromControllerRoot;
                if(IsiPad)
                {
                    controllerUserInfo.modalPresentationStyle = UIModalPresentationFormSheet;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controllerUserInfo];
                    nav.modalPresentationStyle = UIModalPresentationFormSheet;
                    nav.navigationBarHidden = YES;
                    
                    [self presentViewController:nav animated:YES completion:nil];
                }
                else
                {
                    self.navigationController.navigationBarHidden = YES;
                    [self.navigationController pushViewController:controllerUserInfo animated:YES];
                    
                }
            }
            else
            {
                UIControllerLogin *ccontrollerLogin = [UIControllerLogin controllerFromXib];
                ccontrollerLogin.fromController = FromControllerRoot;
                if(IsiPad) {
                    ccontrollerLogin.modalPresentationStyle = UIModalPresentationFormSheet;
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ccontrollerLogin];
                    nav.modalPresentationStyle = UIModalPresentationFormSheet;
                    nav.navigationBarHidden = YES;
                    [self presentViewController:nav animated:YES completion:nil];
                    
                }
                else
                {
                    [self.navigationController pushViewController:ccontrollerLogin animated:YES];
                }
            }
        }break;
        case MenuItemNoImageMode:
        {
            BOOL noImageMode = [AppSetting shareAppSetting].noImageMode;
            [AppSetting shareAppSetting].noImageMode = !noImageMode;
            viewMenu.viewMenuItemNoImageMode.selected = [AppSetting shareAppSetting].noImageMode;
            _webManager.noImageMode = [AppSetting shareAppSetting].noImageMode;
        }break;
        case MenuItemFullscreenMode:
        {
            BOOL fullscreenMode = [AppSetting shareAppSetting].fullscreenMode;
            [AppSetting shareAppSetting].fullscreenMode = !fullscreenMode;
            viewMenu.viewMenuItemFullscreen.selected = [AppSetting shareAppSetting].fullscreenMode;
            
            _scrollToChangeFullscreenEnable = [AppSetting shareAppSetting].fullscreenMode;
            
            if ([self isWebPageMode]) {
                [UIView animateWithDuration:0.35 animations:^{
                    if ([AppSetting shareAppSetting].fullscreenMode) {
                        [self enterFullscreenMode];
                    }
                    else {
                        [self exitFullscreenMode];
                    }
                }];
            }
        }break;
        case MenuItemSetBrightness:
        {
            UIViewPopSetBrightness *viewPop = [UIViewPopSetBrightness viewFromXib];
            viewPop.labelTitle.text = LocalizedString(@"liangdutiaojie");
            [viewPop showInView:self.view completion:nil];
        }break;
        case MenuItemNoSaveHistory:
        {
            BOOL noSaveHistory = [AppSetting shareAppSetting].noSaveHistory;
            [AppSetting shareAppSetting].noSaveHistory = !noSaveHistory;
            viewMenu.viewMenuItemNoSaveHistory.selected = [AppSetting shareAppSetting].noSaveHistory;
        }break;
        case MenuItemQRCode:
        {
            UIControllerQRCode *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UIControllerQRCode"];
            controller.delegateQRCode = self;
            controller.title = LocalizedString(@"saoerweima");
            [self presentViewController:controller animated:YES completion:nil];
        }break;
        case MenuItemSkinManage:
        {
            UIControllerSetSkin *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UIControllerSetSkin"];
            controller.title = LocalizedString(@"pifuguanli");
            controller.delegate = self;
            [self.navigationController pushViewController:controller animated:YES];
        }break;
        case MenuItemDesktopStyle:
        {
            UIControllerDesktopStyle *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UIControllerDesktopStyle"];
            controller.title = LocalizedString(@"zhuomianyangshi");
            
            [self.navigationController pushViewController:controller animated:YES];
        }break;
        case MenuItemSystemSettings:
        {
            UIControllerSysSettings *controller = [UIControllerSysSettings controllerFromXib];
            controller.title = LocalizedString(@"xitongshezhi");
            [self.navigationController pushViewController:controller animated:YES];
        }break;
        case MenuItemDownload:
        {
            
        }break;
        case MenuItemFeedback:
        {
            UIControllerWebview *controllerWebview = [[UIControllerWebview alloc] init];
            controllerWebview.link = GetApiWithName(API_Feedback);
            controllerWebview.title = LocalizedString(@"yijianfankui");
            [self.navigationController pushViewController:controllerWebview animated:YES];
        }break;
        case MenuItemSaveTraffic:
        {
            
        }break;
        case MenuItemCheckVersion:
        {
            [CheckVersion checkVersionAtLaunch:NO];
        }break;
        case MenuItemExit:
        {
            
        }break;
            
        default:
            break;
    }
}

// ---------------------------------- 点击地址栏书签按钮 事件 -----------------
#pragma mark - UIViewBookmarkPopActionDelegate
- (void)viewBookmarkPopAction:(UIViewBookmarkPopAction *)viewBookmarkPopAction bookmarkPopAction:(BookmarkPopAction)bookmarkPopAction
{
    switch (bookmarkPopAction) {
        case BookmarkPopActionAddBookmark:
        {
            if ([ADOBookmark isExistWithLink:_webPage.link userId:[UserManager shareUserManager].currUser.uid]) {
                [SVProgressHUD showErrorWithStatus:LocalizedString(@"shuqianyicunzai")];
                return;
            }
            
            ModelBookmark *model = [ModelBookmark model];
            model.userid = [UserManager shareUserManager].currUser.uid;
            model.lan = [LocalizationUtil currLanguage];
            model.title = _webPage.title;
            model.link = _webPage.link;
            model.isFolder = NO;
            model.parent_pkid = 0;
            model.updateTime = [[NSDate date] timeIntervalSince1970];
            /**
             *  放在根目录
             */
            model.sortIndex = [ADOBookmark queryMaxSortIndexWithParentPkid:model.parent_pkid userId:[UserManager shareUserManager].currUser.uid]+1;
            model.icon = FaviconWithLink(model.link);
            
            NSInteger pkid = [ADOBookmark addModel:model];
            if (pkid>0) {
                model.pkid = pkid;
                [viewBookmarkPopAction setBookmarkIsExist:YES];
                
                // 同步添加 书签
                if ([SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeBookmark]) {
                    [[SyncHelper shareSync] syncAddArrBookmark:@[model] completion:^{
                        
                    } fail:^(NSError *error) {
                        
                    }];
                }
                
                [SVProgressHUD showImage:nil status:LocalizedString(@"yitianjiadaoshuqian")];
            }
        }break;
        case BookmarkPopActionRemoveBookmark:
        {
            ModelBookmark *modelBookmark = [ADOBookmark queryWithLink:_webPage.link userId:[UserManager shareUserManager].currUser.uid];
            if ([ADOBookmark deleteWithPkid:modelBookmark.pkid]) {
                
                if (modelBookmark.pkid_server>0) {
                    ModelSyncDelete *modelSyncDelete = [ModelSyncDelete modelWithPkidServer:modelBookmark.pkid_server syncDataType:SyncDataTypeBookmark userId:modelBookmark.userid];
                    modelSyncDelete.pkid = [ADOSyncDelete addModel:modelSyncDelete];
                    if (modelSyncDelete.pkid>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeBookmark]) {
                        [[SyncHelper shareSync] syncDeleteBookmarkWithArrSyncDelete:@[modelSyncDelete] completion:^{
                            
                        } fail:^(NSError *error) {
                            
                        }];
                    }
                }
                
                [viewBookmarkPopAction setBookmarkIsExist:NO];
                [SVProgressHUD showImage:nil status:LocalizedString(@"yicongshuqianyichu")];
            }
        }break;
        case BookmarkPopActionAddHomeApp:
        {
            if ([_scrollViewApp canAdd]) {
                ModelApp *model = [ModelApp model];
                model.lan = [LocalizationUtil currLanguage];
                model.userid = [UserManager shareUserManager].currUser.uid;
                model.title = _webPage.title;
                model.link = _webPage.link;
                model.icon = [ADOLinkIcon queryWithLink:HostWithLink(model.link)];
                model.appType = AppTypeWeb;
                NSInteger pkid = [ADOApp addModel:model];
                if (pkid>0) {
                    model.pkid = pkid;
                    [_scrollViewApp addAppWithModel:model animated:YES];
                    
                    [viewBookmarkPopAction setHomeAppIsExist:YES];
                    [SVProgressHUD showImage:nil status:LocalizedString(@"yitianjiadaoshouyeyingyongping")];
                }
            }
            else {
                [SVProgressHUD showImage:nil status:LocalizedString(@"shouyeyingyongshuliangyidadaoshangxian")];
            }
        }break;
        case BookmarkPopActionRemoveHome:
        {
            if ([ADOApp deleteWithWebAppWithLink:_webPage.link userId:[UserManager shareUserManager].currUser.uid]) {
                [_scrollViewApp removeWithLink:_webPage.link];
                [viewBookmarkPopAction setHomeAppIsExist:NO];
                [SVProgressHUD showImage:nil status:LocalizedString(@"yicongshouyeyingyongpingshanchu")];
            }
        }break;
        default:
            break;
    }
    
    [_viewTopBar setBookmarkIconHighlighted:viewBookmarkPopAction.bookmarkIsExist];
}

// ---------------------------------- 搜索选项相关 事件 -----------------
#pragma mark - UIViewSearchOptionDelegate
- (void)viewSearchOption:(UIViewSearchOption *)viewSearchOption didSelectSearchEngine:(ModelSearchEngine *)searchEngine
{
    [_viewTopBar setSearchEngine:searchEngine];
    [_viewTopBar.textField becomeFirstResponder];
    _viewTopBar.viewTopBarStatus = ViewTopBarStatusInput;
}

// ---------------------------------- 情景翻译分类 事件 -----------------
#pragma mark - UIScrollViewTransDelegate
- (void)scrollViewTrans:(UIScrollViewTrans *)scrollViewTrans onTouchCate:(ModelSentenceCate *)modelCate
{
    UIControllerTrans *controllerTrans = [UIControllerTrans controllerFromXib];
    controllerTrans.title = LocalizedString(@"qingjingfanyi");
    controllerTrans.modelCate = modelCate;
    [self.navigationController pushViewController:controllerTrans animated:YES];
}

- (void)scrollViewTrans:(UIScrollViewTrans *)scrollViewTrans reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

// ---------------------------------- 旅游模块 -----------------
#pragma mark - UIScrollViewTravelDelegate
- (void)scrollViewTravel:(UIScrollViewTravel *)scrollViewTravel reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

- (void)scrollViewTravel:(UIScrollViewTravel *)scrollViewTravel selectProvince:(ModelTravelProvince *)province
{
    UIControllerTravelDetail *controller = [UIControllerTravelDetail controllerFromXib];
    controller.delegate = self;
    controller.provinceId = province.provinceId;
    controller.imageUrl = province.image;
    controller.imageSize = province.imageSize;
    controller.title = province.name;
    [self.navigationController pushViewController:controller animated:YES];
}

// ---------------------------------- 旅游模块 -----------------
#pragma mark - UIControllerTravelDetailDelegate
- (void)controllerTravelDetail:(UIControllerTravelDetail *)controllerTravelDetail reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

// -------------------------------- 书签历史记录 -----------------
#pragma mark - UIControllerBookmarkHistoryDelegate
- (void)controllerBookmarkHistory:(UIControllerBookmarkHistory *)controllerBookmarkHistory reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

// ---------------------------------- 推荐屏 -----------------
#pragma mark - UIScrollViewRecommendDelegate
- (void)scrollViewRecommend:(UIScrollViewRecommend *)scrollViewRecommend reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

- (void)scrollViewRecommend:(UIScrollViewRecommend *)scrollViewRecommend reqNewsWithCateId:(NSInteger)cateId cateName:(NSString *)cateName;
{
    UIViewNews *viewNews = [UIViewNews viewFromXib];
    viewNews.cateId = cateId;
    viewNews.cateName = cateName;
    viewNews.delegate = self;
    [_viewHome pushView:viewNews animated:YES completion:^{
        [viewNews refreshData];
        [self updateControlState];
    }];
}

- (void)scrollViewRecommend:(UIScrollViewRecommend *)scrollViewRecommend reqSubCateWithCateId:(NSInteger)cateId
{
    UIViewRecommendSubCate *viewRecommendSubCate = [UIViewRecommendSubCate viewFromXib];
    viewRecommendSubCate.cateId = cateId;
    viewRecommendSubCate.delegate = self;
    [_viewHome pushView:viewRecommendSubCate animated:YES completion:^{
        [viewRecommendSubCate refreshData];
        [self updateControlState];
    }];
}

// ---------------------------------- 推荐屏 新闻列表 -----------------
#pragma mark - UIViewNewsDelegate
- (void)viewNews:(UIViewNews *)viewNews reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

// ---------------------------------- 推荐屏 子分类 -----------------
#pragma mark - UIViewRecommendSubCateDelegate
- (void)viewRecommendSubCate:(UIViewRecommendSubCate *)viewRecommendSubCate reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

// ---------------------------------- 应用屏 -----------------
#pragma mark - UIScrollViewAppDelegate
- (void)scrollViewApp:(UIScrollViewApp *)scrollViewApp openModel:(ModelApp *)model
{
    switch (model.appType) {
        case AppTypeWeb:
        {
            [self handleLink:model.link urlOpenStyle:UrlOpenStyleCurrent];
        }break;
        case AppTypeNative:
        {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.urlSchemes]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"") delegate:nil cancelButtonTitle:LocalizedString(@"quxiao") otherButtonTitles:LocalizedString(@"xiazai"), nil];
                [alert showWithCompletionHandler:^(NSInteger buttonIndex) {
                    if (alert.cancelButtonIndex==buttonIndex) {
                        return;
                    }
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.downloadLink]];
                }];
            }
        }break;
        case AppTypeFunc:
        {
            
        }break;
            
        default:
            break;
    }
}

- (void)scrollViewApp:(UIScrollViewApp *)scrollViewApp edit:(BOOL)edit
{
    [_viewHome setScrollEnable:!edit];
    [_viewTopBar setEditingApp:edit];
    
    if (edit) {
        _btnCancelEditApp = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnCancelEditApp setTitle:LocalizedString(@"wancheng") forState:UIControlStateNormal];
        [_btnCancelEditApp setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_btnCancelEditApp setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _btnCancelEditApp.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        [_btnCancelEditApp addTarget:self action:@selector(onTouchCancelEditApp) forControlEvents:UIControlEventTouchUpInside];
        CGRect rc = _viewBottomBar.frame;
        if (!IsPortrait) {
            rc.size.height = 32;
        }
        rc.origin.y = self.view.height-rc.size.height;
        
        _btnCancelEditApp.frame = rc;
        _btnCancelEditApp.transform = CGAffineTransformMakeTranslation(0, _btnCancelEditApp.height);
        [self.view addSubview:_btnCancelEditApp];
        
        [UIView animateWithDuration:0.3 animations:^{
            _btnCancelEditApp.transform = CGAffineTransformIdentity;
            CGRect rc = _viewBottomBar.frame;
            rc.origin.y = self.view.height;
            _viewBottomBar.frame = rc;
            
            _viewHome.frame = [self mainFrame];
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            _btnCancelEditApp.transform = CGAffineTransformMakeTranslation(0, _btnCancelEditApp.height);
            
            CGRect rc = _viewBottomBar.frame;
            rc.origin.y = self.view.height-(IsPortrait?_viewBottomBar.height:0);
            _viewBottomBar.frame = rc;
            
            _viewHome.frame = [self mainFrame];
            _webPage.frame = [self mainFrame];
        } completion:^(BOOL finished) {
            [_btnCancelEditApp removeFromSuperview];
            _btnCancelEditApp = nil;
        }];
    }
}

- (void)scrollViewAppWillAddItem:(UIScrollViewApp *)scrollViewAp
{
    UIControllerLabelsList *controller = [UIControllerLabelsList controllerFromXib];
    controller.callbackAddApp = ^(ModelApp *model){
        [_scrollViewApp addAppWithModel:model animated:NO];
    };
    controller.callbackIsExistApp = ^(ModelApp *model) {
        return [_scrollViewApp isExistWithType:model.appType link:model.link urlSchemes:model.urlSchemes];
    };
    controller.callbackCanAddApp = ^{
        return [_scrollViewApp canAdd];
    };
    controller.callbackOpen = ^(ModelApp *model) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self scrollViewApp:_scrollViewApp openModel:model];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)scrollViewApp:(UIScrollViewApp *)scrollViewApp willEditItem:(ModelApp *)model viewAppItem:(UIControlItemApp *)viewAppItem
{
    UIControllerManuallyAdd *manuallyAdd = [UIControllerManuallyAdd controllerFromXib];
    manuallyAdd.callbackDidEdit = ^(ModelApp *editModel){
        editModel.updateTime = [[NSDate date] timeIntervalSince1970];
        if ([ADOApp updateModel:editModel]) {
            viewAppItem.labelTitle.text = model.title;
            if (editModel.icon.length<=0) {
                viewAppItem.imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/App/ic_app_default.png"];
            }
            else {
                __unsafe_unretained UIImageView *wImageViewIcon = viewAppItem.imageViewIcon;
                [viewAppItem.imageViewIcon setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageWithBundleFile:@"iPhone/App/ic_app_default.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (!image) {
                        wImageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/App/ic_app_default.png"];
                    }
                    else {
                        wImageViewIcon.image = image;
                        [KTAnimationKit animationEaseIn:wImageViewIcon];
                    }
                }];
            }
        }
    };
    manuallyAdd.editApp = model;
    manuallyAdd.title = LocalizedString(@"bianji");
    [self.navigationController pushViewController:manuallyAdd animated:YES];
    
    _DEBUG_LOG(@"%s", __FUNCTION__);
}

- (void)onTouchCancelEditApp
{
    _scrollViewApp.edit = NO;
}

// ---------------------------------- 个性化定制(定时提醒) -----------------
#pragma mark - UITableViewModeDelegate
- (void)tableViewModeWillAdd:(UITableViewMode *)tableViewMode
{
    // 新增的模式，一定不是 当前选中的模式，所以不用操作 FM通知 模块，如果需求是新建模式后就选择该模式，则必须要 操作 FM通知 模块
    UIControllerAddProgram *controller = [UIControllerAddProgram controllerFromXib];
    controller.title = LocalizedString(@"xinjianmoshi");
    controller.actionType = ProgramActionTypeAddMode;
    [controller setCallbackDidAddMode:^(ModelMode *modelMode) {
        [_tableViewMode addMode:modelMode];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewMode:(UITableViewMode *)tableViewMode willRenameName:(NSString *)name
{
    UIControllerRename *controllerRename = [UIControllerRename controllerFromXib];
    controllerRename.title = LocalizedString(@"chongmingming");
    controllerRename.text = name;
    [controllerRename setCallbackDidEdit:^(NSString *text) {
        [_tableViewMode setEditingModeName:text];
    }];
    [self.navigationController pushViewController:controllerRename animated:YES];
}

- (void)tableViewMode:(UITableViewMode *)tableViewMode showDetailMode:(ModelMode *)modelMode
{
    UIControllerModeDetail *controllerModeDetail = [UIControllerModeDetail controllerFromXib];
    controllerModeDetail.modelMode = modelMode;
    controllerModeDetail.title = modelMode.name;
    [controllerModeDetail setCallbackGetCurrModePkid:^NSInteger{
        return _tableViewMode.currModePkid;
    }];
    [controllerModeDetail setCallbackDidUpdateMode:^(NSInteger modePkid) {
        [_tableViewMode updatePListIfNeedWithModePkid:modePkid];
    }];
    [self.navigationController pushViewController:controllerModeDetail animated:YES];
}

// ---------------------------------- 二维码扫描结果 事件 -----------------
#pragma mark - QRCodeProtocol
- (void)controller:(UIViewController *)controller didReadContent:(NSString *)content
{
    [controller dismissViewControllerAnimated:YES completion:^{
        NSString *link = content;
        if ([link isURLString]) {
            link = [link urlEncodeNormal];
            if (![[link lowercaseString] hasPrefix:@"http://"] && ![[link lowercaseString] hasPrefix:@"https://"]) {
                link = [@"http://" stringByAppendingString:link];
            }
            [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
        }
        else {
            link = [_viewTopBar.searchEngine.link stringByAppendingString:[link urlEncodeNormal]];
        }
        
        [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
    }];
}

// ---------------------------------- 截图 -----------------
#pragma mark - UIControllerScreenshotDelegate
- (void)controller:(UIControllerScreenshot *)controller didCaptureImage:(UIImage *)image
{
    UIControllerDrawView *vc = [UIControllerDrawView UIControllerDrawViewFromXib];
    vc.bgImge = image;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }
    else {
        [SVProgressHUD showSuccessWithStatus:LocalizedString(@"tupianbaocunchenggong")];
    }
}

// ---------------------------------- 皮肤设置 -----------------
#pragma mark - UIControllerSetSkinDelegate
- (void)controllerSetSkinDidChanageSkin:(UIControllerSetSkin *)controllerSetSkin
{
    [self.view setBgImageWithScaleAspectFillImage:[AppSetting shareAppSetting].skinImage];
    _DEBUG_LOG(@"%s", __FUNCTION__);
}

// ---------------------------------- 搜索面板 -----------------
#pragma mark - UIViewSearchPanelDelegate
- (void)viewSearchPanel:(UIViewSearchPanel *)viewSearchPanel reqLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

- (void)viewSearchPanelWillDismiss:(UIViewSearchPanel *)viewSearchPanel
{
    _viewTopBar.viewTopBarStatus = _viewTopBar.viewTopBarStatusBeforeInput;
    [_viewTopBar.textField resignFirstResponder];
    
    
    if (ViewTopBarStatusHome==_viewTopBar.viewTopBarStatus) {
        [self backToHome];
    }
    else if (ViewTopBarStatusWeb==_viewTopBar.viewTopBarStatus) {
        [self backToWebPage];
    }
    
    _viewTopBar.userInteractionEnabled = NO;
    [_viewSearchPanel dismissWithCompletion:^{
        _viewTopBar.userInteractionEnabled = YES;
    }];
    
}

// ---------------------------------- 页内查找 -----------------
#pragma mark - UIViewFindInWebPageDelegate
- (void)viewFindInWebPageDidBegin:(UIViewFindInWebPage *)viewFindInWebPage
{
    CGRect rc = _viewBottomBar.frame;
    rc.origin.y = self.view.height;
    [UIView animateWithDuration:0.35 animations:^{
        _viewBottomBar.frame = rc;
        _webPage.frame = [self mainFrame];
    }];
    
    [_webPage beginFindInPage];
}

- (void)viewFindInWebPageDidEnd:(UIViewFindInWebPage *)viewFindInWebPage
{
    CGRect rc = _viewBottomBar.frame;
    rc.origin.y = self.view.height-(IsPortrait?_viewBottomBar.height:0);
    [UIView animateWithDuration:0.35 animations:^{
        _viewBottomBar.frame = rc;
        _webPage.frame = [self mainFrame];
    }];
    
    [_webPage endFindInPage];
}

- (void)viewFindInWebPage:(UIViewFindInWebPage *)viewFindInWebPage findWithKeyword:(NSString *)keyword
{
    viewFindInWebPage.number = [_webPage findInPageWithKeyword:keyword];
    viewFindInWebPage.currIndex = _webPage.indexOfKeyrowd;
}

- (void)viewFindInWebPageFindPrev:(UIViewFindInWebPage *)viewFindInWebPage
{
    [_webPage scrollToPrevKeyword];
    viewFindInWebPage.currIndex = _webPage.indexOfKeyrowd;
}

- (void)viewFindInWebPageFindNext:(UIViewFindInWebPage *)viewFindInWebPage
{
    [_webPage scrollToNextKeyword];
    viewFindInWebPage.currIndex = _webPage.indexOfKeyrowd;
}

// ------------------------------ 处理启动操作 操作 AppLaunchDelegate -----------------
#pragma mark - AppLaunchDelegate
- (void)appLaunchOpenRecommendCateId:(NSInteger)cateid cateName:(NSString *)cateName
{
    void (^domain)()=^{
        if ([_viewHome canPop]) {
            [_viewHome popToRootWithAnimated:YES completion:^{
                UIViewNews *viewNews = [UIViewNews viewFromXib];
                viewNews.cateId = cateid;
                viewNews.cateName = cateName;
                viewNews.delegate = self;
                [_viewHome pushView:viewNews animated:YES completion:^{
                    [viewNews refreshData];
                }];
            }];
        }
        else {
            UIViewNews *viewNews = [UIViewNews viewFromXib];
            viewNews.cateId = cateid;
            viewNews.cateName = cateName;
            viewNews.delegate = self;
            [_viewHome pushView:viewNews animated:YES completion:^{
                [viewNews refreshData];
            }];
        }
    };
    
    if (_webPage.show) {
        [self backToHomeWithAnimated:NO completion:^{
            domain();
        }];
    }
    else {
        domain();
    }
}

- (void)appLaunchOpenLink:(NSString *)link
{
    [self handleLink:link urlOpenStyle:UrlOpenStyleCurrent];
}

// ------------------------------ 网页回调处理 WebPageManageDelegate -----------------
#pragma mark - WebPageManageDelegate
/**
 *  请求打开链接
 *
 *  @param webPageManage WebPageManage
 *  @param link        链接地址
 *  @param UrlOpenStyle 链接打开方式
 */
- (void)webPageManage:(WebPageManage *)webPageManage reqLink:(NSString *)link UrlOpenStyle:(UrlOpenStyle)UrlOpenStyle
{
    [self handleLink:link urlOpenStyle:UrlOpenStyle];
}

/**
 *  开始加载, 外部接受此事件后 要显示 停止按钮
 *
 *  @param webPageManage WebPageManage
 *  @param index       索引
 */
- (void)webPageManageDidStartLoad:(WebPageManage *)webPageManage atIndex:(NSInteger)index
{
    if (index==_webManager.currWebPageIndex) {
        _viewTopBar.btnRefresh.hidden = YES;
        _viewTopBar.btnStop.hidden = NO;
    }
}

/**
 *  结束加载, 外部接受此事件后 要显示 刷新按钮
 *
 *  @param webPageManage WebPageManage
 *  @param index       索引
 */
- (void)webPageManageDidEndLoad:(WebPageManage *)webPageManage atIndex:(NSInteger)index
{
    if (index==_webManager.currWebPageIndex) {
        _viewTopBar.btnRefresh.hidden = NO;
        _viewTopBar.btnStop.hidden = YES;
    }
}

/**
 *  标题已更新
 *
 *  @param webPageManage WebPageManage
 *  @param title       网页标题
 *  @param index       索引
 */
- (void)webPageManage:(WebPageManage *)webPageManage didUpdateTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([self isWebPageMode] && index==_webManager.currWebPageIndex) {
        [self updateControlState];
    }
    
    // 仅修改历史记录的标题
    UIWebPage *webPage = [_webManager webPageAtIndex:index];
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    [ADOHistory updateTitle:title time:time updateTime:time withLink:webPage.link userId:[UserManager shareUserManager].currUser.uid];
    
    if (_viewScrollPreviewTab.show) {
        [_viewScrollPreviewTab updateTitle:webPage.titleOfShow atIndex:index];
    }
}

/**
 *  网页链接
 *
 *  @param webPageManage WebPageManage
 *  @param link        网页链接
 *  @param index       索引
 */
- (void)webPageManage:(WebPageManage *)webPageManage didUpdateLink:(NSString *)link atIndex:(NSInteger)index
{
    if ([self isWebPageMode] && index==_webManager.currWebPageIndex) {
        [_viewTopBar setBookmarkIconHighlighted:[ADOBookmark isExistWithLink:link userId:[UserManager shareUserManager].currUser.uid]];
        [self updateControlState];
    }
    
    UIWebPage *webPage = [_webManager webPageAtIndex:index];
    [self recordHistoryWithWebPage:webPage];
}

/**
 *  松手回到首页
 *
 *  @param webPageManage WebPageManage
 */
- (void)webPageManageWillEndDragBackHome:(WebPageManage *)webPageManage atInex:(NSInteger)index
{
    [self backToHome];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_scrollToChangeFullscreenEnable) {
        return;
    }
    
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:self.view];
    BOOL canChangeFullscreenMode = velocity.x==0 && velocity.y!=0;
    if ([AppSetting shareAppSetting].fullscreenMode && canChangeFullscreenMode) {
        
        if (velocity.y>0 && _viewTopBar.top<0) {
            // 下滚 退出全屏
            _scrollToChangeFullscreenEnable = NO;
            [UIView animateWithDuration:0.35 animations:^{
                [self exitFullscreenMode];
            } completion:^(BOOL finished) {
                _scrollToChangeFullscreenEnable = YES;
            }];
        }
        else if (velocity.y<0 && _viewTopBar.top==0) {
            // 上滚 进入全屏
            _scrollToChangeFullscreenEnable = NO;
            [UIView animateWithDuration:0.35 animations:^{
                [self enterFullscreenMode];
            } completion:^(BOOL finished) {
                _scrollToChangeFullscreenEnable = YES;
            }];
        }
    }
}

#pragma mark - UIViewScrollPreviewTabDelegate
- (NSString *)titleForTabViewScrollPreviewTab:(UIViewScrollPreviewTab *)viewScrollPreviewTab atIndex:(NSInteger)index
{
    UIWebPage *webPage = [_webManager webPageAtIndex:index];
    return webPage.show?webPage.titleOfShow:LocalizedString(@"qishiye");
}

- (void)viewScrollPreviewTab:(UIViewScrollPreviewTab *)viewScrollPreviewTab didRemoveAtIndex:(NSInteger)removeAtIndex newIndex:(NSInteger)newIndex
{
    [_webManager removeAtIndex:removeAtIndex];
    _viewTopBar.numberOfWinds =
    _viewBottomBar.numberOfWinds = _webManager.numberOfWebPage;
    
    [_viewTabBottom setAllowNew:_webManager.numberOfWebPage<kMaxWebViewNumber];
    
    if (newIndex>=0) {
        _webManager.currWebPageIndex = newIndex;
    }
    else {
        [self newWebPageWithLink:nil toBeActive:YES animated:NO];
        
        _viewScrollPreviewTab.alpha = 0;
        [self.view addSubview:_viewHome];
        _imageHomeScreenshot = [UIImage imageFromView:self.view rect:self.mainFrame];
        [_viewHome removeFromSuperview];
        _viewScrollPreviewTab.alpha = 1;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        imageView.image = _imageHomeScreenshot;
        [_viewHome removeFromSuperview];
        [viewScrollPreviewTab newThumbWithPreviewView:imageView];
    }
}

- (void)viewScrollPreviewTabDidSelect:(UIViewScrollPreviewTab *)viewScrollPreviewTab selectIndex:(NSInteger)selectIndex
{
    _webManager.currWebPageIndex = selectIndex;
    if (_webManager.currWebPage!=_webPage) {
        _webPage.transform = CGAffineTransformIdentity;
        [_webPage removeFromSuperview];
        
        _webPage = _webManager.currWebPage;
        _webPage.transform = CGAffineTransformIdentity;
        _webPage.center = _viewHome.center;
    }
    
    if (_webPage.show) {
        [self.view insertSubview:_webPage belowSubview:_viewBottomBar];
        _viewTopBar.viewTopBarStatus = ViewTopBarStatusWeb;
    }
    else {
        [self.view insertSubview:_viewHome belowSubview:_viewHome];
        _viewTopBar.viewTopBarStatus = ViewTopBarStatusHome;
    }
    
    if (_webPage.hasSnapshot) {
        [_webPage reload];
    }
    
    [self updateControlState];
}

- (void)viewScrollPreviewTabWillSelect:(UIViewScrollPreviewTab *)viewScrollPreviewTab selectIndex:(NSInteger)selectIndex
{
    [self updateControlStateWithWebPage:[_webManager webPageAtIndex:selectIndex]];
}

- (void)viewScrollPreviewTabWillDismiss:(UIViewScrollPreviewTab *)viewScrollPreviewTab
{
    [self showTabs:NO];
}

@end