//
//  ModelBookmark.h
//  ChinaBrowser
//
//  Created by HHY on 14/11/8.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelSyncBase.h"

/**
 *  书签
 */
@interface ModelBookmark : ModelSyncBase
/**
 *  父id
 */
@property (nonatomic, assign) NSInteger parent_pkid;
/**
 *  服务器父id
 */
@property (nonatomic, assign) NSInteger parent_pkid_server;
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
 *  是否是文件
 */
@property (nonatomic, assign) BOOL isFolder;
/**
 *  能否编辑
 */
@property (nonatomic, assign) BOOL canEdit;
/**
 *  序号
 */
@property (nonatomic, assign) NSInteger sortIndex;

@end
