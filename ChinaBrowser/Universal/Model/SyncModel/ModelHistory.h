//
//  ModelHistory.h
//  ChinaBrowser
//
//  Created by HHY on 14/11/14.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelSyncBase.h"

/**
 *  历史记录
 */
@interface ModelHistory : ModelSyncBase

/**
 *  书签标题
 */
@property (nonatomic, strong) NSString *title;
/**
 *  书签链接
 */
@property (nonatomic, strong) NSString *link;
/**
 *  书签链接图地址
 */
@property (nonatomic, strong) NSString *icon;
/**
 *  时间戳
 */
@property (nonatomic, assign) NSInteger time;
/**
 *  时间戳
 */
@property (nonatomic, assign) NSInteger times;

@end