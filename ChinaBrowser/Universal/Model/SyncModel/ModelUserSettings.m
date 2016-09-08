//
//  ModelUserSettings.m
//  ChinaBrowser
//
//  Created by David on 14/11/21.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelUserSettings.h"

@implementation ModelUserSettings

#pragma mark - instance

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self) {
        self.syncBookmark = [dict[@"sync_bookmark"] boolValue];
        self.syncLastVisit = [dict[@"sync_lastvisit"] boolValue];
        self.syncReminder = [dict[@"sync_reminder"] boolValue];
        self.syncStyle = [dict[@"sync_style"] integerValue];
    }
    return self;
}

- (instancetype)initWithResultSetDict:(NSDictionary *)dict
{
    self = [super initWithResultSetDict:dict];
    if (self) {
        self.syncBookmark = [dict[@"sync_bookmark"] boolValue];
        self.syncLastVisit = [dict[@"sync_lastvisit"] boolValue];
        self.syncReminder = [dict[@"sync_reminder"] boolValue];
        self.syncStyle = [dict[@"sync_style"] integerValue];
        self.updateTime = [dict[@"update_time"] integerValue];
        self.updateTimeServer = [dict[@"update_time_server"] integerValue];
    }
    return self;
}


@end