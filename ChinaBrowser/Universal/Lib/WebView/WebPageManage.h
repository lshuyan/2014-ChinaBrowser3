//
//  WebPageManage.h
//  Browser-Touch
//
//  Created by David on 14-5-22.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIWebPage.h"

@protocol WebPageManageDelegate;

@interface WebPageManage : NSObject <UIWebPageDelegate>

@property (nonatomic, weak) id<WebPageManageDelegate> delegate;

/**
 *  字体比例(字体大小)
 */
@property (nonatomic, assign) CGFloat fontScale;
/**
 *  无图模式
 */
@property (nonatomic, assign) BOOL noImageMode;

/**
 *  当前网页 索引
 */
@property (nonatomic, assign) NSInteger currWebPageIndex;

/**
 *  当前网页 UIWebPage
 */
@property (nonatomic, weak, readonly) UIWebPage *currWebPage;

/**
 *  网页数量
 */
@property (nonatomic, assign, readonly) NSInteger numberOfWebPage;

/**
 *  网页 UIWebPage
 */
@property (nonatomic, assign, readonly) NSArray *arrWebPage;

/**
 *  新建一个网页（后台打开链接 可用）
 *
 *  @param frame 网页frame
 */
- (void)newWebPageWithFrame:(CGRect)frame;
/**
 *  新建网页
 *
 *  @param frame 网页frame
 *
 *  @return UIWebPage
 */
- (UIWebPage *)newWebPageAndReturnWithFrame:(CGRect)frame;

/**
 *  删除指定网页
 *
 *  @param index 索引
 */
- (void)removeAtIndex:(NSInteger)index;
/**
 *  删除最后一个对象（网页）（add by david at 2014.08.06 17:07:05）
 */
- (void)removeLastObject;

/**
 *  删除网页
 *
 *  @param webPage UIWebPage
 */
- (void)removeWebPage:(UIWebPage *)webPage;

/**
 *  从顶部删除一个（排除currWebPage）
 */
- (void)removeAtTopExceptCurrWebPage;

- (UIWebPage *)webPageAtIndex:(NSInteger)index;

/**
 *  用一个新网页来替换某个索引处的网页（add by david at 2014.08.06 17:07:05）
 *
 *  @param index 即将替换的网页的索引
 *
 *  @return 返回一个已经替换的网页
 */
- (UIWebPage *)replaceWithNewWebPageAtIndex:(NSInteger)index;

/**
 *  用一个新网页来替换某个网页（add by david at 2014.08.06 17:07:05）
 *
 *  @param webPage 即将替换的网页
 *
 *  @return 返回一个已经替换的网页
 */
- (UIWebPage *)replaceWithNewWebPage:(UIWebPage *)webPage;

/**
 *  将当前网页移动到最底部
 */
- (void)moveCurrPageToLast;

/**
 *  将当前网页移动到顶部
 */
- (void)moveCurrPageToHead;

/**
 *  设置当前网页
 *
 *  @param currWebPage UIWebPage, currWebPage 必须存在于当前的容器中，否则设置无效
 */
- (void)setCurrWebPage:(UIWebPage *)currWebPage;

/**
 *  通过原始链接地址查找网页
 *
 *  @param linkOrigin 原始链接地址
 *
 *  @return UIWebPage
 */
- (UIWebPage *)findWebPageWithOriginLink:(NSString *)linkOrigin;

@end

@protocol WebPageManageDelegate <NSObject, UIScrollViewDelegate>

@optional
/**
 *  请求打开链接
 *
 *  @param webPageManage WebPageManage
 *  @param link        链接地址
 *  @param UrlOpenStyle 链接打开方式
 */
- (void)webPageManage:(WebPageManage *)webPageManage reqLink:(NSString *)link UrlOpenStyle:(UrlOpenStyle)UrlOpenStyle;

/**
 *  开始加载, 外部接受此事件后 要显示 停止按钮
 *
 *  @param webPageManage WebPageManage
 *  @param index       索引
 */
- (void)webPageManageDidStartLoad:(WebPageManage *)webPageManage atIndex:(NSInteger)index;

/**
 *  结束加载, 外部接受此事件后 要显示 刷新按钮
 *
 *  @param webPageManage WebPageManage
 *  @param index       索引
 */
- (void)webPageManageDidEndLoad:(WebPageManage *)webPageManage atIndex:(NSInteger)index;

/**
 *  标题已更新
 *
 *  @param webPageManage WebPageManage
 *  @param title       网页标题
 *  @param index       索引
 */
- (void)webPageManage:(WebPageManage *)webPageManage didUpdateTitle:(NSString *)title atIndex:(NSInteger)index;

/**
 *  网页链接
 *
 *  @param webPageManage WebPageManage
 *  @param link        网页链接
 *  @param index       索引
 */
- (void)webPageManage:(WebPageManage *)webPageManage didUpdateLink:(NSString *)link atIndex:(NSInteger)index;

/**
 *  松手回到首页
 *
 *  @param webPageManage WebPageManage
 */
- (void)webPageManageWillEndDragBackHome:(WebPageManage *)webPageManage atInex:(NSInteger)index;

@end