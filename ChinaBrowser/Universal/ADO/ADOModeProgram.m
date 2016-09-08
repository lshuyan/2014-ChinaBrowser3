//
//  ADOModeProgram.m
//  ChinaBrowser
//
//  Created by David on 14/11/22.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ADOModeProgram.h"

#import "DBHelper.h"
#import "ModelModeProgram.h"
#import "ModelProgram.h"

@implementation ADOModeProgram

/**
 *  检查本地数据是否存有指定的服务器id数据
 *
 *  @param pkidServer 服务器 模式-节目表 pkid
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithPkidServer:(NSInteger)pkidServer
{
    NSInteger pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_mode_program where pkid_server=? and lan=?", @(pkidServer), [LocalizationUtil currLanguage]];
    return pkid>0;
}

/**
 *  检查某个模式下是否有有指定的节目
 *
 *  @param modePkid Mode.pkid
 *  @param time 时间
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithModePkid:(NSInteger)modePkid time:(NSInteger)time;
{
    NSInteger pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_mode_program where mode_pkid=? and time=? and lan=?", @(modePkid), @(time), [LocalizationUtil currLanguage]];
    return pkid>0;
}

+ (BOOL)isExistWithModePkid:(NSInteger)modePkid time:(NSInteger)time exceptPkid:(NSInteger)exceptPkid
{
    NSInteger pkid = [[DBHelper shareDBHelper].db intForQuery:@"select pkid from tab_mode_program where mode_pkid=? and time=? and pkid<>? and lan=?", @(modePkid), @(time), @(exceptPkid), [LocalizationUtil currLanguage]];
    return pkid>0;
}

/**
 *  添加一条数据
 *
 *  @param model ModelProgram
 *
 *  @return NSInteger pkid 添加数据的pkid
 */
+ (NSInteger)addModel:(ModelModeProgram *)model
{
    NSInteger lastInsertId = -1;
    BOOL flag = [[DBHelper shareDBHelper].db executeUpdate:@"insert into tab_mode_program (lan, mode_pkid, mode_pkid_server, program_pkid_server, time, repeat, is_on, pkid_server, update_time, update_time_server) values (?,?,?,?,?,?,?,?,?,?)", model.lan?:@"", @(model.modePkid), @(model.modePkidServer), @(model.modelProgram.pkid_server), @(model.time), @(model.repeatMode), @(model.on), @(model.pkid_server), @(model.updateTime), @(model.updateTimeServer)];
    if (flag) {
        lastInsertId = (NSInteger)[[DBHelper shareDBHelper].db lastInsertRowId];
    }
    return lastInsertId;
}

/**
 *  更新指定数据的提醒时间
 *
 *  @param time 提醒时间(时间戳)
 *  @param pkid
 *
 *  @return BOOL
 */
+ (BOOL)updateTime:(NSInteger)time withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_mode_program set time=? where pkid=?", @(time), @(pkid)];
}

/**
 *  修改指定数据的提醒重复方式
 *
 *  @param repeatMode 重复方式
 *  @param pkid
 *
 *  @return BOOL
 */
+ (BOOL)updateRepeatMode:(RemindRepeatMode)repeatMode withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_mode_program set repeat=? where pkid=?", @(repeatMode), @(pkid)];
}

/**
 *  修改指定数据的开启状态
 *
 *  @param on   是否开启
 *  @param pkid
 *
 *  @return BOOL
 */
+ (BOOL)updateOn:(BOOL)on withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_mode_program set is_on=? where pkid=?", @(on), @(pkid)];
}

+ (BOOL)updateProgramPkidServer:(NSInteger)programPkidServer withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_mode_program set program_pkid_server=? where pkid=?", @(programPkidServer), @(pkid)];
}

/**
 *  修改指定数据的：重复模式，提醒时间，开启状态
 *
 *  @param repeatMode
 *  @param time
 *  @param pkid
 *
 *  @return BOOL
 */
