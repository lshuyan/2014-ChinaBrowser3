//
//  UIControllerRegister.m
//  login
//
//  Created by HHY on 14-10-24.
//  Copyright (c) 2014年 koto. All rights reserved.
//

#import "UIControllerRegister.h"

#import "UIControllerLogin.h"
#import "UIControllerUserInfo.h"
#import "UIControllerWebview.h"

@interface UIControllerRegister ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    AFJSONRequestOperation *_reqRegister;
    UIButton *_btnResign;
    //用于密文状态下,刚输入的字符转换密文判断.
    NSString *_string;
}
@end

@implementation UIControllerRegister

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
    
    _textFieldInfo.delegate = self;
    _textFieldPassword.delegate = self;
    _textFieldNick.delegate = self;
    _textFieldInfo.autocapitalizationType =
    _textFieldPassword.autocapitalizationType =
    _textFieldNick.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textFieldPassword.clearsOnBeginEditing = NO;
    
    _btnResign = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnResign addTarget:self action:@selector(myResignFirstResponder) forControlEvents:UIControlEventTouchDown];
    [_scrollView addSubview:_btnResign];
    [_scrollView sendSubviewToBack:_btnResign];
    _scrollView.delegate = self;
    self.title = LocalizedString(@"zhuce");
    
    //按label.text 字符串宽度 设置 label 的size
    CGRect rect = _labelAgree.frame;
    CGSize size = [_labelAgree.text sizeWithFont:_labelAgree.font constrainedToSize:CGSizeMake(_labelAgree.frame.size.width+100, _labelAgree.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    rect.size=size;
    _labelAgree.frame=rect;
    
    rect = _btnDelegate.frame;
    rect.origin.x = _labelAgree.frame.origin.x + size.width + 5;
    _btnDelegate.frame=rect;
    
    [self registerForKeyboardNotifications];
    
    _textFieldPassword.inputView.backgroundColor = [UIColor orangeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  屏幕旋转
 *
 *  @param toInterfaceOrientation
 *  @param duration
 */
-(void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIUserInterfaceIdiomPad==UI_USER_INTERFACE_IDIOM()) return;
    
    [_viewNav resizeWithOrientation:orientation];
    
    CGRect rc = _scrollView.frame;
    rc.origin.y = _viewNav.bottom;
    rc.size.height = self.view.height-rc.origin.y;
    _scrollView.frame = rc;
    
    rc = _btnDelegate.frame;
    rc.size.width = self.view.width - rc.origin.x - 20;
    
    _scrollView.contentSize = CGSizeMake(0, _btnRegister.bottom + 10);
    _btnResign.frame = CGRectMake(0, _scrollView.contentOffset.y, _scrollView.width, _scrollView.contentSize.height);
}

#pragma mark - private methods
/**
 *  注册键盘通知
 */
- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
}

//实现当键盘出现的时候计算键盘的高度大小。用于设置scrollView的contentSize;
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    float kbheight;
    //kbSize即為鍵盤尺寸 (有width, height)
//    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
//        
//    }
//    else
//    {
//        kbheight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
//    }
    kbheight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    //得到鍵盤的高度
    if (kbheight>300) {
        kbheight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    }
    CGRect rect = _scrollView.frame;
    
    rect.size.height = self.view.bounds.size.height-rect.origin.y-kbheight;
    _scrollView.frame = rect;
    
    rect.size.height = _btnRegister.frame.origin.y+_btnRegister.frame.size.height+10;
    _scrollView.contentSize = rect.size;
    
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect rect = _scrollView.frame;
    rect.size.height = self.view.bounds.size.height-rect.origin.y;
    _scrollView.frame = rect;
    rect.size.height = _btnRegister.frame.origin.y+_btnRegister.frame.size.height+10;
    _scrollView.contentSize = CGSizeMake(0, _btnRegister.bottom + 10);
    self.navigationItem.leftBarButtonItem = nil;
}

//当点击View时  放弃输入框
-(void)myResignFirstResponder
{
    [_textFieldNick resignFirstResponder];
    [_textFieldInfo resignFirstResponder];
    [_textFieldPassword resignFirstResponder];
}

