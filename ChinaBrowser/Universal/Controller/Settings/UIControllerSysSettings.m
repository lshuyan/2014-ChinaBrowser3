//
//  UIControllerSysSettings.m
//  ChinaBrowser
//
//  Created by David on 14/11/7.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerSysSettings.h"

#import "UIViewNav.h"
#import "UICellUserLogin.h"
#import "UICellSysSettings.h"

#import "UIViewPopUrlOpenStyle.h"
#import "UIViewPopSearchEngine.h"
#import "UIViewPopSetFontSize.h"
#import "UIViewPopUserAgent.h"

#import "UIControllerUserInfo.h"
#import "UIControllerLogin.h"
#import "UIControllerPageStyle.h"
#import "UIControllerAboutUs.h"
#import "UIControllerClearCache.h"

#import "ModelUser.h"
#import "ModelSearchEngine.h"

#import "BlockUI.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#define  kSectionTitle @"kSectionTitle"
#define  kCells @"kCells"

#define kTitle @"title"
#define kSubTitle @"kSubTitle"
#define kRightView @"kRightView"
#define kRightHasArrow @"kRightHasArrow"
#define kSettingsCellType @"kSettingsCellType"

typedef NS_ENUM(NSInteger, SettingsCellType) {
    SettingsCellUserLogin,
    
    SettingsCellOpenLastWeb,
    SettingsCellUrlOpenStyle,
    SettingsCellFontSize,
    SettingsCellSearchEngine,
    SettingsCellRemotePush,
    SettingsCellAdBlocker,
    SettingsCellScreenRotate,
    SettingsCellDownload,
    SettingsCellPageStyle,
    
    SettingsCellSaveForm,
    SettingsCellClearHistory,
    
    SettingsCellDefaultBrowser,
    SettingsCellUserAgent,
    SettingsCellAbout,
    
    SettingsCellReset,
    SettingsCellRate
};

@interface UIControllerSysSettings () <UITableViewDataSource, UITableViewDelegate, UIViewPopUrlOpenStyleDelegate, UIViewPopSearchEngineDelegate, UIViewPopSetFontSizeDelegate, UIViewPopUserAgentDelegate>

@end

