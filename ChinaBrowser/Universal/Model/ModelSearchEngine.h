//
//  ModelSearchEngine.h
//  ChinaBrowser
//
//  Created by David on 14/10/29.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelBase.h"

/**
 *  搜索引擎
 */
@interface ModelSearchEngine : ModelBase

/**
 *  搜索引擎id
 */
@property (nonatomic, assign) NSInteger seachEngineId;
/**
 *  图标
 */
@property (nonatomic, strong) NSString *icon;
/**
 *  彩色图标
 */
@property (nonatomic, strong) NSString *colorIcon;
/**
 *  名称
 */
@property (nonatomic, strong) NSString *name;
/**
 *  搜索链接地址
 */
@property (nonatomic, strong) NSString *link;

@end