+ (BOOL)updateRepeatMode:(RemindRepeatMode)repeatMode time:(NSInteger)time withPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_mode_program set repeat=?, time=? where pkid=?", @(repeatMode), @(time), @(pkid)];
}

+ (BOOL)updateModel:(ModelModeProgram *)model
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"update tab_mode_program set pkid_server=?, mode_pkid=?, mode_pkid_server=?, update_time=?, update_time_server=?, program_pkid_server=?, time=?, repeat=?, is_on=? where pkid=?",
            @(model.pkid_server), @(model.modePkid), @(model.modePkidServer), @(model.updateTime), @(model.updateTimeServer), @(model.modelProgram.pkid_server), @(model.time), @(model.repeatMode), @(model.on), @(model.pkid)];
}

+ (BOOL)updateModePkidServer:(NSInteger)modePkidServer withModePkid:(NSInteger)modePkid
{
    return [[DBHelper db] executeUpdate:@"update tab_mode_program set mode_pkid_server=? where mode_pkid=? and lan=?", @(modePkidServer), @(modePkid), [LocalizationUtil currLanguage]];
}

/**
 *  查找指定的一条数据
 *
 *  @param pkid
 *
 *  @return ModelProgram
 */
+ (ModelModeProgram *)queryWithPkid:(NSInteger)pkid
{
    ModelModeProgram *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where pkid = ?", @(pkid)];
    while ([set next]) {
        model= [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (ModelModeProgram *)queryWithPkidServer:(NSInteger)pkidServer
{
    ModelModeProgram *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where pkid_server = ?", @(pkidServer)];
    while ([set next]) {
        model= [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (ModelModeProgram *)queryWithModePkid:(NSInteger)modePkid time:(NSInteger)time
{
    ModelModeProgram *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where mode_pkid=? and time=? and lan=?", @(modePkid), @(time), [LocalizationUtil currLanguage]];
    while ([set next]) {
        model= [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (ModelModeProgram *)queryWithModePkid:(NSInteger)modePkid time:(NSInteger)time exceptPkid:(NSInteger)pkid
{
    ModelModeProgram *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where mode_pkid=? and time=? and pkid<>? and lan=?", @(modePkid), @(time), @(pkid), [LocalizationUtil currLanguage]];
    while ([set next]) {
        model= [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

+ (ModelModeProgram *)queryWithModePkid:(NSInteger)modePkid programPkidServer:(NSInteger)programPkidServer time:(NSInteger)time repeat:(RemindRepeatMode)repeat
{
    return [ADOModeProgram queryWithModePkid:modePkid programPkidServer:programPkidServer time:time repeat:repeat exceptPkid:0];
}

+ (ModelModeProgram *)queryWithModePkid:(NSInteger)modePkid programPkidServer:(NSInteger)programPkidServer time:(NSInteger)time repeat:(RemindRepeatMode)repeat exceptPkid:(NSInteger)exceptPkid
{
    ModelModeProgram *model = nil;
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select pkid from tab_mode_program where mode_pkid=? and program_pkid_server=? and time=? and (repeat&?)>0 and pkid<>? and lan=?", @(modePkid), @(programPkidServer), @(time), @(repeat), @(exceptPkid), [LocalizationUtil currLanguage]];
    while ([set next]) {
        model= [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        break;
    }
    return model;
}

/**
 *  查询指定Mode的一组数据
 *
 *  @return NSArray
 */
+ (NSArray *)queryWithModePkid:(NSInteger)modePkid
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where mode_pkid=? and lan=? order by time asc", @(modePkid), [LocalizationUtil currLanguage]];
    while ([set next]) {
        ModelModeProgram *model = [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

/**
 *  根据条件 查询指定Mode的一组数据
 *
 *  @param modePkid modePkid
 *  @param on       是否启用
 *
 *  @return NSArray
 */
+ (NSArray *)queryWithModePkid:(NSInteger)modePkid on:(BOOL)on
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where mode_pkid=? and is_on =? and lan=? order by time asc", @(modePkid), @(on), [LocalizationUtil currLanguage]];
    while ([set next]) {
        ModelModeProgram *model = [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

+ (NSArray *)queryWithModePkid:(NSInteger)modePkid on:(BOOL)on repeat:(RemindRepeatMode)repeat
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper shareDBHelper].db executeQuery:@"select * from tab_mode_program where mode_pkid=? and is_on=? and (repeat&?)>0 and lan=? order by time asc", @(modePkid), @(on), @(repeat), [LocalizationUtil currLanguage]];
    while ([set next]) {
        ModelModeProgram *model = [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

+ (NSArray *)queryWillUpdateWithModePkidServer:(NSInteger)modelPkidServer
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper db] executeQuery:@"select * from tab_mode_program where update_time>update_time_server and pkid_server>0 and mode_pkid_server=? and lan=?", @(modelPkidServer), [LocalizationUtil currLanguage]];
    while ([set next]) {
        ModelModeProgram *model = [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

+ (NSArray *)queryWillAddWithModePkidServer:(NSInteger)modelPkidServer
{
    NSMutableArray *arrResult = [NSMutableArray array];
    FMResultSet *set = [[DBHelper db] executeQuery:@"select * from tab_mode_program where pkid_server=0 and mode_pkid_server=? and lan=?", @(modelPkidServer), [LocalizationUtil currLanguage]];
    while ([set next]) {
        ModelModeProgram *model = [ModelModeProgram modelWithResultSetDict:[set resultDictionary]];
        [arrResult addObject:model];
    }
    return arrResult;
}

/**
 *  删除一条数据
 *
 *  @param pkid
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithPkid:(NSInteger)pkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_mode_program where pkid=?", @(pkid)];
}

/**
 *  删除一条数据
 *
 *  @param pkidServer
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithPkidServer:(NSInteger)pkidServer
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_mode_program where pkid_server=? and lan=?", @(pkidServer), [LocalizationUtil currLanguage]];
}

+ (BOOL)deleteWithArrPkidServer:(NSArray *)arrPkidServer modePkidServer:(NSInteger)modePkidServer
{
    NSString *pkidServers = [arrPkidServer componentsJoinedByString:@","];
    if (pkidServers.length<=0) {
        pkidServers = @"0";
    }
    NSString *sql = [NSString stringWithFormat:@"delete from tab_mode_program where lan='%@' and pkid_server>0 and pkid_server not in (%@) and mode_pkid_server=%ld", [LocalizationUtil currLanguage], pkidServers, (long)modePkidServer];
    return [[DBHelper db] executeUpdate:sql];
}

/**
 *  删除一条数据
 *
 *  @param modePkid modePkid description
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithModePkid:(NSInteger)modePkid
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_mode_program where mode_pkid=? and lan=?", @(modePkid), [LocalizationUtil currLanguage]];
}

+ (BOOL)deleteWithModePkid:(NSInteger)modePkid time:(NSInteger)time
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_mode_program where mode_pkid=? and time=? and lan=?", @(modePkid), @(time), [LocalizationUtil currLanguage]];
}

+ (BOOL)deleteWithModePkid:(NSInteger)modePkid programPkidServer:(NSInteger)programPkidServer
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_mode_program where mode_pkid=? and program_pkid_server and lan=?", @(modePkid), @(programPkidServer), [LocalizationUtil currLanguage]];
}

+ (BOOL)deleteWithPkidServer:(NSInteger)pkidServer modePkidServer:(NSInteger)modePkidServer exceptPkid:(NSInteger)exceptPkid
{
    return [[DBHelper db] executeUpdate:@"delete from tab_mode_program where pkid_server=? and mode_pkid_server=? and pkid<>? and lan=?", @(pkidServer), @(modePkidServer), @(exceptPkid), [LocalizationUtil currLanguage]];
}

/**
 *  清空数据表
 *
 *  @return BOOL
 */
+ (BOOL)clear
{
    return [[DBHelper shareDBHelper].db executeUpdate:@"delete from tab_mode_program where lan=?", [LocalizationUtil currLanguage]];
}

@end
