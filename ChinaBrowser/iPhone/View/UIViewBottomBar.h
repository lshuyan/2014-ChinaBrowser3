//
//  UIViewBottomBar.h
//  ChinaBrowser
//
//  Created by David on 14-9-1.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewBarEventDelegate.h"

@interface UIViewBottomBar : UIView

@property (nonatomic, assign) IBOutlet id<UIViewBarEventDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *btnGoBack;
@property (nonatomic, weak) IBOutlet UIButton *btnGoForward;
@property (nonatomic, weak) IBOutlet UIButton *btnMenu;
@property (nonatomic, weak) IBOutlet UIButton *btnGoHome;
@property (nonatomic, weak) IBOutlet UIButton *btnWinds;

@property (nonatomic, assign) NSInteger numberOfWinds;

- (void)setNumberOfWinds:(NSInteger)numberOfWinds animated:(BOOL)animated;

@end