@implementation UIControllerSysSettings
{
    NSArray *_arrDicCell;
    
    UIViewNav *_viewNav;
    __weak IBOutlet UITableView *_tableView;
    
    UICellUserLogin *_cellUserLogin;
    
    UISwitch *_switchOpenLastWeb;
    UISwitch *_switchRemotePush;
    
    UILabel *_rightViewUrlOpenStyle;
    UILabel *_rightViewFontSize;
    UILabel *_rightViewSearchEngine;
    UILabel *_rightViewPageStyle;
    
    UILabel *_rightViewClearHistory;
    
    UILabel *_rightViewUserAgent;
    UILabel *_rightViewAbout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginNotification:) name:KNotificationDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogoutNotification:) name:KNotificationDidLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangedUserInfo:) name:KNotificationDidUpdateUserInfo object:nil];
    
    {
        _switchOpenLastWeb = [[UISwitch alloc] init];
        [_switchOpenLastWeb addTarget:self action:@selector(onTouchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        _switchRemotePush = [[UISwitch alloc] init];
        [_switchRemotePush addTarget:self action:@selector(onTouchValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        _rightViewUrlOpenStyle = [[UILabel alloc] init];
        
        _rightViewFontSize = [[UILabel alloc] init];
        
        _rightViewSearchEngine = [[UILabel alloc] init];
        
        _rightViewPageStyle = [[UILabel alloc] init];
        
        _rightViewClearHistory = [[UILabel alloc] init];
        
        _rightViewUserAgent = [[UILabel alloc] init];
        
        _rightViewAbout = [[UILabel alloc] init];
        
        _rightViewUrlOpenStyle.font =
        _rightViewFontSize.font =
        _rightViewSearchEngine.font =
        _rightViewPageStyle.font =
        _rightViewClearHistory.font =
        _rightViewUserAgent.font =
        _rightViewAbout.font = [UIFont systemFontOfSize:12];
        
        _rightViewUrlOpenStyle.textColor =
        _rightViewFontSize.textColor =
        _rightViewSearchEngine.textColor =
        _rightViewPageStyle.textColor =
        _rightViewClearHistory.textColor =
        _rightViewUserAgent.textColor =
        _rightViewAbout.textColor = [UIColor grayColor];
        
        _switchRemotePush.on = [AppSetting shareAppSetting].remotePush;
        _switchOpenLastWeb.on = [AppSetting shareAppSetting].openLastWebsite;
        
        _rightViewUrlOpenStyle.text = StringFromUrlOpenStyle([AppSetting shareAppSetting].urlOpenStyle);
        ModelSearchEngine *model = [AppSetting shareAppSetting].arrSearchEngine[[AppSetting shareAppSetting].searchIndex];
        _rightViewSearchEngine.text = model.name;
        _rightViewFontSize.text = [@([AppSetting shareAppSetting].fontsize) stringValue];
        _rightViewUserAgent.text = LocalizedString([AppSetting shareAppSetting].userAgent);
    }
    
    {
        _arrDicCell = @[@{kSectionTitle:@"",
                          kCells:@[@{kTitle:@"weidenglu",
                                     kSettingsCellType:@(SettingsCellUserLogin),
                                     kRightHasArrow:@(YES)}]},
                        @{kSectionTitle:@"",
                          kCells:@[/*@{kTitle:@"kaiqishidakaishangciyemian",
                                     kRightView:_switchOpenLastWeb,
                                     kSettingsCellType:@(SettingsCellOpenLastWeb),
                                     kSubTitle:@"",
                                     kRightHasArrow:@(NO)},
                                   @{kTitle:@"lianjiedakaifangshi",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellUrlOpenStyle),
                                     kRightView:_rightViewUrlOpenStyle,
                                     kRightHasArrow:@(YES)},*/
                                   @{kTitle:@"zitidaxiao",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellFontSize),
                                     kRightView:_rightViewFontSize,
                                     kRightHasArrow:@(YES)},
                                   @{kTitle:@"morensousuoyinqing",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellSearchEngine),
                                     kRightView:_rightViewSearchEngine,
                                     kRightHasArrow:@(YES)},
                                   @{kTitle:@"xiaoxituisong",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellRemotePush),
                                     kRightView:_switchRemotePush,
                                     kRightHasArrow:@(NO)}/*,
                                   @{kTitle:@"fanyefangshi",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellPageStyle),
                                     kRightView:_rightViewPageStyle,
                                     kRightHasArrow:@(YES)}*/]},
                        @{kSectionTitle:@"",
                          kCells:@[@{kTitle:@"xiaochujilu",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellClearHistory),
                                     kRightView:_rightViewClearHistory,
                                     kRightHasArrow:@(YES)}]},
                        @{kSectionTitle:@"",
                          kCells:@[@{kTitle:@"liulanqibiaozhi",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellUserAgent),
                                     kRightView:_rightViewUserAgent,
                                     kRightHasArrow:@(YES)},
                                   @{kTitle:@"guanyuzhonghualiulanqi",
                                     kSubTitle:@"",
                                     kSettingsCellType:@(SettingsCellAbout),
                                     kRightView:_rightViewAbout,
                                     kRightHasArrow:@(YES)}]},
                        @{kSectionTitle:@"",
                          kCells:@[@{kTitle:@"huifumorenshezhi",
                                     kSettingsCellType:@(SettingsCellReset),
                                     kSubTitle:@"",
                                     kRightHasArrow:@(NO)}]},
                        @{kSectionTitle:@"",
                          kCells:@[@{kTitle:@"qin_geige5xinghaopingba",
                                     kSettingsCellType:@(SettingsCellRate),
                                     kSubTitle:@"",
                                     kRightHasArrow:@(NO)}]}
                        ];
    }
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    [self.view addSubview:_viewNav];
    
    [self updateByLanguage];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTouchValueChanged:(UISwitch *)swt
{
    NSIndexPath *indexPath = [self indexPathFromTag:swt.tag];
    NSDictionary *dicSection = _arrDicCell[indexPath.section];
    NSArray *arrCellss = dicSection[kCells];
    NSMutableDictionary *dicCell = arrCellss[indexPath.row];
    SettingsCellType settingsCellType = (SettingsCellType)[dicCell[kSettingsCellType] integerValue];
    switch (settingsCellType) {
        case SettingsCellOpenLastWeb:
        {
            [AppSetting shareAppSetting].openLastWebsite = swt.on;
        }break;
        case SettingsCellRemotePush:
        {
            [AppSetting shareAppSetting].remotePush = swt.on;
        }break;
        default:
            break;
    }
}

