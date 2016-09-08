//
//  ADONewsStatus.m
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ADONewsStatus.h"

#import "DBHelper.h"
#import "ModelNewsStatus.h"

@implementation ADONewsStatus

/**
 *  查询是否存在
 *
 *  @param newsId 新闻ID
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithNewsId:(NSInteger)newsId
{
    NSInteger pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_news_status where newsid=? and lan=?", @(newsId), [LocalizationUtil currLanguage]];
    return pkid>0;
}

/**
 *  查询是否已读
 *
 *  @param newsId 新闻ID
 *
 *  @return BOOL
 */
+ (BOOL)isReadWithNewsId:(NSInteger)newsId
{
    return [[DBHelper shareDBHelper].db boolForQuery:@"select status from tab_news_status where newsid=? and lan=?", @(newsId), [LocalizationUtil currLanguage]];
}

/**
 *  新加一条新闻阅读状态数据，只需要newId，新加的记录 状态默认为 NO
 *
 *  @param newsId 新闻ID
 *  @param isRead 是否已读
 *
 *  @return NSInteger
 */
+ (NSInteger)addNewsStatusWithNewsId:(NSInteger)newsId isRead:(BOOL)isRead
{
    NSInteger lastInsertId = -1;
    
    if ([ADONewsStatus isExistWithNewsId:newsId]) {
        return lastInsertId;
    }
    
    BOOL flag = [[DBHelper shareDBHelper].db executeUpdate:@"insert into tab_news_status (newsid, status, lan) values (?,?,?)", @(newsId), @(isRead), [LocalizationUtil currLanguage]];
    if (flag) {
        lastInsertId = (NSInteger)[[DBHelper shareDBHelper].db lastInsertRowId];
    }
    return lastInsertId;
}

/**
 *  删除新闻阅读状态
 *
 *  @param newsId 新闻ID
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithNewsId:(NSInteger)newsId
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_news_status where newsid=? and lan=?", @(newsId), [LocalizationUtil currLanguage]];
}

/**
 *  更新阅读状态（属于扩展方法，以后可以将新闻标记为已读或未读）
 *
 *  @param newsId 新闻ID
 *  @param isRead 是否已读
 *
 *  @return BOOL
 */
+ (BOOL)updateReadStatusWithNewsId:(NSInteger)newsId isRead:(BOOL)isRead
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_news_status set status=? where newsid=? and lan=?", @(isRead), @(newsId), [LocalizationUtil currLanguage]];
}

@end
