//
//  UIControllerWebview.m
//  ChinaBrowser
//
//  Created by David on 14/12/17.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerWebview.h"

#import "UIViewNav.h"

@interface UIControllerWebview () <UIWebViewDelegate>
{
    UIViewNav *_viewNav;
    UIWebView *_webView;
}

@end

@implementation UIControllerWebview

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = YES;
    
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    [self.view addSubview:_viewNav];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(onTouchBack) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_link] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30]];
    [self.view addSubview:_webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [_viewNav resizeWithOrientation:orientation];
    
    _webView.frame = CGRectMake(0, _viewNav.bottom, self.view.width, self.view.height-_viewNav.bottom);
}

#pragma mark - private methods
- (void)onTouchBack
{
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
    
    [SVProgressHUD dismiss];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}

@end
