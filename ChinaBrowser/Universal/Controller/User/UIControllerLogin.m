//
//  UIControllerLogin.m
//  login
//
//  Created by HHY on 14-10-24.
//  Copyright (c) 2014年 koto. All rights reserved.
//

#import "UIControllerLogin.h"

#import "UIControllerRegister.h"
#import "UIControllerUserInfo.h"

#import "ModelUser.h"

#import "ADOUserPassword.h"
#import "ModelUserPassword.h"

#import <AGCommon/NSString+Common.h>

#define kUserDefaultsUserName @"kUserDefaultsUserName"

@interface UIControllerLogin ()
{
    AFJSONRequestOperation *_reqLogin;
    NSMutableArray *_arrBtnSDK;
    //取消键盘 隐藏按钮
    UIButton * _btnResign;
    //是否是自动填充的密码
    BOOL _isAutoPassword;
    
    //第三方登录type , 用于注销第三方登录
    ShareType _type;
}
@end

@implementation UIControllerLogin

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateByLanguage];
    
    _arrBtnSDK = [[NSMutableArray alloc]init];
    
    _textFieldInfo.delegate = self;
    _textFieldInfo.tag = 1;
    _textFieldInfo.autocapitalizationType =
    _textFieldPassWord.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //用上次登录的用户名,作为默认登录用户名
    _textFieldInfo.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserName];
    
    //根据上次登录的用户名, 自动填充密码.
    ModelUserPassword *model = [ADOUserPassword queryWithUserName:_textFieldInfo.text];
    if (model) {
        _textFieldPassWord.text = model.password;
        _isAutoPassword = YES;
    }
    _textFieldPassWord.delegate = self;
    _textFieldPassWord.tag = 2;
    _textFieldInfo.backgroundColor = [UIColor whiteColor];
    _textFieldPassWord.backgroundColor = [UIColor whiteColor];
    //取消键盘按钮
    _btnResign = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnResign addTarget:self action:@selector(myResignFirstResponder) forControlEvents:UIControlEventTouchDown];
    _btnResign.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    _scrollView.delegate = self;
    [_scrollView addSubview:_btnResign];
    [_scrollView sendSubviewToBack:_btnResign];
    _scrollViewSDK.showsVerticalScrollIndicator = NO;
    _scrollViewSDK.showsHorizontalScrollIndicator = NO;
    
    //注册键盘通知
    [self registerForKeyboardNotifications];
    
