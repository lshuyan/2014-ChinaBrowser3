//
//  ADOApp.h
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelApp.h"

@interface ADOApp : NSObject

/**
 *  判断是否存在
 *
 *  @param appType App类型
 *  @param link 链接地址/功能模块的地址
 *  @param urlSchemes urlSchemes
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithAppType:(AppType)appType link:(NSString *)link urlSchemes:(NSString *)urlSchemes userId:(NSInteger)userId;
/**
 *  添加
 *
 *  @param model ModelApp
 *
 *  @return NSInteger  最后添加的id； <= 0，表示错误； > 0 表示添加成功
 */
+ (NSInteger)addModel:(ModelApp *)model;
/**
 *  删除App
 *
 *  @param pkid 本地数据库AppId
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithPkid:(NSInteger)pkid;

+ (BOOL)deleteWithWebAppWithLink:(NSString *)link userId:(NSInteger)userId;
/**
 *  清空数据表
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)clear;

+ (BOOL)clearWithUserId:(NSInteger)userId;
/**
 *  更新数据
 *
 *  @param model ModelApp
 *
 *  @return BOOL
 */
+ (BOOL)updateModel:(ModelApp *)model;

+ (BOOL)updateTitle:(NSString *)title link:(NSString *)link withPkid:(NSInteger)pkid;
+ (BOOL)updateTitle:(NSString *)title urlSchemes:(NSString *)urlSchemes withPkid:(NSInteger)pkid;
/**
 *  通过唯一键更新排序索引
 *
 *  @param orderIndex 排序索引
 *  @param pkid       唯一键id
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)updateOrderIndex:(NSInteger)orderIndex withPkid:(NSInteger)pkid;
/**
 *  查询所有App
 *
 *  @return NSArray 所有App
 */
+ (NSArray *)queryWithUserId:(NSInteger)userId;
/**
 *  分页查询App
 *
 *  @param page     页码
 *  @param pageSize 数量
 *
 *  @return NSArray App
 */
+ (NSArray *)queryWithPage:(NSInteger)page pagesize:(NSInteger)pagesize userId:(NSInteger)userId;

+ (NSInteger)queryMaxSortIndexWithUserId:(NSInteger)userId;

@end
