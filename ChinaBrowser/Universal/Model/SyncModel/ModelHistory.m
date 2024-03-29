//
//  ModelHistory.m
//  ChinaBrowser
//
//  Created by HHY on 14/11/14.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelHistory.h"

@implementation ModelHistory

- (void)setTitle:(NSString *)title
{
    _title = [title isKindOfClass:[NSString class]]?title:nil;
}

- (void)setLink:(NSString *)link
{
    _link = [link isKindOfClass:[NSString class]]?link:nil;
}

- (void)setIcon:(NSString *)icon
{
    _icon = [icon isKindOfClass:[NSString class]]?icon:nil;
}

#pragma mark - instance
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self) {
        self.title = dict[@"title"];
        self.link = dict[@"link"];
        self.icon = dict[@"icon"];
        self.time = [dict[@"time"] doubleValue];
        self.times = [dict[@"times"] integerValue];
    }
    return self;
}

- (instancetype)initWithResultSetDict:(NSDictionary *)dict
{
    self = [super initWithResultSetDict:dict];
    if (self) {
        self.title = dict[@"title"];
        self.link = dict[@"link"];
        self.icon = dict[@"icon"];
        self.time = [dict[@"time"] integerValue];
        self.times = [dict[@"times"] integerValue];
    }
    return self;
}

@end
