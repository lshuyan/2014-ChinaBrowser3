//
//  UIViewHome.h
//  ChinaBrowser
//
//  Created by David on 14-9-27.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewHome : UIView

/**
 *  是否可以弹出
 */
@property (nonatomic, assign, readonly) BOOL canPop;

/**
 *  页码
 */
@property (nonatomic, assign) NSInteger pageIndex;

/**
 *  总页数
 */
@property (nonatomic, assign, readonly) NSInteger numberOfPages;

/**
 *  翻页
 *
 *  @param pageIndex pageIndex description
 *  @param animated  animated description
 */
- (void)setPageIndex:(NSInteger)pageIndex animated:(BOOL)animated;

- (void)prevPage;
- (void)nextPage;

/**
 *  设置是否可滚动
 *
 *  @param enable BOOL
 */
- (void)setScrollEnable:(BOOL)enable;
/**
 *  push 一个View进来
 *
 *  @param view     UIView
 *  @param animated  是否动画
 *  @param completion
 */
- (void)pushView:(UIView *)view animated:(BOOL)animated completion:(void(^)(void))completion;

/**
 *  pop 出来
 *
 *  @param animated   animated description
 *  @param completion completion description
 */
- (void)popToRootWithAnimated:(BOOL)animated completion:(void(^)(void))completion;


@end