//    _textFieldInfo.text = @"18645678911";
//    _textFieldPassWord.text = @"123456";

    //第三方登陆位置
    if ([AppSetting snsLoginItem].count<=0)
    {
        [_viewSDK removeFromSuperview];
    }
    for (NSInteger i = 0; i<[AppSetting snsLoginItem].count; i++)
    {
        UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
        [but addTarget:self action:@selector(onTouchSNSLogin:) forControlEvents:UIControlEventTouchUpInside];
        but.tag = i;
        [but setImage:SNSIconWithShareType((ShareType)[[AppSetting snsLoginItem][i] integerValue], YES) forState:UIControlStateNormal];
        [_scrollViewSDK addSubview:but];
        [_arrBtnSDK addObject:but];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()) return;
    
    [_viewNav resizeWithOrientation:orientation];
    
    CGRect rc = _scrollView.frame;
    rc.origin.y = _viewNav.bottom;
    rc.size.height = self.view.height-rc.origin.y;
    _scrollView.frame = rc;
    
    //第三方登陆按钮位置
    rc = CGRectMake(0, 25, 40, 40);
    rc.origin.x = (self.view.bounds.size.width - rc.size.width*_arrBtnSDK.count)/(_arrBtnSDK.count + 1);
    float w = rc.origin.x;
    if (rc.origin.x<=32) {
        rc.origin.x = 20;
        w = (self.view.bounds.size.width - rc.size.width*_arrBtnSDK.count -40)/(_arrBtnSDK.count - 1);
    }
    for (int i = 0; i<_arrBtnSDK.count; i++)
    {
        UIButton *btn = _arrBtnSDK[i];
        
        btn.frame = rc;
//        if([AppSetting snsLoginItem].count<=4  && UIInterfaceOrientationIsPortrait(orientation))
//        {
//            rc.origin.x += w + rc.size.width;
//            
//        }
//        else if ([AppSetting snsLoginItem].count<=5 && UIInterfaceOrientationIsLandscape(orientation))
//        {
//            rc.origin.x += w + rc.size.width;
//        }
        if (w >= 30) {
            rc.origin.x += w + rc.size.width;
        }
        else
        {
            //如果数量过多 , 按固定宽度排序
            rc.origin.x += 80;
        }
    
        if (i == (_arrBtnSDK.count-1)) {
            _scrollViewSDK.contentSize = CGSizeMake(btn.right+20, 0);
        }
    }
    
    //最下面图片位置
    //如果没有第三方登陆
    if (![AppSetting snsLoginItem]) {
        [_scrollViewSDK removeFromSuperview];
        
        rc = _viewBottom.frame;
        rc.origin.y = _btnRegister.bottom + 20;
        _viewBottom.frame = rc;
    }
    
    //书签图片的位置
    rc = _controlItemShuQian.frame;
    rc.origin.x = self.view.bounds.size.width/3.0-_controlItemShuQian.frame.size.width;
    _controlItemShuQian.frame = rc;
    
    rc = _controlItemMore.frame;
    rc.origin.x = 2*self.view.bounds.size.width/3.0;
    _controlItemMore.frame = rc;
    
    //两条线的位置
    rc = _imageView1.frame;
    rc.size.width = _labelLogin2.frame.origin.x-_imageView1.frame.origin.x - 5;
    _imageView1.frame = rc;
    
    rc = _imageView2.frame;
    rc.origin.x = _labelLogin2.frame.origin.x+_labelLogin2.frame.size.width+5;
    rc.size.width = _imageView1.frame.size.width;
    _imageView2.frame = rc;
    
    _scrollView.contentSize = CGSizeMake(0, _viewBottom.bottom + 10);
    _btnResign.frame = CGRectMake(0, _scrollView.contentOffset.y, _scrollView.width, _scrollView.contentSize.height);
}

// --------------------------------- 用户按钮事件
/**
 *  返回
 */
- (void)onTouchBtnback
{
    if(IsiPad) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        switch (_fromController) {
            case FromControllerUnknow:
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }break;
            case FromControllerSystemSettings:
            {
                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            }break;
            case FromControllerRoot:
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }break;
            case FromControllerSync:
            {
                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            }break;
                
            default:
                break;
        }
    }
}

/**
 *  注册
 */
- (IBAction)onTouchRegister
{
    UIControllerRegister *vc = [UIControllerRegister controllerFromXib];
    vc.fromController = _fromController;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  登录
 *
 *  
 */
- (IBAction)onTouchBtnLogin
{
    if ([_textFieldInfo.text length]==0) {
        //[alert show];
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshuruyouxiang_shouji")];
    }
    else if([_textFieldPassWord.text length]==0)
    {
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshurumima")];
    }
    else if(!(IsValidEmail(_textFieldInfo.text, NO) || IsValidMobilePhoneNum(_textFieldInfo.text)))
    {
        //用户名密码格式错误
        [_textFieldInfo becomeFirstResponder];
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshuruzhengquedeyouxiangdizhi_shoujihao")];
    }
    else
    {
        [self doLogin];
    }
}

/**
 *  忘记密码
 */
- (IBAction)onTouchForgotPwd
{
    [[AppLaunchUtil shareAppLaunch].delegate appLaunchOpenLink:GetApiWithName(API_UserForgotPwd)];
    [self onTouchBtnback];
}

/**
 *  第三方登录
 *
 *  @param sender 按钮
 */
- (void)onTouchSNSLogin:(UIButton *)sender
{
    _type = (ShareType)[[AppSetting snsLoginItem][sender.tag] integerValue];
    //隐藏sdk按钮
    id<ISSAuthOptions> authOptions=[ShareSDK authOptionsWithAutoAuth:YES allowCallback:YES authViewStyle:SSAuthViewStyleModal viewDelegate:nil authManagerViewDelegate:nil];
    [authOptions setPowerByHidden:YES];
    
    [ShareSDK getUserInfoWithType:_type authOptions:authOptions result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
        if(result)
        {
             [self doLoginWithUserInfo:userInfo];
        }
        
    }];
}