//申请注册
-(void)reqRegisterFoInfo:(NSString *)info passwd:(NSString *)passwd nick:(NSString *)nick controller:(UIControllerBase *)controller
{
    
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:LocalizedString(@"zhengzaizhuce") maskType:SVProgressHUDMaskTypeClear];
    [_reqRegister cancel];
    _reqRegister = nil;
    
    NSDictionary *dicParam = @{@"passwd":passwd,
                               @"username":info,
                               @"nickname":nick,
                               @"device":IsiPad?@"ipad":@"iphone"};
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSMutableURLRequest *req = [client requestWithMethod:@"POST" path:GetApiWithName(API_UserRegister) parameters:dicParam];
    
    _reqRegister = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        _DEBUG_LOG(@"\n------sns Register result:%@", JSON);
        
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
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"lianjieshibai")];
    }];
    [_reqRegister start];
    
}

- (void)onTouchBtnback
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  密文转换
 *
 *  @param sender
 */
- (IBAction)onTouchToPasswordsecurTextEntryBut:(UIButton *)sender {

    if (_textFieldPassword.secureTextEntry) {
        _labelPwd.text = _textFieldPassword.text;
        _textFieldPassword.secureTextEntry = NO;
    }
    else
    {
        _textFieldPassword.secureTextEntry = YES;
        _labelPwd.text = @"";
        for (int i = 0; i<_textFieldPassword.text.length; i++) {
            _labelPwd.text = [_labelPwd.text stringByAppendingString:@"●"];
        }
    }
    if(_textFieldPassword.becomeFirstResponder)
    {
        [_textFieldPassword becomeFirstResponder];
    }
}

//注册方法
- (IBAction)onTouchBtnResiter:(id)sender
{
    
    //账号密码不能为空
    if ([_textFieldInfo.text length]==0) {
        //[alert show];
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshuruyouxiang_shouji")];
    }
    else if([_textFieldPassword.text length]==0)
    {
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshurumima")];
    }
    else if(!(IsValidEmail(_textFieldInfo.text, YES) || IsValidMobilePhoneNum(_textFieldInfo.text)))
    {
        //用户名格式错误
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshuruzhengquedeyouxiangdizhi_shoujihao")];
        //        alert.message = LocalizedString(@"yonghuminggeshicuowu");
        //        [alert show];
    }
    else if(!(IsValidPassword(_textFieldPassword.text)))
    {
        [SVProgressHUD showErrorWithStatus:LocalizedString(@"qingshuru6_16weishuzihuozimudemima")];
    }
    else
    {
        [self reqRegisterFoInfo:_textFieldInfo.text passwd:_textFieldPassword.text nick:_textFieldNick.text controller:self];
        
    }
}

- (IBAction)onTouchBtnAgree
{
    _btnAgree.selected = !_btnAgree.selected;
    if (_btnAgree.selected) {
        _btnRegister.userInteractionEnabled = NO;
        _btnRegister.alpha = 0.8;
        [_btnRegister setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_btnRegister setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/choose_1.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1] forState:UIControlStateNormal];
        
    }
    else
    {
        _btnRegister.userInteractionEnabled = YES;
        _btnRegister.alpha = 1;
        [_btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnRegister setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/log_in_0.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
    }
}

/**
 *  中华浏览器用户服务协议
 */
