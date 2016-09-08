//
//  UIViewFindInWebPage.m
//  ChinaBrowser
//
//  Created by David on 14/11/14.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewFindInWebPage.h"

@interface UIViewFindInWebPage () <UITextFieldDelegate>

@end

@implementation UIViewFindInWebPage
{
    __weak IBOutlet UIView *_viewInput;
    __weak IBOutlet UIButton *_btnCancel;
    __weak IBOutlet UIImageView *_imageViewIcon;
}

#pragma mark - property
- (void)setNumber:(NSInteger)number
{
    _currIndex = 0;
    _number = number;
    
    if (_number<=0) {
        _labelIndexTotal.text = nil;
    }
    else {
        _labelIndexTotal.text = [NSString stringWithFormat:@"%ld/%ld", (long)((_number>0)?(_currIndex+1):0), (long)_number];
    }
    [_labelIndexTotal sizeToFit];
    
    _btnPrev.enabled = _currIndex>0;
    _btnNext.enabled = (_currIndex+1<_number);
}

- (void)setCurrIndex:(NSInteger)currIndex
{
    _currIndex = currIndex;
    
    _labelIndexTotal.text = [NSString stringWithFormat:@"%ld/%ld", (long)((_number>0)?(_currIndex+1):0), (long)_number];
    [_labelIndexTotal sizeToFit];
    
    _btnNext.enabled = (_currIndex+1<_number);
    _btnPrev.enabled = _currIndex>0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _viewInput.backgroundColor = [UIColor whiteColor];
    _viewInput.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.].CGColor;
    _viewInput.layer.borderWidth = 0.6;
    _viewInput.layer.cornerRadius = 6;
    
    self.backgroundColor = kBgColorNav;
    [_btnCancel setTitle:LocalizedString(@"quxiao") forState:UIControlStateNormal];
    _textField.placeholder = LocalizedString(@"shuruchazhaoneirong");
    _imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/Settings/FindInPage/search.png"];
    
    [_btnPrev setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/FindInPage/page_0_0.png"] forState:UIControlStateNormal];
    [_btnPrev setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/FindInPage/page_0_1.png"] forState:UIControlStateHighlighted];
    [_btnNext setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/FindInPage/page_1_0.png"] forState:UIControlStateNormal];
    [_btnNext setImage:[UIImage imageWithBundleFile:@"iPhone/Settings/FindInPage/page_1_1.png"] forState:UIControlStateHighlighted];
    
    _labelIndexTotal.text = @"18/50";
    _textField.leftView = _imageViewIcon;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    
    _textField.rightView = _labelIndexTotal;
    _textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    
    [_labelIndexTotal sizeToFit];
    
    _btnPrev.enabled =
    _btnNext.enabled = NO;
    
    [self setNumber:0];
}

+ (instancetype)viewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
}

- (void)showInView:(UIView *)view completion:(void(^)())completion
{
    CGRect rc = view.bounds;
    rc.size.height = view.height;
    rc.origin.y = 0;
    self.frame = rc;
    
    self.alpha = 1;
    self.transform = CGAffineTransformMakeTranslation(0, -view.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismissWithCompletion:(void(^)())completion
{
    [_delegate viewFindInWebPageDidEnd:self];
    [self endEditing:YES];
    [UIView animateWithDuration:0.35 animations:^{
//        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, -self.superview.height);;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        
        [self removeFromSuperview];
    }];
}

#pragma mark - private methods
- (IBAction)onTouchCancel
{
    [self dismissWithCompletion:nil];
}

- (IBAction)onTouchPrev
{
    [_delegate viewFindInWebPageFindPrev:self];
}

- (IBAction)onTouchNext
{
    [_delegate viewFindInWebPageFindNext:self];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_delegate viewFindInWebPageDidBegin:self];
    _btnPrev.enabled =
    _btnNext.enabled = NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.number = 0;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_delegate viewFindInWebPage:self findWithKeyword:textField.text];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _btnPrev.enabled = _currIndex>0;
    _btnNext.enabled = (_currIndex+1<_number);
}

@end
