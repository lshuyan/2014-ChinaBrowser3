//
//  ADONewsStatus.h
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADONewsStatus : NSObject

/**
 *  查询是否存在
 *
 *  @param newsId 新闻ID
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithNewsId:(NSInteger)newsId;

/**
 *  查询是否已读
 *
 *  @param newsId 新闻ID
 *
 *  @return BOOL
 */
+ (BOOL)isReadWithNewsId:(NSInteger)newsId;

/**
 *  新加一条新闻阅读状态数据，只需要newId，新加的记录 状态默认为 NO
 *
 *  @param newsId 新闻ID
 *  @param isRead 是否已读
 *
 *  @return NSInteger
 */
+ (NSInteger)addNewsStatusWithNewsId:(NSInteger)newsId isRead:(BOOL)isRead;

/**
 *  删除新闻阅读状态
 *
 *  @param newsId 新闻ID
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithNewsId:(NSInteger)newsId;

/**
 *  更新阅读状态（属于扩展方法，以后可以将新闻标记为已读或未读）
 *
 *  @param newsId 新闻ID
 *  @param isRead 是否已读
 *
 *  @return BOOL
 */
+ (BOOL)updateReadStatusWithNewsId:(NSInteger)newsId isRead:(BOOL)isRead;

@end