- (IBAction)onTouchProtocol
{
    UIControllerWebview *controllerWebview = [[UIControllerWebview alloc] init];
    controllerWebview.link = GetApiWithName(API_UserProtocol);
    controllerWebview.title = LocalizedString(@"zhonghualiulanqiyonghufuwuxieyi");
    [self.navigationController pushViewController:controllerWebview animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==_textFieldPassword) {
        
        NSString *pwd = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //用于密文状态下,刚输入的字符转换密文判断.
        _string = string;
        //输入长度超过16不允许输入
        if (pwd.length >= 17) return NO;
         _DEBUG_LOG(@"%s pwd=:%@  range.length == %@  string = %@", __FUNCTION__, pwd, NSStringFromRange(range), string);
        if (_textFieldPassword.secureTextEntry == NO)
        {
           //明文
            _labelPwd.text = pwd;
        }
        else
        {
            //密文
            if([string isEqualToString:@""]){
                //删除(退格)
                _labelPwd.text = @"";
                //先把输入前的全转变为*
                for (int i = 0; i<pwd.length; i++) {
                    _labelPwd.text = [_labelPwd.text stringByAppendingString:@"●"];
                }

            }
            else
            {
                //输入
                _labelPwd.text = @"";
                //先把输入前的全转变为*
                for (int i = 0; i<pwd.length-1; i++) {
                    _labelPwd.text = [_labelPwd.text stringByAppendingString:@"●"];
                }
                //再把刚刚输入的 先明文显示
                _labelPwd.text = [_labelPwd.text stringByReplacingCharactersInRange:range withString:string];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //两秒后
                   //_string == string 说明没有再输入  并且  是密文状态.  输入的文字由明文转*
                    if ((_string == string) && _textFieldPassword.secureTextEntry) {
                        NSString *aString = @"";
                        if (![string isEqualToString:@""]) {
                            for (int i = 0; i<string.length; i++) {
                                aString = [aString stringByAppendingString:@"●"];
                            }
                        }
                        NSRange aRange = NSMakeRange(range.location, string.length);
                        _labelPwd.text = [_labelPwd.text stringByReplacingCharactersInRange:aRange withString:aString];
                    }
                    
                });
            }
        }
        _textFieldPassword.text = pwd;
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _textFieldInfo)
    {
        //        [self getOffsetPoint:[_textFieldPassword superview]];
        
        [_textFieldNick becomeFirstResponder];
    }
    else if(textField == _textFieldNick)
    {
        [_textFieldPassword becomeFirstResponder];
    }
    else
    {
        //调用注册
        [self onTouchBtnResiter:nil ];
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField == _textFieldPassword)
    {
        
         _labelPwd.text = @"";
        //防止密文状态下输入的字符还没有转换成密文时 点击了clear崩溃
        _string = nil;
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    CGRect rc = _btnResign.frame;
    rc.origin.y = scrollView.contentOffset.y;
    _btnResign.frame = rc;
}

#pragma mark - AppLanguageProtocol
-(void)updateByLanguage
{
    self.title = LocalizedString(@"zhuce");
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    [self.view addSubview:_viewNav];
    
    _textFieldInfo.leftView = [[UIImageView alloc]initWithImage:[UIImage imageWithBundleFile:@"iPhone/User/account.png"]];
    _textFieldInfo.leftViewMode = UITextFieldViewModeAlways;
    [_textFieldInfo.layer setBorderWidth:1];
    [_textFieldInfo.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    _textFieldPassword.leftView = [[UIImageView alloc]initWithImage:[UIImage imageWithBundleFile:@"iPhone/User/password.png"]];
    _textFieldPassword.leftViewMode = UITextFieldViewModeAlways;
    [_textFieldPassword.layer setBorderWidth:1];
    [_textFieldPassword.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    _textFieldNick.leftView = [[UIImageView alloc]initWithImage:[UIImage imageWithBundleFile:@"iPhone/User/name.png"]];
    _textFieldNick.leftViewMode = UITextFieldViewModeAlways;
    [_textFieldNick.layer setBorderWidth:1];
    [_textFieldNick.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    _btnTextPassword.userInteractionEnabled = YES;
    [_btnTextPassword setImage:[UIImage imageWithBundleFile:@"iPhone/User/eyes_0.png"] forState:UIControlStateNormal];
    [_btnTextPassword setImage:[UIImage imageWithBundleFile:@"iPhone/User/eyes_1.png"] forState:UIControlStateHighlighted];
    [_btnTextPassword.layer setBorderWidth:1];
    [_btnTextPassword.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    [_btnDelegate setTitle:LocalizedString(@"zhonghualiulanqiyonghufuwuxieyi") forState:UIControlStateNormal];
    _labelAgree.text = LocalizedString(@"tongyi");
    [_btnRegister setTitle:LocalizedString(@"zhuce") forState:UIControlStateNormal];
    [_btnRegister setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/log_in_0.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
    [_btnRegister setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/log_in_1.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateHighlighted];
    
    [_btnAgree setBackgroundImage:[UIImage imageWithBundleFile:@"iPhone/User/choose_0.png"] forState:UIControlStateNormal];
    [_btnAgree setBackgroundImage:[UIImage imageWithBundleFile:@"iPhone/User/choose_1.png"] forState:UIControlStateSelected];
    //左边导航栏
    UIButton *btnBack =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(onTouchBtnback) forControlEvents:UIControlEventTouchUpInside];
    [btnBack sizeToFit];
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
    
    _textFieldInfo.placeholder = LocalizedString(@"youxiang_shoujihao");
    _textFieldNick.placeholder = LocalizedString(@"nicheng");
    _textFieldPassword.placeholder = LocalizedString(@"6_16weishuzihuozimu");
}

@end
