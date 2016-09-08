//
//  AppLaunchUtil.h
//  ChinaBrowser
//
//  Created by David on 14/12/5.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelProgram.h"

@protocol AppLaunchDelegate;

/**
 *  程序启动工具类
 */
@interface AppLaunchUtil : NSObject

@property (nonatomic, weak) id<AppLaunchDelegate> delegate;

/**
 *  是否从通知 启动 节目
 */
@property (nonatomic, assign, readonly) BOOL shouldLaunchProgram;

/**
 *  是否播放FM
 */
@property (nonatomic, assign, readonly) BOOL shouldPlayFM;

/**
 *  启动节目
 */
@property (nonatomic, strong) ModelProgram *program;

/**
 *  远程通知信息
 */
@property (nonatomic, strong) NSDictionary *dictRemoteNotificationInfo;


+ (instancetype)shareAppLaunch;

@end

@protocol AppLaunchDelegate <NSObject>

/**
 *  打开网址
 *
 *  @param link 网站链接地址
 */
- (void)appLaunchOpenLink:(NSString *)link;

/**
 *  打开推荐的新闻分类
 *
 *  @param cateid 推荐分类id
 *  @param cateName 推荐分类名称
 */
- (void)appLaunchOpenRecommendCateId:(NSInteger)cateid cateName:(NSString *)cateName;

@end
