//
//  ADOFMHistory.h
//  ChinaBrowser
//
//  Created by David on 14/12/3.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ModelFMHistory;

@interface ADOFMHistory : NSObject

+ (BOOL)isExistWithUserId:(NSInteger)userId;

+ (NSInteger)addModel:(ModelFMHistory *)modelFMHistory;

+ (BOOL)updateModePkid:(NSInteger)modePkid withUserId:(NSInteger)userId;
+ (BOOL)updateModeProgramPkid:(NSInteger)modeProgramPkid withUserId:(NSInteger)userId;
+ (BOOL)updateModePkid:(NSInteger)modePkid modeProgramPkid:(NSInteger)modeProgramPkid withUserId:(NSInteger)userId;

+ (BOOL)deleteWithUserId:(NSInteger)userId;
+ (BOOL)clear;
+ (BOOL)clearWithUserId:(NSInteger)userId;

+ (ModelFMHistory *)queryWithUserId:(NSInteger)userId;

@end