//
//  UIScrollViewLablesList.h
//  ChinaBrowser
//
//  Created by 石显军 on 14/11/11.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollViewLablesList : UIScrollView

@property (nonatomic, strong) NSMutableArray *lableList;

@property (nonatomic, strong) void(^lableListDelegate)(NSInteger);

@end