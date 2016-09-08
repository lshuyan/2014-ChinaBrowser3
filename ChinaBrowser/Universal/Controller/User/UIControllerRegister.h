//
//  UIControllerRegister.h
//  login
//
//  Created by HHY on 14-10-24.
//  Copyright (c) 2014年 koto. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewNav.h"
#import "UIControllerBase.h"
#import "AppLanguageProtocol.h"

@interface UIControllerRegister : UIControllerBase<AppLanguageProtocol, UIScrollViewDelegate>
{
    //LocalizedString(@"")
    __weak IBOutlet UIButton *_btnDelegate;
    __weak IBOutlet UILabel *_labelAgree;

    UIViewNav *_viewNav;
    IBOutlet UIScrollView *_scrollView;
    
    IBOutlet UITextField *_textFieldNick;
//    IBOutlet UITextField *_textFieldPasswordSecure;
    IBOutlet UITextField *_textFieldPassword;
    IBOutlet UITextField *_textFieldInfo;
    //注册
    IBOutlet UIButton *_btnRegister;
    
    //勾选
    IBOutlet UIButton *_btnAgree;
    //用户服务协议
    IBOutlet UIButton *btnDelegate;
    
    IBOutlet UIButton *_btnTextPassword;
    
    IBOutlet UILabel *_labelPwd;
}

@property (nonatomic, assign) FromController fromController;

@end
