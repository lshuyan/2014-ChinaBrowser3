//
//  ADOUserSettings.m
//  ChinaBrowser
//
//  Created by David on 14/11/24.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ADOUserSettings.h"

#import "DBHelper.h"
#import "ModelUserSettings.h"

@implementation ADOUserSettings

+ (BOOL)isExistWithUserId:(NSInteger)userId
{
    NSInteger pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_user_settings where user_id=? and lan=?", @(userId), [LocalizationUtil currLanguage]];
    return pkid>0;
}

+ (NSInteger)addModel:(ModelUserSettings *)model
{
    NSInteger lastInsertId = -1;
    if ([ADOUserSettings isExistWithUserId:model.userid]) {
        return lastInsertId;
    }
    
    BOOL flag = [[DBHelper shareDBHelper].db executeUpdate:@"insert into tab_user_settings (user_id, lan, sync_bookmark, sync_lastvisit, sync_reminder, sync_style, pkid_server, update_time, update_time_server) values (?,?,?,?,?,?,?,?,?)", @(model.userid), model.lan?:@"", @(model.syncBookmark), @(model.syncLastVisit), @(model.syncReminder), @(model.syncStyle), @(model.pkid_server), @(model.updateTime), @(model.updateTimeServer)];
    if (flag) {
        lastInsertId = (NSInteger)[[DBHelper shareDBHelper].db lastInsertRowId];
    }
    return lastInsertId;
}

+ (BOOL)updateModel:(ModelUserSettings *)model
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_user_settings set sync_bookmark=?, sync_lastvisit=?, sync_reminder=?, sync_style=?, update_time=?, update_time_server=? where user_id=? and lan=?", @(model.syncBookmark), @(model.syncLastVisit), @(model.syncReminder), @(model.syncStyle), @(model.updateTime), @(model.updateTimeServer), @(model.userid), [LocalizationUtil currLanguage]];
}

+ (ModelUserSettings *)queryWithUserId:(NSInteger)userId
{
    ModelUserSettings *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_user_settings where user_id=? and lan=?", @(userId), [LocalizationUtil currLanguage]];
    while ([set next]) {
        model= [ModelUserSettings modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (BOOL)deleteWithUserId:(NSInteger)userId
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_user_settings where user_id=? and lan=?", @(userId), [LocalizationUtil currLanguage]];
}

+ (BOOL)clear
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_user_settings where lan=?", [LocalizationUtil currLanguage]];
}

@end
