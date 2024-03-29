//
//  ADOUserPassword.h
//  ChinaBrowser
//
//  Created by huyan on 14/12/20.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelUserPassword.h"

@interface ADOUserPassword : NSObject
/**
 *  判断是否存在
 *
 *  @param UserName 用户名
 *
 *  @return BOOL
 */
+ (BOOL)isExistWithUserName:(NSString *)userName;

/**
 *  添加
 *
 *  @param userName 用户名
 *  @param password 密码
 *
 *  @return NSInteger  最后添加的id； <= 0，表示错误； > 0 表示添加成功
 */
+ (NSInteger)addUserName:(NSString *)userName password:(NSString *)password;

/**
 *  通过用户名,更新密码
 *
 *  @param password 需要更新的密码
 *
 *  @param username 用户名
 *
 *  @return BOOL
 */
+ (BOOL)updatePassword:(NSString *)password withUserName:(NSString *)userName;

/**
 *  按用户名查询数据
 *
 *  @param 用户名
 *
 *  @return
 */
+ (ModelUserPassword *)queryWithUserName:(NSString *)userName;

/**
 *  删除
 *
 *  @param username 用户名
 *
 *  @return BOOL
 */
+ (BOOL)deleteWithUserName:(NSString *)userName;

/**
 *  清除用户密码
 *
 *  @return BOOL
 */
+ (BOOL)clear;

@end