- (NSInteger)tagFromIndexPath:(NSIndexPath *)indexPath
{
    return 1000*indexPath.section+indexPath.row;
}

- (NSIndexPath *)indexPathFromTag:(NSInteger)tag
{
    return [NSIndexPath indexPathForRow:tag%1000 inSection:tag/1000];
}

- (void)didLoginNotification:(NSNotification *)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICellUserLogin *cellUserLogin = (UICellUserLogin *)[_tableView cellForRowAtIndexPath:indexPath];
    cellUserLogin.labelTitle.text = [UserManager shareUserManager].currUser.nickname;
    [cellUserLogin.imageViewIcon setImageWithURL:[NSURL URLWithString:[UserManager shareUserManager].currUser.avatar] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void)didLogoutNotification:(NSNotification *)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSDictionary *dicSection = _arrDicCell[indexPath.section];
    NSArray *arrCellss = dicSection[kCells];
    NSDictionary *dicCell = arrCellss[indexPath.row];
    UICellUserLogin *cellUserLogin = (UICellUserLogin *)[_tableView cellForRowAtIndexPath:indexPath];
    cellUserLogin.labelTitle.text = LocalizedString(dicCell[kTitle]);
    cellUserLogin.imageViewIcon.image = [UIImage imageWithBundleFile:@"ad_default.jpg"];
}

