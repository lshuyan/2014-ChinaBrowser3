//
//  UIControllerPageStyle.m
//  ChinaBrowser
//
//  Created by David on 14/11/11.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerPageStyle.h"

#import "UIViewNav.h"

#import "AppLanguageProtocol.h"

#define kSectionTitle @"kSectionTitle"
#define kSectionFooter @"kSectionFooter"
#define kSectionCells @"kSectionCells"
#define kCellTitle @"kCellTitle"
#define kCellRightView @"kCellRightView"

@interface UIControllerPageStyle () <UITableViewDataSource, UITableViewDelegate, AppLanguageProtocol>
{
    UIViewNav *_viewNav;
    __weak IBOutlet UITableView *_tableView;
    
    UISwitch *_switchPageBtn;
    UISwitch *_switchTouchPage;
    
    NSArray *_arrDicSection;
    
    PageStyle _pageStyleOld;
}

@end

@implementation UIControllerPageStyle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageStyleOld = [AppSetting shareAppSetting].pageStyle;
    
    {
        _switchPageBtn = [[UISwitch alloc] init];
        _switchTouchPage = [[UISwitch alloc] init];
        
        _switchPageBtn.on = [AppSetting shareAppSetting].pageStyle.showPageBtn;
        _switchTouchPage.on = [AppSetting shareAppSetting].pageStyle.shouldTouchPage;
    }
    
    _arrDicSection = @[@{kSectionTitle:@"",
                         kSectionFooter:@"fanyeanniu_tishi",
                         kSectionCells:@[@{kCellTitle:@"fanyeanniu",
                                           kCellRightView:_switchPageBtn}]},
                       @{kSectionTitle:@"",
                         kSectionFooter:@"chupingfanye_tishi",
                         kSectionCells:@[@{kCellTitle:@"chupingfanye",
                                           kCellRightView:_switchTouchPage}]}];
    
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    [self.view addSubview:_viewNav];
    
    [self updateByLanguage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [_viewNav resizeWithOrientation:orientation];
    
    CGRect rc = self.view.bounds;
    rc.origin.y = _viewNav.bottom;
    rc.size.height = self.view.height-rc.origin.y;
    _tableView.frame = rc;
}

#pragma mark - private methods
- (void)onTouchBack
{
    if (_pageStyleOld.showPageBtn!=_switchPageBtn.on || _pageStyleOld.shouldTouchPage!=_switchTouchPage.on) {
        // 有修改翻页配置才 处理
        [AppSetting shareAppSetting].pageStyle = (PageStyle){_switchPageBtn.on, _switchTouchPage.on};
        // TODO: 通知处理 翻页方式
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidChangedPageStyle object:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AppLanguageProtocol
- (void)updateByLanguage
{
    _viewNav.title = self.title;
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(onTouchBack) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrDicSection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dicSection = _arrDicSection[section];
    NSArray *arrCells = dicSection[kSectionCells];
    NSInteger count = arrCells.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UICellPageStyle"];
    NSDictionary *dicSection = _arrDicSection[indexPath.section];
    NSDictionary *dicCell = dicSection[kSectionCells][indexPath.row];
    
    cell.textLabel.text = LocalizedString(dicCell[kCellTitle]);
    
    UISwitch *rightView = (UISwitch *)dicCell[kCellRightView];
    if (rightView) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    cell.accessoryView = rightView;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary *dicSection = _arrDicSection[section];
    return LocalizedString(dicSection[kSectionFooter]);
}

@end
