//
//  UITableViewMode.h
//  ChinaBrowser
//
//  Created by David on 14/11/18.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppLanguageProtocol.h"

@protocol UITableViewModeDelegate;
@class ModelMode;

@interface UITableViewMode : UITableView <AppLanguageProtocol>

@property (nonatomic, weak) IBOutlet id<UITableViewModeDelegate> delegateMode;

@property (nonatomic, assign, readonly) NSInteger currModePkid;

/**
 *  添加模式
 *
 *  @param model ModelMode
 */
- (void)addMode:(ModelMode *)model;
/**
 *  重命名正在编辑的模型
 *
 *  @param name 新名字
 */
- (void)setEditingModeName:(NSString *)name;

/**
 *  更新节目列表
 *
 *  @param modePkid
 */
- (void)updatePListIfNeedWithModePkid:(NSInteger)modePkid;

/**
 *  重新加载自定义模式
 */
- (void)reloadCustomMode;

@end

@protocol UITableViewModeDelegate <NSObject>

- (void)tableViewModeWillAdd:(UITableViewMode *)tableViewMode;
- (void)tableViewMode:(UITableViewMode *)tableViewMode willRenameName:(NSString *)name;
- (void)tableViewMode:(UITableViewMode *)tableViewMode showDetailMode:(ModelMode *)modelMode;

@end