- (void)didChangedUserInfo:(NSNotification *)notication
{
    _cellUserLogin.labelTitle.text = [UserManager shareUserManager].currUser.username;
    [_cellUserLogin.imageViewIcon setImageWithURL:[NSURL URLWithString:[UserManager shareUserManager].currUser.avatar] placeholderImage:_cellUserLogin.imageViewIcon.image];
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
    return _arrDicCell.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dicSection = _arrDicCell[section];
    return [dicSection[kCells] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UICellSysSettings *cell = (UICellSysSettings *)[tableView dequeueReusableCellWithIdentifier:indexPath.section==0?@"UICellUserLogin":@"UICellSysSettings"];
    if (!cell) {
        if (indexPath.section==0) {
            cell = [UICellUserLogin cellFromXib];
        }
        else {
            cell = [UICellSysSettings cellFromXib];
        }
    }
    
    NSDictionary *dicSection = _arrDicCell[indexPath.section];
    NSArray *arrCell = dicSection[kCells];
    NSDictionary *dicCell = arrCell[indexPath.row];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section==0) {
        if (!_cellUserLogin)
        {
            _cellUserLogin = (UICellUserLogin *)cell;
            if ([UserManager shareUserManager].currUser)
            {
                _cellUserLogin.labelTitle.text = [UserManager shareUserManager].currUser.nickname;
                [_cellUserLogin.imageViewIcon setImageWithURL:[NSURL URLWithString:[UserManager shareUserManager].currUser.avatar]
                                             placeholderImage:[UIImage imageWithBundleFile:@"iPhone/User/avatar_default.png"]
                                  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
            else
            {
                _cellUserLogin.labelTitle.text = LocalizedString(dicCell[kTitle]);
                _cellUserLogin.imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/User/avatar_default.png"];
            }
        }
    }
    else {
        cell.textLabel.text = LocalizedString(dicCell[kTitle]);
        cell.detailTextLabel.text = LocalizedString(dicCell[kSubTitle]);
    }
    
    BOOL hasArrow = [dicCell[kRightHasArrow] boolValue];
    cell.accessoryType = hasArrow?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    
    // right view
    UIView *accessoryView = dicCell[kRightView];
    cell.rightView = accessoryView;
    if (accessoryView) {
        cell.rightView.tag = [self tagFromIndexPath:indexPath];
        if ([accessoryView isKindOfClass:[UISwitch class]]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            accessoryView.backgroundColor = [UIColor clearColor];
        }
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    // text color
    if (indexPath.section==_arrDicCell.count-1) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    }
    else if (indexPath.section==_arrDicCell.count-2) {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section==0?61:44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dicSection = _arrDicCell[section];
    return dicSection[kSectionTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dicSection = _arrDicCell[indexPath.section];
    NSArray *arrCellss = dicSection[kCells];
    NSMutableDictionary *dicCell = arrCellss[indexPath.row];
    SettingsCellType settingsCellType = (SettingsCellType)[dicCell[kSettingsCellType] integerValue];
    switch (settingsCellType) {
        case SettingsCellUserLogin:
        {
            if ([UserManager shareUserManager].currUser) {
                UIControllerUserInfo *controller = [UIControllerUserInfo controllerFromXib];
                controller.fromController = FromControllerSystemSettings;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else {
                UIControllerLogin *controllerLogin = [UIControllerLogin controllerFromXib];
                controllerLogin.fromController = FromControllerSystemSettings;
                [self.navigationController pushViewController:controllerLogin animated:YES];
            }
        }break;
        case SettingsCellUrlOpenStyle:
        {
            UIViewPopUrlOpenStyle *viewPop = [UIViewPopUrlOpenStyle viewFromXib];
            viewPop.delegate = self;
            viewPop.labelTitle.text = LocalizedString(@"lianjiedakaifangshi");
            [viewPop.btnRight setTitle:LocalizedString(@"queding") forState:UIControlStateNormal];
            [viewPop showInView:self.view completion:nil];
        }break;
        case SettingsCellFontSize:
        {
            UIViewPopSetFontSize *viewPop = [UIViewPopSetFontSize viewFromXib];
            viewPop.delegate = self;
            viewPop.labelTitle.text = LocalizedString(@"shezhizitidaxiao");
            [viewPop.btnRight setTitle:LocalizedString(@"queding") forState:UIControlStateNormal];
            [viewPop showInView:self.view completion:nil];
        }break;
        case SettingsCellSearchEngine:
        {
            UIViewPopSearchEngine *viewPop = [UIViewPopSearchEngine viewFromXib];
            viewPop.deletate = self;
            viewPop.labelTitle.text = LocalizedString(@"xuanzemorensousuoyinqing");
            [viewPop.btnRight setTitle:LocalizedString(@"queding") forState:UIControlStateNormal];
            [viewPop showInView:self.view completion:nil];
        }break;
        case SettingsCellScreenRotate:
        {
            
        }break;
        case SettingsCellDownload:
        {
            
        }break;
        case SettingsCellPageStyle:
        {
            UIControllerPageStyle *controller = [UIControllerPageStyle controllerFromXib];
            controller.title = LocalizedString(@"fanyefangshi");
            [self.navigationController pushViewController:controller animated:YES];
        }break;
        case SettingsCellSaveForm:
        {
            
        }break;
        case SettingsCellClearHistory:
        {
            UIControllerClearCache *controllerClear = [UIControllerClearCache controllerFromXib];
            controllerClear.title = LocalizedString(@"qingchujilu");
            [self.navigationController pushViewController:controllerClear animated:YES];
        }break;
        case SettingsCellDefaultBrowser:
        {
            
        }break;
        case SettingsCellUserAgent:
        {
            UIViewPopUserAgent *viewPop = [UIViewPopUserAgent viewFromXib];
            viewPop.delegate = self;
            viewPop.labelTitle.text = LocalizedString(@"liulanqibiaozhi");
            [viewPop.btnRight setTitle:LocalizedString(@"queding") forState:UIControlStateNormal];
            [viewPop showInView:self.view completion:nil];
            
        }break;
        case SettingsCellAbout:
        {
            UIControllerAboutUs *controllerAbout = [UIControllerAboutUs controllerFromXib];
            controllerAbout.title = LocalizedString(@"guanyuzhonghualiulanqi");
            [self.navigationController pushViewController:controllerAbout animated:YES];
        }break;
        case SettingsCellReset:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:LocalizedString(@"quedingyaohuifumorenshezhi")
                                                                     delegate:nil
                                                            cancelButtonTitle:LocalizedString(@"quxiao")
                                                       destructiveButtonTitle:LocalizedString(@"huifumorenshezhi")
                                                            otherButtonTitles:nil];
            UIView *view = [[UIApplication sharedApplication].windows[0] rootViewController].view;
            [actionSheet showInView:view withCompletionHandler:^(NSInteger buttonIndex) {
                if (buttonIndex==actionSheet.cancelButtonIndex) {
                    return;
                }
                
                [[AppSetting shareAppSetting] reset];
                
                _switchRemotePush.on = [AppSetting shareAppSetting].remotePush;
                _switchOpenLastWeb.on = [AppSetting shareAppSetting].openLastWebsite;
                
                _rightViewUrlOpenStyle.text = StringFromUrlOpenStyle([AppSetting shareAppSetting].urlOpenStyle);
                ModelSearchEngine *model = [AppSetting shareAppSetting].arrSearchEngine[[AppSetting shareAppSetting].searchIndex];
                _rightViewSearchEngine.text = model.name;
                _rightViewFontSize.text = [@([AppSetting shareAppSetting].fontsize) stringValue];
                _rightViewUserAgent.text = LocalizedString([AppSetting shareAppSetting].userAgent);
                
                [_tableView reloadData];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidChanageDesktopStyle object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidChangedFontSize object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidChangedSearchEngine object:nil];
            }];
        }break;
        case SettingsCellRate:
        {
            NSString *link = [NSString stringWithFormat:API_AppStoreRate, kAppId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
        }break;
            
        default:
            break;
    }
}

#pragma mark - UIViewPopUrlOpenStyleDelegate
- (void)viewPopUrlOpenStyle:(UIViewPopUrlOpenStyle *)viewPopUrlOpenStyle selectUrlOpenStyle:(UrlOpenStyle)urlOpenStyle
{
    [AppSetting shareAppSetting].urlOpenStyle = urlOpenStyle;
    _rightViewUrlOpenStyle.text = StringFromUrlOpenStyle(urlOpenStyle);
    [_tableView reloadData];
}

#pragma mark - UIViewPopSearchEngineDelegate
- (void)viewPopSearchEngine:(UIViewPopSearchEngine *)viewPopSearchEngine selectSearchIndex:(NSInteger)searchIndex
{
    [AppSetting shareAppSetting].searchIndex = searchIndex;
    ModelSearchEngine *model = [AppSetting shareAppSetting].arrSearchEngine[[AppSetting shareAppSetting].searchIndex];
    _rightViewSearchEngine.text = model.name;
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidChangedSearchEngine object:nil];
}

#pragma mark - UIViewPopSetFontSizeDelegate
- (void)viewPopSetFontSize:(UIViewPopSetFontSize *)viewPopSetFontSize selectFontSize:(CGFloat)fontSize
{
    [AppSetting shareAppSetting].fontsize = fontSize;
    _rightViewFontSize.text = [@((NSInteger)fontSize) stringValue];
    [_tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationDidChangedFontSize object:nil];
}

#pragma mark - UIViewPopUserAgentDelegate
- (void)viewPopUserAgent:(UIViewPopUserAgent *)viewPopUserAgent selectUserAgentIndex:(NSInteger)userAgentIndex
{
    [AppSetting shareAppSetting].userAgentIndex = userAgentIndex;
    _rightViewUserAgent.text = [AppSetting shareAppSetting].userAgent;
    [_tableView reloadData];
}

@end