// --------------- private
#pragma mark - private methods
/**
 *  注册键盘通知
 */
- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//实现当键盘出现的时候计算键盘的高度大小。用于设置scrollView的contentSize;
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    float kbheight;
    
    kbheight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (kbheight>300) {
        kbheight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    }
    //得到鍵盤的高度
    CGRect rect = _scrollView.frame;
    
    rect.size.height = self.view.bounds.size.height-rect.origin.y-kbheight;
    _scrollView.frame = rect;
    
    rect.size.height =_viewBottom.bottom+10;
    _scrollView.contentSize = rect.size;
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    CGRect rect =_scrollView.frame;
    rect.size.height = self.view.bounds.size.height-rect.origin.y;
    _scrollView.frame = rect;
    rect.size.height = _controlItemBiaoQian.frame.origin.y+_controlItemBiaoQian.frame.size.height+10;
    _scrollView.contentSize = CGSizeMake(0, _viewBottom.bottom + 10);
}

//当点击View时  放弃输入框
-(void)myResignFirstResponder
{
    [_textFieldInfo resignFirstResponder];
    [_textFieldPassWord resignFirstResponder];
}

/**
 *  用户登录逻辑
 */
- (void)doLogin
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:LocalizedString(@"zhengzaidenglu") maskType:SVProgressHUDMaskTypeClear];
    //防止多次登录
    [_reqLogin cancel];
    _reqLogin = nil;
    
    NSDictionary *dicParam = @{@"passwd":_textFieldPassWord.text,
                               @"username":_textFieldInfo.text};
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSMutableURLRequest *req = [client requestWithMethod:@"POST" path:GetApiWithName(API_UserLogin) parameters:dicParam];
    
    _reqLogin = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        _DEBUG_LOG(@"\n------sns login result:%@", JSON);
        
        BOOL flag = NO;
        NSInteger error = -1;
        NSString *msg;
        do {
            if (![JSON isKindOfClass:[NSDictionary class]]) break;
            
            {
                msg = JSON[@"msg"];
                error = [JSON[@"error"] integerValue];
            }
            
            NSDictionary *dicUser = JSON[@"data"];
            if (![dicUser isKindOfClass:[NSDictionary class]]) break;
            
            ModelUser *modelUser = [ModelUser modelWithDict:dicUser];
            
            //设置下次登录界面的默认用户名
            [[NSUserDefaults standardUserDefaults] setObject:modelUser.username forKey:kUserDefaultsUserName];
            //如果数据库有这个账号,更新密码.   如果没有新增
            if ([ADOUserPassword isExistWithUserName:_textFieldInfo.text]) {
                //更新密码
                [ADOUserPassword updatePassword:_textFieldPassWord.text withUserName:_textFieldInfo.text];
            }
            else
            {
                [ADOUserPassword addUserName:_textFieldInfo.text password:_textFieldPassWord.text];
            }
            
            // 个人信息持久化
            [[UserManager shareUserManager] loginUser:modelUser];
            
            // 登陆成功  跳转到个人中心
            UIControllerUserInfo *vc = [UIControllerUserInfo controllerFromXib];
            vc.fromController = _fromController;
            [self.navigationController pushViewController:vc animated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidLogin object:nil];
            
            flag = YES;
        } while (NO);
        
        if (flag) {
            [SVProgressHUD showSuccessWithStatus:LocalizedString(@"dengluchenggong")];
        }
        else {
//            3013, 用户名或密码错误,请重试。
        //如果密码错误, 数据库删除用户账户密码信息
            if(error == 3013)
            {
                [ADOUserPassword deleteWithUserName:_textFieldInfo.text];
            }
            NSString *error = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"denglushibai"),msg];
            [SVProgressHUD showErrorWithStatus:error];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"failure__%@",(NSDictionary*)JSON);
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"lianjieshibai")];
    }];
    [_reqLogin start];
    
}

