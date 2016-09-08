//
//  UIControllerRename.m
//  ChinaBrowser
//
//  Created by David on 14/11/28.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerRename.h"

#import "UIViewNav.h"

@interface UIControllerRename () <UITextFieldDelegate>
{
    UIViewNav *_viewNav;
    
    IBOutlet UITextField *_textFiled;
}

@end

@implementation UIControllerRename

- (void)setText:(NSString *)text
{
    _text = text;
    if (_textFiled) {
        _textFiled.text = text;
    }
}

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
    // Do any additional setup after loading the view from its nib.
    
    // ----------------
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(onTouchBack) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:LocalizedString(@"baocun") forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnSave addTarget:self action:@selector(onTouchSave) forControlEvents:UIControlEventTouchUpInside];
    [btnSave sizeToFit];
    
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    _viewNav.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSave];
    [self.view addSubview:_viewNav];
    
    _textFiled.backgroundColor = [UIColor whiteColor];
    _textFiled.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    _textFiled.layer.borderWidth = 0.5;
    _textFiled.delegate = self;
    _textFiled.placeholder = LocalizedString(@"qingshurumoshiming");
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _textFiled.leftView = leftView;
    _textFiled.leftViewMode = UITextFieldViewModeAlways;
    
    if (_text) {
        _textFiled.text = _text;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [_viewNav resizeWithOrientation:orientation];
    
    _textFiled.frame = CGRectMake(-1, _viewNav.bottom+20, self.view.width+2, 40);
}

#pragma mark - private methods
- (void)onTouchBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTouchSave
{
    if (_callbackDidEdit) {
        _callbackDidEdit(_textFiled.text);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length]<=0) {
        [SVProgressHUD showErrorWithStatus:_textFiled.placeholder];
        return NO;
    }
    
    [self.view endEditing:YES];
    [self onTouchSave];
    
    return YES;
}

@end