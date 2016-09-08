//
//  AppLaunchUtil.m
//  ChinaBrowser
//
//  Created by David on 14/12/5.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "AppLaunchUtil.h"

static AppLaunchUtil *appLaunch;

@implementation AppLaunchUtil

+ (instancetype)shareAppLaunch
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appLaunch = [[AppLaunchUtil alloc] init];
    });
    return appLaunch;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldPlayFM = NO;
        _shouldLaunchProgram = NO;
    }
    return self;
}

- (void)setProgram:(ModelProgram *)program
{
    _program = program;
    if (_program) {
        _shouldPlayFM = YES;
        _shouldLaunchProgram = YES;
    }
    else {
        _shouldLaunchProgram = NO;
        _shouldPlayFM = NO;
    }
}

- (void)setDictRemoteNotificationInfo:(NSDictionary *)dictRemoteNotificationInfo
{
    _dictRemoteNotificationInfo = dictRemoteNotificationInfo;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
