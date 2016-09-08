//
//  SyncHelper.h
//  ChinaBrowser
//
//  Created by David on 14/12/19.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNotificationDidSync;

typedef void (^SyncCompletion) ();
typedef void (^SyncFail) (NSError *error);
typedef void (^SyncDataTypeCompletion) (SyncDataType);

@class ModelUserSettings;
@class ModelHistory;
@class ModelBookmark;
@class ModelMode;
@class ModelModeProgram;

/**
 *  同步助手，同步用户设置、书签、最近浏览、个性化定制；其中用户设置是及时同步的，修改用户设置则立即反馈到服务器，忽略失败的操作
 *  提交失败后
 */
@interface SyncHelper : NSObject

/**
 *
 */
@property (nonatomic, assign, readonly) BOOL isSyncing;

+ (instancetype)shareSync;

/**
 *  根据当前用户设置和网络环境，检查是否可以自动同步
 *
 *  @return BOOL 是否自动同步
 */
+ (BOOL)shouldAutoSync;

/**
 *  是否允许同步某种数据类型
 *
 *  @param syncDataType 同步的数据类型
 *
 *  @return BOOL
 */
+ (BOOL)shouldSyncWithType:(SyncDataType)syncDataType;

/**
 *  根据用户设置同步所有能同步的数据
 *
 *  @param completion completion description
 *  @param fail       fail description
 *  @param syncDataTypeCompletion       syncDataTypeCompletion description
 */
- (void)syncAllIfNeededWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail syncDataTypeCompletion:(SyncDataTypeCompletion)syncDataTypeCompletion;

// --------------------- 批处理 get=>compare=>submit
/**
 *  同步用户设置
 *
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncUserSettingsWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  同步某种数据类型
 *
 *  @param type 同步的数据类型
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncDataType:(SyncDataType)type completion:(SyncCompletion)completion fail:(SyncFail)fail;

- (void)syncModeProgramWithArrModePkidServer:(NSArray *)arrModePkidServer completion:(SyncCompletion)completion fail:(SyncFail)fail;

/*
- (void)syncHistoryWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;
- (void)syncBookmarkWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;
- (void)syncReminderWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;
- (void)syncModeWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;
- (void)syncModeProgramWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;
*/

// --------------------- 批处理同步 add
/**
 *  往服务器添加最近浏览的历史记录，添加成功后更新本地的pkid_server
 *
 *  @param arrHistory   历史记录实体 数组
 *  @param completion   completion description
 *  @param fail         fail description
 */
- (void)syncAddArrHistory:(NSArray *)arrHistory completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  往服务器添加书签(文件件)，添加成功后，更新本地相关的pkid_server和parent_pkid_server
 *
 *  @param arrBookmark  书签实体 数据
 *  @param completion    完成block
 *  @param fail          失败block
 */
- (void)syncAddArrBookmark:(NSArray *)arrBookmark completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  往服务器添加 定制 模式，添加成功后，更新本地的相关的pkid_server和 ModelModeProgram 中的 mode_pkid_server
 *
 *  @param arrMode      模式实体数组
 *  @param completion   完成block
 *  @param fail         失败block
 */
- (void)syncAddArrMode:(NSArray *)arrMode completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  往服务器添加 模式-节目，添加成功后，更新本地相关的pkid_server
 *
 *  @param arrModeProgram   模式-节目实体 数组
 *  @param completion       completion description
 *  @param fail             fail description
 */
- (void)syncAddArrModeProgram:(NSArray *)arrModeProgram completion:(SyncCompletion)completion fail:(SyncFail)fail;

// --------------------- 批处理同步 delete
/**
 *  删除服务器上的 历史记录（最近浏览）
 *
 *  @param arrSyncDelete 需要同步的删除项，请求成功之后返回对应的
 *  @param completion    completion description
 *  @param fail          fail description
 */
- (void)syncDeleteHistoryWithArrSyncDelete:(NSArray *)arrSyncDelete completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  删除服务器上的 书签(文件夹)
 *
 *  @param arrSyncDelete 需要同步的删除项
 *  @param completion    completion description
 *  @param fail          fail description
 */
- (void)syncDeleteBookmarkWithArrSyncDelete:(NSArray *)arrSyncDelete completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  删除服务器上的定制 模式，同时删除该 模式 下的所有节目
 *
 *  @param arrSyncDelete 需要同步的删除项
 *  @param completion    completion description
 *  @param fail          fail description
 */
- (void)syncDeleteModeWithArrSyncDelete:(NSArray *)arrSyncDelete completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  删除服务器上的 模式-节目
 *
 *  @param arrSyncDelete 需要同步的删除项
 *  @param completion    completion description
 *  @param fail          fail description
 */
- (void)syncDeleteModeProgramWithArrSyncDelete:(NSArray *)arrSyncDelete completion:(SyncCompletion)completion fail:(SyncFail)fail;

// --------------------- 更新同步 update
/**
 *  向服务器修改用户设置
 *
 *  @param userSetting 用户设置实体
 *  @param completion  completion description
 *  @param fail        fail description
 */
- (void)syncUpdateUserSetting:(ModelUserSettings *)userSetting completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  修改服务器 最近浏览(历史记录前20条)
 *
 *  @param arrHistory   历史记录实体 数组 ModelHistory
 *  @param async        异步实现; YES:不检查是否正在同步；NO:需要检查是否正在同步
 *  @param completion   completion description
 *  @param fail         fail description
 */
- (void)syncUpdateArrHistory:(NSArray *)arrHistory async:(BOOL)async completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  修改服务器 书签
 *
 *  @param arrBookmark 书签实体 数组 ModelBookmark
 *  @param completion  completion description
 *  @param fail        fail description
 */
- (void)syncUpdateArrBookmark:(NSArray *)arrBookmark completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  修改服务器 个性化定制 模式
 *
 *  @param arrMode    模式实体 数组
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncUpdateArrMode:(NSArray *)arrMode completion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  修改服务器 模式-节目
 *
 *  @param arrModeProgram 模式-节目 实体 数组
 *  @param completion     completion description
 *  @param fail           fail description
 */
- (void)syncUpdateArrModeProgram:(NSArray *)arrModeProgram completion:(SyncCompletion)completion fail:(SyncFail)fail;

// --------------------- 同步 get
/**
 *  下载用户设置
 *
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncGetUserSettingsWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  下载 历史记录
 *
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncGetHistoryWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  下载 书签数据
 *
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncGetBookmarkWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  下载个性化定制模式
 *
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncGetModeWithCompletion:(SyncCompletion)completion fail:(SyncFail)fail;

/**
 *  下载 个性化定制 模式中的节目
 *
 *  @param completion completion description
 *  @param fail       fail description
 */
- (void)syncGetModeProgramWithArrModePkidServer:(NSArray *)arrModePkidServer completion:(SyncCompletion)completion fail:(SyncFail)fail;

// ------------------- 同步 清空服务器上的用户数据
/**
 *  清空服务器上的用户数据
 *
 *  @param syncDataType 数据类型
 *  @param completion   completion description
 *  @param fail         fail description
 */
- (void)syncClearDataType:(SyncDataType)syncDataType completion:(SyncCompletion)completion fail:(SyncFail)fail;

@end