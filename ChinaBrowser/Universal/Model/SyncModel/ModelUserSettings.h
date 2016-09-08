//
//  ModelUserSettings.h
//  ChinaBrowser
//
//  Created by David on 14/11/21.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelSyncBase.h"

/**
 *  用户同步设置
 */
@interface ModelUserSettings : ModelSyncBase

/**
 *  是否同步书签
 */
@property (nonatomic, assign) BOOL syncBookmark;
/**
 *  是否同步最近访问(历史记录 最近 20条)
 */
@property (nonatomic, assign) BOOL syncLastVisit;
/**
 *  是否同步定时提醒(个性化定制)
 */
@property (nonatomic, assign) BOOL syncReminder;
/**
 *  同步方式
 */
@property (nonatomic, assign) SyncStyle syncStyle;

@end
