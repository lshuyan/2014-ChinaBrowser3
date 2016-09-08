//
//  ModelBookmark.m
//  ChinaBrowser
//
//  Created by HHY on 14/11/8.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ModelBookmark.h"

@implementation ModelBookmark

#pragma mark - property
- (void)setTitle:(NSString *)title
{
    _title = [title isKindOfClass:[NSString class]]?title:nil;
}

- (void)setLink:(NSString *)link
{
    _link = [link isKindOfClass:[NSString class]]?link:nil;
    if (_link) {
        NSURL *url = [NSURL URLWithString:_link];
        NSString *stringIcon = [[NSString stringWithFormat:@"http://%@",url] stringByAppendingPathComponent:@"favicon.ico"];
        self.icon = stringIcon;
    }
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
        if (dict[@"parent_pkid"]) {
            self.parent_pkid_server = [dict[@"parent_pkid"] integerValue];
        }
        
        self.title = dict[@"title"];
        self.link = dict[@"link"];
        self.icon = dict[@"icon"];
        self.isFolder = [dict[@"is_folder"] boolValue];
        self.canEdit = [dict[@"can_edit"] boolValue];
        self.sortIndex = [dict[@"sort_index"] integerValue];
    }
    return self;
}

- (instancetype)initWithResultSetDict:(NSDictionary *)dict
{
    self = [super initWithResultSetDict:dict];
    if (self) {
        self.parent_pkid = [dict[@"parent_pkid"] integerValue];
        self.parent_pkid_server = [dict[@"parent_pkid_server"] integerValue];
        self.title = dict[@"title"];
        self.link = dict[@"link"];
        self.icon = dict[@"icon"];
        self.isFolder = [dict[@"is_folder"] boolValue];
        self.canEdit = [dict[@"can_edit"] boolValue];
        self.sortIndex = [dict[@"sort_index"] integerValue];
    }
    return self;
}

@end