/**
 *  第三方登陆
 *
 *  @param userInfo 登陆模式
 */
- (void)doLoginWithUserInfo:(id<ISSPlatformUser>)userInfo
{
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:LocalizedString(@"zhengzaidenglu") maskType:SVProgressHUDMaskTypeClear];
    
    ShareType type = [userInfo type];
    NSMutableDictionary *dicParam = [NSMutableDictionary dictionary];
    switch (type) {
        case ShareTypeSinaWeibo:
        {
            dicParam[@"type"] = @"weibo";
        }break;
        case ShareTypeTencentWeibo:
        {
            dicParam[@"type"] = @"tqq";
        }break;
        case ShareTypeQQSpace:
        {
            dicParam[@"type"] = @"qq";
        }break;
        case ShareTypeFacebook:
        {
            dicParam[@"type"] = @"fb";
        }break;
        case ShareTypeTwitter:
        {
            dicParam[@"type"] = @"tw";
        }break;
        default:
            return;
            break;
    }
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:type];
    dicParam[@"access_token"] = [credential token];
    dicParam[@"expires_in"] = @((NSInteger)[[credential expired] timeIntervalSince1970]);
    dicParam[@"uid"] = [userInfo uid];
    dicParam[@"nickname"] = [userInfo nickname];
    dicParam[@"avatar"] = [userInfo profileImage];
    
    _DEBUG_LOG(@"\nparam:%@", dicParam);
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSMutableURLRequest *req = [client requestWithMethod:@"POST" path:GetApiWithName(API_UserSDKLogin) parameters:dicParam];
    
    _reqLogin = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        _DEBUG_LOG(@"\n------sns login result:%@", JSON);
        
        BOOL flag = NO;
        NSInteger error = -1;
        NSString *msg;
        do {
            if (![JSON isKindOfClass:[NSDictionary class]]) break;
            
            {
                msg = JSON[@"msg"];
                error = [JSON[@"error"] integerValue];
            }
            
            NSDictionary *dicUser = JSON[@"data"];
            if (![dicUser isKindOfClass:[NSDictionary class]]) break;
            if (![dicUser[@"settings"] isKindOfClass:[NSDictionary class]]) break;
            
            ModelUser *modelUser = [ModelUser modelWithDict:dicUser];
            // 个人信息持久化
            [[UserManager shareUserManager] loginUser:modelUser];
            // 登陆成功  跳转到个人中心
            UIControllerUserInfo *vc = [UIControllerUserInfo controllerFromXib];
            vc.fromController = _fromController;
            vc.type = _type;
            [self.navigationController pushViewController:vc animated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidLogin object:nil];
            
            flag = YES;
        } while (NO);
        
        if (flag) {
            [SVProgressHUD showSuccessWithStatus:LocalizedString(@"dengluchenggong")];
        }
        else {
            NSString *error = [NSString stringWithFormat:@"%@:%@",LocalizedString(@"denglushibai"),msg];
            [SVProgressHUD showErrorWithStatus:error];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"denglushibai")];
    }];
    [_reqLogin start];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    CGRect rc = _btnResign.frame;
    rc.origin.y = scrollView.contentOffset.y;
    _btnResign.frame = rc;
}

