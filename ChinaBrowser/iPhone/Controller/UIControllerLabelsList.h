//
//  UIControllerLabelsList.h
//  ChinaBrowser
//
//  Created by 石显军 on 14/11/11.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerBase.h"

@class ModelApp;

@interface UIControllerLabelsList : UIControllerBase

@property (nonatomic, strong) void (^callbackAddApp)(ModelApp *);
@property (nonatomic, strong) BOOL (^callbackIsExistApp)(ModelApp *);
@property (nonatomic, strong) BOOL (^callbackCanAddApp)();
@property (nonatomic, strong) void (^callbackOpen)(ModelApp *);

@end
