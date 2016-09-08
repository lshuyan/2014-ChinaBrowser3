//
//  ADOBookmark.h
//  ChinaBrowser
//
//  Created by David on 14/11/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelBookmark.h"

@interface ADOBookmark : NSObject
/**
 *  判断是否存在
 *
 *  @param link 地址
 *  @param title 标题
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithLink:(NSString *)link userId:(NSInteger)userId;

+ (BOOL)isExistWithLink:(NSString *)link userId:(NSInteger)userId exceptPkid:(NSInteger)exceptPkid;

/**
 *  判断同名文件夹是否存在
 *
 *  @param title  文件夹名
 *  @param userId 用户id
 *
 *  @return bool
 */
+ (BOOL)isExistFolderWithTitil:(NSString *)title userId:(NSInteger)userId parentPkid:(NSInteger)parentPkid;

/**
 *  添加
 *
 *  @param model modleBookmark
 *
 *  @return NSInteger  最后添加的id； <= 0，表示错误； > 0 表示添加成功
 */
+ (NSInteger)addModel:(ModelBookmark *)model;

/**
 *  删除App
 *
 *  @param aid 本地数据库AppBookmark
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithPkid:(NSInteger)pkid;

/**
 *  根据链接地址和用户id删除一条书签
 *
 *  @param link   链接地址
 *  @param userId 所属用户id
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)deleteWithLink:(NSString *)link userId:(NSInteger)userId;

+ (BOOL)deleteWithArrPkidServer:(NSArray *)arrPkidServer userId:(NSInteger)userId;

+ (BOOL)deleteWithPkidServer:(NSInteger)pkidServer userId:(NSInteger)userId exceptPkid:(NSInteger)pkid;

/**
 *  清空数据表
 *
 *  @return BOOL 是否成功
 */
//+ (BOOL)clear;

+ (BOOL)clearWithUserId:(NSInteger)userId;

/**
 *  通过唯一键更新排序索引
 *
 *  @param orderIndex 排序索引
 *  @param pkid       唯一键id
 *
 *  @return BOOL 是否成功
 */
+ (BOOL)updateSort:(NSInteger)sort_index withPkid:(NSInteger)pkid;

/**
 *  通过唯一键更新 标题，链接地址
 *
 *  @param title 标题
 *  @param link  链接地址
 *  @param parentPkid 父级id(文件夹id)
 *  @param pkid  pkid
 *
 *  @return BOOL
 */
+ (BOOL)updateTitle:(NSString *)title link:(NSString *)link parentPkid:(NSInteger)parentPkid withPkid:(NSInteger)pkid;

+ (BOOL)updateTitle:(NSString *)title link:(NSString *)link parentPkid:(NSInteger)parentPkid parentPkidServer:(NSInteger)parentPkidServer withPkid:(NSInteger)pkid;

+ (BOOL)updateModel:(ModelBookmark *)model;

+ (BOOL)updateParentPkidServer:(NSInteger)parentPkidServer withParentPkid:(NSInteger)parentPkid;


+ (NSArray *)queryWillUpdateWithUserId:(NSInteger)userId;
+ (NSArray *)queryWillAddWithUserId:(NSInteger)userId;

/**
 *  查询所有bookmark+文件夹
 *
 *  @return NSArray 所有bookmark
 */
+ (NSArray *)queryWithUserId:(NSInteger)userId;

/**
 *  查询所有文件夹
 *
 *  @return NSArray 所有文件夹
 */
+ (NSArray *)queryAllFolderWithUserId:(NSInteger)userId;

/**
 *  按文件夹查询书签
 *
 *  @param parent_pkid 文件夹编号
 *
 *  @return NSArray bookmark
 */
+ (NSArray *)queryWithParent_pkid:(NSInteger )parent_pkid userId:(NSInteger)userId;

/**
 *  按文件夹查询  索引内书签
 *
 *  @param parent_pkid 文件夹编号
 *  @param fromSort    起始索引
 *  @param toSort      结束索引
 *
 *  @return nsarray bookmark
 */
+ (NSArray *)queryWithParent_pkid:(NSInteger )parent_pkid userId:(NSInteger)userId fromSort:(NSInteger)fromSort toSort:(NSInteger)toSort;

+ (NSArray *)queryWithParentPkid:(NSInteger)parentPkid fromSortIndex:(NSInteger)fromSortIndex exceptPkid:(NSInteger)exceptPkid;

/**
 *  按唯一ID查询某一条数据
 *
 *  @param pkid 唯一ID
 *
 *  @return
 */
+ (ModelBookmark *)queryWithPkid:(NSInteger)pkid;
+ (ModelBookmark *)queryFolderWithTitil:(NSString *)title userId:(NSInteger)userId parentPkidServer:(NSInteger)parentPkidServer exceptPkid:(NSInteger)exceptPkid;
+ (ModelBookmark *)queryFolderWithTitil:(NSString *)title userId:(NSInteger)userId parentPkidServer:(NSInteger)parentPkidServer;
+ (ModelBookmark *)queryWithPkidServer:(NSInteger)pkidServer userId:(NSInteger)userId;

/**
 *  按link查询一条书签
 *
 *  @param link 连接地址/功能模块的地址
 *  @param urlSchemes urlSchemes
 *
 *  @return BOOL
 */
+ (ModelBookmark *)queryWithLink:(NSString *)link userId:(NSInteger)userId;

+ (ModelBookmark *)queryWithLink:(NSString *)link userId:(NSInteger)userId exceptPkid:(NSInteger)exceptPkid;

+ (NSInteger)queryParentPkidWithParentPkidServer:(NSInteger)parentPkidServer;
+ (NSInteger)queryParentPkidServerWithParentPkid:(NSInteger)parentPkid;

+ (NSInteger)queryPkidWithPkidServer:(NSInteger)pkidServer;
+ (NSInteger)queryPkidServerWithPkid:(NSInteger)pkid;

/**
 *  添加书签或文件夹时设置索引
 *
 *  @param parentPkid 唯一ID
 *  @param userId     用户ID
 *
 *  @return 错误信息
 */
+ (NSInteger)queryMaxSortIndexWithParentPkid:(NSInteger)parentPkid userId:(NSInteger)userId;

@end