#pragma mark - AppLanguageProtocol.h
-(void)updateByLanguage
{
    self.title = LocalizedString(@"zhanghudenglu");
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    [self.view addSubview:_viewNav];
    
    //输入框设置

    _textFieldInfo.leftView = [[UIImageView alloc]initWithImage:[UIImage imageWithBundleFile:@"iPhone/User/account.png"]];
    _textFieldInfo.leftViewMode = UITextFieldViewModeAlways;
    [_textFieldInfo.layer setBorderWidth:1];
    [_textFieldInfo.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    _textFieldPassWord.leftView = [[UIImageView alloc]initWithImage:[UIImage imageWithBundleFile:@"iPhone/User/password.png"]];
    _textFieldPassWord.leftViewMode = UITextFieldViewModeAlways;
    [_textFieldPassWord.layer setBorderWidth:1];
    [_textFieldPassWord.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    _controlItemShuQian.labelTitle.text = LocalizedString(@"shuqian");
    _controlItemShuQian.labelTitle.font = [UIFont systemFontOfSize:13];
    _controlItemShuQian.userInteractionEnabled = NO;
    _controlItemShuQian.imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/User/collect_0.png"];
    _controlItemBiaoQian.labelTitle.text = LocalizedString(@"biaoqianye_chuangkou_");
    _controlItemBiaoQian.labelTitle.font = [UIFont systemFontOfSize:13];
    _controlItemBiaoQian.userInteractionEnabled = NO;
    _controlItemBiaoQian.imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/User/label_0.png"];
    _controlItemMore.labelTitle.text = LocalizedString(@"gengduofuwu");
    _controlItemMore.labelTitle.font = [UIFont systemFontOfSize:13];
    _controlItemMore.userInteractionEnabled = NO;
    _controlItemMore.imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/User/set_up_0.png"];
    
    //导航栏设置
    UIButton *btnBack =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(onTouchBtnback) forControlEvents:UIControlEventTouchUpInside];
    [btnBack sizeToFit];
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
    //    _navBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"baocun") style:UIBarButtonItemStyleBordered target:self action:nil];
    
    _labelLogin2.text = LocalizedString(@"shiyonghezuozhanghaodenglu");
    _labelLogin3.text = LocalizedString(@"dengluzhonghualiulanqizhanghao_keyitongbuyixiashuju");
    
    
    _textFieldInfo.placeholder = LocalizedString(@"youxiang_shoujihao");
    _textFieldPassWord.placeholder = LocalizedString(@"mima");
    
    [_btnLogin setTitle:LocalizedString(@"denglu") forState:UIControlStateNormal];
    [_btnLogin setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/log_in_0.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
    [_btnLogin setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/log_in_1.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateHighlighted];
    
    [_btnRegister setTitle:LocalizedString(@"mianfeizhuce") forState:UIControlStateNormal];
    [_btnRegister setTitle:LocalizedString(@"mianfeizhuce") forState:UIControlStateHighlighted];
    [_btnFindPassWord setTitle:LocalizedString(@"wangjimima") forState:UIControlStateNormal];
    [_btnFindPassWord setTitle:LocalizedString(@"wangjimima") forState:UIControlStateHighlighted];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1)
    {
        [_textFieldPassWord becomeFirstResponder];
    }
    else
    {
        //调用登陆
        [self onTouchBtnLogin];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==_textFieldInfo) {
        
        NSString *userName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //如果有这个账号 自动填充密码
        ModelUserPassword *model = [ADOUserPassword queryWithUserName:userName];
        if (model) {
            _textFieldPassWord.text = model.password;
            _isAutoPassword = YES;
            
        }
        else if(_isAutoPassword)
        {
            //在自动填充密码的情况下, 更改用户名. 把密码置空.
            _textFieldPassWord.text = @"";
            _isAutoPassword = NO;
        }
        
    }
    return YES;
}

@end
