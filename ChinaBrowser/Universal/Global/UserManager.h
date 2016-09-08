//
//  UserManager.h
//  ChinaBrowser
//
//  Created by David on 14/10/31.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelUser.h"

@interface UserManager : NSObject

/**
 *  当前用户，切换用户直接赋值即可；赋值 nil 表示切换为匿名用户
 */
@property (nonatomic, strong, readonly) ModelUser *currUser;

+ (instancetype)shareUserManager;

/**
 *  从本地钥匙串中删除用户
 *
 *  @param uid 用户id
 */
- (void)deleteUserWithUid:(NSInteger)uid;

/**
 *  更新用户信息
 *
 *  @param modelUser ModelUser
 */
- (void)updateUser:(ModelUser *)modelUser;

/**
 *  用户登录
 *
 *  @param user user description
 */
- (void)loginUser:(ModelUser *)user;

/**
 *  退出用户
 */
- (void)logout;

@end
