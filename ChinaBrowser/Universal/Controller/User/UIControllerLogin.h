//
//  UIControllerLogin.h
//  login
//
//  Created by HHY on 14-10-24.
//  Copyright (c) 2014年 koto. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIControllerBase.h"
#import "UIControlItem.h"

#import "UIViewNav.h"
#import "AppLanguageProtocol.h"

#import <ShareSDK/ShareSDK.h>


@interface UIControllerLogin : UIControllerBase <UITextFieldDelegate, AppLanguageProtocol, UIScrollViewDelegate>
{
    //LocalizedString
    __weak IBOutlet UILabel *_labelLogin3;
    __weak IBOutlet UILabel *_labelLogin2;

    // 自定义导航栏
    
    UIViewNav *_viewNav;
    //第三方登陆view / 底部功能图展示view
    IBOutlet UIImageView *_imageView1;
    IBOutlet UIImageView *_imageView2;
    //账号 / 密码
    IBOutlet UITextField *_textFieldInfo;
    IBOutlet UITextField *_textFieldPassWord;
    //登陆
    IBOutlet UIButton *_btnLogin;
    //注册/找回密码
    IBOutlet UIButton *_btnRegister;
    IBOutlet UIButton *_btnFindPassWord;
    
    //第三方登陆界面
    IBOutlet UIView *_viewSDK;
    IBOutlet UIScrollView *_scrollViewSDK;
    IBOutlet UIView *_viewBottom;
    
    IBOutlet UIScrollView *_scrollView;
    
    IBOutlet UIControlItem *_controlItemShuQian;
    IBOutlet UIControlItem *_controlItemMore;
    IBOutlet UIControlItem *_controlItemBiaoQian;
    
}

@property (nonatomic, assign) FromController fromController;

@end
