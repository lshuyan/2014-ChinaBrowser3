//
//  ADOHistory.m
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ADOHistory.h"

#import "DBHelper.h"

@implementation ADOHistory
/**
 *  判断是否存在
 *
 *  @param link 连接地址/功能模块的地址
 *  @param urlSchemes urlSchemes
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithlink:(NSString *)link userId:(NSInteger)userId
{
    NSInteger pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_history where link=? and lan=? and user_id=?", link?:@"", [LocalizationUtil currLanguage], @(userId)];
    return pkid>0;
}

/**
 *  添加
 *
 *  @param model ModelApp
 *
 *  @return NSInteger  最后添加的id； <= 0，表示错误； > 0 表示添加成功
 */
+ (NSInteger)addModel:(ModelHistory *)model
{
    NSInteger lastInsertId = -1;
    
    if (0>=model.title.length || 0>=model.link.length) {
        return lastInsertId;
    }
    
    if ([ADOHistory isExistWithlink:model.link userId:model.userid]) {
        return lastInsertId;
    }
    
    BOOL flag = [[DBHelper shareDBHelper].db executeUpdate:@"insert into tab_history (user_id, lan, title, link, icon, time, times, pkid_server, update_time, update_time_server) values (?,?,?,?,?,?,?,?,?,?)", @(model.userid), model.lan?:@"", model.title?:@"", model.link?:@"", model.icon?:@"", @(model.time), @(model.times), @(model.pkid_server), @(model.updateTime), @(model.updateTimeServer)];
    if (flag)
    {
        lastInsertId = (NSInteger)[[DBHelper shareDBHelper].db lastInsertRowId];
    }
    return lastInsertId;
}

/**
 *  根据链接地址查询一条记录
 *
 *  @param link 链接地址
 *
 *  @return ModelHistory
 */
+ (ModelHistory *)queryWithLink:(NSString *)link userId:(NSInteger)userId
{
    ModelHistory *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_history where link=? and lan=? and user_id=?", link, [LocalizationUtil currLanguage], @(userId)];
    while ([set next]) {
        model = [ModelHistory modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (ModelHistory *)queryWithLink:(NSString *)link userId:(NSInteger)userId exceptPkid:(NSInteger)exceptPkid
{
    ModelHistory *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_history where link=? and lan=? and user_id=? and pkid<>?", link, [LocalizationUtil currLanguage], @(userId), @(exceptPkid)];
    while ([set next]) {
        model = [ModelHistory modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (ModelHistory *)queryWithPkidServer:(NSInteger)pkidServer userId:(NSInteger)userId
{
    ModelHistory *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_history where lan=? and user_id=? and pkid_server=?", [LocalizationUtil currLanguage], @(userId), @(pkidServer)];
    while ([set next]) {
        model = [ModelHistory modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

/**
 *  根据链接和所属用户id查找pkid
 *
 *  @param link   链接地址
 *  @param userId 所属用户id
 *
 *  @return NSInteger 返回pkid，>0 表示存在，否则不存在
 */
+ (NSInteger)queryPkidWithLink:(NSString *)link userId:(NSInteger)userId
{
    return [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_history where link=? and lan=? and user_id=?", link, [LocalizationUtil currLanguage], @(userId)];
}

+ (BOOL)updateTitle:(NSString *)title time:(NSInteger)time updateTime:(NSInteger)updateTime withLink:(NSString *)link userId:(NSInteger)userId
{
    if (title.length<=0 || link.length<=0) {
        return NO;
    }
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_history set title=?, time=?, update_time=? where link=? and user_id=? and lan=?", title, @(time), @(updateTime), link, @(userId), [LocalizationUtil currLanguage]];
}

/**
 *  网服务器添加数据后，需要修改服务器id
 *
 *  @param pkidServer pkidServer description
 *  @param pkid       pkid description
 *
 *  @return BOOL
 */
+ (BOOL)updatePkidServer:(NSInteger)pkidServer withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_history set pkid_server=? where pkid=?", @(pkidServer), @(pkid)];
}

+ (BOOL)updatePkidServer:(NSInteger)pkidServer updateTimeServer:(NSInteger)updateTimeServer withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_history set pkid_server=?, update_time_server=? where pkid=?", @(pkidServer), @(updateTimeServer), @(pkid)];
}

+ (BOOL)updateModel:(ModelHistory *)model
{
    return [[DBHelper db] executeUpdate:@"update tab_history set pkid_server=?, title=?, time=?, times=?, update_time=?, update_time_server=? where pkid=?", @(model.pkid_server), model.title, @(model.time), @(model.times), @(model.updateTime), @(model.updateTimeServer), @(model.pkid)];
}

/**
 *  查询所有书签及文件夹
 *
 *  @return NSArray 所有
 */
+ (NSArray *)queryAllWithUserId:(NSInteger)userId
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_history where lan=? and user_id=? order by time desc", [LocalizationUtil currLanguage], @(userId)];
    while ([set next]) {
        ModelHistory *model = [ModelHistory modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

/**
 *  查询最近浏览的指定数量的历史记录
 *
 *  @param number 数量
 *  @param userId 用户id
 *
 *  @return NSArray
 */
+ (NSArray *)queryLastNumber:(NSInteger)number withUserId:(NSInteger)userId
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_history where lan=? and user_id=? order by time desc limit 0,?", [LocalizationUtil currLanguage], @(userId), @(number)];
    while ([set next]) {
        ModelHistory *model = [ModelHistory modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

/**
 *  删除
 *
 *  @param 唯一键
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_history where pkid = ?", @(pkid)];
}

+ (BOOL)deleteWithArrPkidServer:(NSArray *)arrPkidServer userId:(NSInteger)userId
{
    NSString *pkidServers = [arrPkidServer componentsJoinedByString:@","];
    if (pkidServers.length<=0) {
        pkidServers = @"0";
    }
    
    NSString *sqlQuery = [NSString stringWithFormat:@"select pkid_server from tab_history where pkid_server>0 and pkid_server not in (%@) and user_id=%ld and lan='%@' order by time desc limit %d", pkidServers, (long)userId, [LocalizationUtil currLanguage], kLastVisitNumber];
    FMResultSet *set = [[DBHelper db] executeQuery:sqlQuery];
    NSMutableArray *arrPkidServerWillDelete = [NSMutableArray array];
    while ([set next]) {
        [arrPkidServerWillDelete addObject:[set resultDictionary][@"pkid_server"]];
    }
    NSString *pkidServerWillDelete = [arrPkidServerWillDelete componentsJoinedByString:@","];
    if (pkidServerWillDelete.length<=0) {
        return YES;
    }
    
    NSString *sql = [NSString stringWithFormat:@"delete from tab_history where pkid_server in (%@) and user_id=%ld and lan='%@'",  pkidServerWillDelete, (long)userId, [LocalizationUtil currLanguage]];
    return [[DBHelper shareDBHelper].db executeUpdate:sql];
}

/**
 *  清空数据表
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)clear
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_history where lan=?", [LocalizationUtil currLanguage]];
}

+ (BOOL)clearWithUserId:(NSInteger)userId
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_history where lan=? and user_id=?", [LocalizationUtil currLanguage], @(userId)];
}

@end
