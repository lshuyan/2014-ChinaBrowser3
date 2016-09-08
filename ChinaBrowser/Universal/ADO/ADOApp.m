//
//  ADOApp.m
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ADOApp.h"

#import "DBHelper.h"

@implementation ADOApp

/**
 *  判断是否存在
 *
 *  @param appType App类型
 *  @param link 连接地址/功能模块的地址
 *  @param urlSchemes urlSchemes
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithAppType:(AppType)appType link:(NSString *)link urlSchemes:(NSString *)urlSchemes userId:(NSInteger)userId
{
    NSInteger pkid = 0;
    if (AppTypeNative==appType) {
        pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_app where app_type=? and url_schemes=? and lan=? and user_id=?", @(appType), urlSchemes, [LocalizationUtil currLanguage], @(userId)];
    }
    else {
        pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_app where app_type=? and link=? and lan=? and user_id=?", @(appType), link?:@"", [LocalizationUtil currLanguage], @(userId)];
    }
    return pkid>0;
}

/**
 *  添加
 *
 *  @param model ModelApp
 *
 *  @return NSInteger  最后添加的id； <= 0，表示错误； > 0 表示添加成功
 */
+ (NSInteger)addModel:(ModelApp *)model
{
    NSInteger lastInsertId = -1;
    
    if ([ADOApp isExistWithAppType:model.appType link:model.link urlSchemes:model.urlSchemes userId:model.userid]) {
        return lastInsertId;
    }
    
    BOOL flag = [[DBHelper shareDBHelper].db executeUpdate:@"insert into tab_app (user_id, lan, app_type, name, icon, link, url_schemes, package, download_link, sort_index, pkid_server, update_time, update_time_server) values (?,?,?,?,?,?,?,?,?,?,?,?,?)", @(model.userid), model.lan?:@"", @(model.appType), model.title?:@"", model.icon?:@"", model.link?:@"", model.urlSchemes?:@"", model.package?:@"", model.downloadLink?:@"", @(model.sortIndex), @(model.pkid_server), @(model.updateTime), @(model.updateTimeServer)];
    if (flag) {
        lastInsertId = (NSInteger)[[DBHelper shareDBHelper].db lastInsertRowId];
    }
    return lastInsertId;
}

/**
 *  删除App
 *
 *  @param aid 本地数据库AppId
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_app where pkid = ?", @(pkid)];
}

+ (BOOL)deleteWithWebAppWithLink:(NSString *)link userId:(NSInteger)userId
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_app where link=? and user_id=? and lan=?", link, @(userId), [LocalizationUtil currLanguage]];
}

/**
 *  清空数据表
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)clear
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_app where lan=?", [LocalizationUtil currLanguage]];
}

+ (BOOL)clearWithUserId:(NSInteger)userId
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_app where lan=? and user_id=?", [LocalizationUtil currLanguage], userId];
}

/**
 *  更新数据
 *
 *  @param model ModelApp
 *
 *  @return BOOL
 */
+ (BOOL)updateModel:(ModelApp *)model
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_app set name=?, icon=?, link=?, url_schemes=?, download_link=?, sort_index=?, pkid_server=?, update_time=?, update_time_server=? where pkid=?", model.title?:@"", model.icon?:@"", model.link?:@"", model.urlSchemes?:@"", model.downloadLink?:@"", @(model.sortIndex), @(model.pkid_server), @(model.updateTime), @(model.updateTimeServer), @(model.pkid)];
}

+ (BOOL)updateTitle:(NSString *)title link:(NSString *)link withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_app set title=?, link=? where pkid=?", title, link, @(pkid)];
}

+ (BOOL)updateTitle:(NSString *)title urlSchemes:(NSString *)urlSchemes withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_app set title=?, url_schemes=? where pkid=?", title, urlSchemes, @(pkid)];
}

/**
 *  通过唯一键更新排序索引
 *
 *  @param orderIndex 排序索引
 *  @param pkid       唯一键id
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)updateOrderIndex:(NSInteger)orderIndex withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_app set sort_index=? where pkid=?", @(orderIndex), @(pkid)];
}

/**
 *  查询所有App
 *
 *  @return NSArray 所有App
 */
+ (NSArray *)queryWithUserId:(NSInteger)userId
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_app where lan=? and user_id=? order by sort_index", [LocalizationUtil currLanguage], @(userId)];
    while ([set next]) {
        ModelApp *model = [ModelApp modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

/**
 *  分页查询App
 *
 *  @param page     页码
 *  @param pagesize 数量
 *
 *  @return NSArray App
 */
+ (NSArray *)queryWithPage:(NSInteger)page pagesize:(NSInteger)pagesize userId:(NSInteger)userId
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_app where lan=? and user_id=? order by sort_index asc limit ?,?", [LocalizationUtil currLanguage], @(userId), @(page*pagesize), @(pagesize)];
    while ([set next]) {
        ModelApp *model = [ModelApp modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

+ (NSInteger)queryMaxSortIndexWithUserId:(NSInteger)userId
{
    return [[DBHelper shareDBHelper].db intForQuery:@"select max(sort_index) from tab_app where user_id=? and lan=?", @(userId), [LocalizationUtil currLanguage]];
}

@end
