//
//  UIScrollViewApp.h
//  ChinaBrowser
//
//  Created by David on 14-9-29.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppLanguageProtocol.h"

@class UIControlItemApp;

@class ModelApp;

@protocol UIScrollViewAppDelegate;

@interface UIScrollViewApp : UIScrollView <AppLanguageProtocol>

@property (nonatomic, weak) IBOutlet id<UIScrollViewAppDelegate> delegateApps;

/**
 *  编辑状态，外部修改edit会触发 应用屏 编辑状态协议；外部许谨慎修改此属性值
 */
@property (nonatomic, assign) BOOL edit;

/**
 *  添加一个自定义App到UI
 *
 *  @param model    App 实体对象
 *  @param animated 是否动画
 */
- (void)addAppWithModel:(ModelApp *)model animated:(BOOL)animated;
/**
 *  检查是否存在相同的数据
 *
 *  @param type       应用类型
 *  @param link       链接地址
 *  @param urlSchemes
 *
 *  @return BOOL
 */
- (BOOL)isExistWithType:(AppType)type link:(NSString *)link urlSchemes:(NSString *)urlSchemes;
/**
 *  检查是否还可添加App，不允许超过当前语言环境指定数量的App个数
 *
 *  @return BOOL
 */
- (BOOL)canAdd;
/**
 *  通过链接地址删除一个App
 *
 *  @param link 链接地址
 */
- (void)removeWithLink:(NSString *)link;

/**
 *  重新加载自定义App
 */
- (void)reloadCustomApp;

@end

@protocol UIScrollViewAppDelegate <NSObject>

- (void)scrollViewApp:(UIScrollViewApp *)scrollViewApp openModel:(ModelApp *)model;
- (void)scrollViewApp:(UIScrollViewApp *)scrollViewApp edit:(BOOL)edit;
- (void)scrollViewAppWillAddItem:(UIScrollViewApp *)scrollViewApp;
- (void)scrollViewApp:(UIScrollViewApp *)scrollViewApp willEditItem:(ModelApp *)model viewAppItem:(UIControlItemApp *)viewAppItem;

@end
