//
//  UIControllerModeDetail.m
//  ChinaBrowser
//
//  Created by David on 14/11/29.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerModeDetail.h"

#import "UIViewNav.h"

#import "UIViewSync.h"
#import "UICellModeProgram.h"

#import "UIControllerAddProgram.h"

#import "ModelMode.h"
#import "ModelProgram.h"
#import "ModelModeProgram.h"
#import "ModelSyncDelete.h"

#import "ADOModeProgram.h"
#import "ADOSyncDelete.h"

#import "FMLocalNotificationManager.h"

@interface UIControllerModeDetail () <UITableViewDataSource, UITableViewDelegate>
{
    UIViewNav *_viewNav;
    UIViewSync *_viewSync;
    __weak IBOutlet UITableView *_tableView;
    
    NSMutableArray *_arrModeProgram;
    ModelModeProgram *_editingModelModeProgram;
}

@end

@implementation UIControllerModeDetail

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
    
    _arrModeProgram = [NSMutableArray arrayWithArray:[ADOModeProgram queryWithModePkid:_modelMode.pkid]];
    
    // ----------------
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(onTouchBack) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [self.view addSubview:_viewNav];
    
    _viewSync = [UIViewSync viewFromXib];
    _viewSync.syncDataType = SyncDataTypeReminder;
    _viewSync.controllerRoot = self;
    
    __weak typeof(self) wSelf = self;
    _viewSync.callbackSyncBegin = ^{
        
    };
    _viewSync.callbackSyncCompletion = ^{
        // 同步后，更新列表
        [wSelf refreshModeProgram];
    };
    _viewSync.callbackSyncFail = ^{
        
    };
    [self.view addSubview:_viewSync];
    
    _tableView.rowHeight = 50;
    
    if (!_modelMode.sysRecommend) {
        UIButton *btnAddModeProgram = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _tableView.rowHeight)];
        [btnAddModeProgram setTitle:LocalizedString(@"xinzengyuyue") forState:UIControlStateNormal];
        [btnAddModeProgram setImage:[UIImage imageWithBundleFile:@"iPhone/FM/add_appointment_0.png"] forState:UIControlStateNormal];
        [btnAddModeProgram setImage:[UIImage imageWithBundleFile:@"iPhone/FM/add_appointment_1.png"] forState:UIControlStateHighlighted];
        [btnAddModeProgram setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/FM/bg_cell_program.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2]
                                     forState:UIControlStateNormal];
        [btnAddModeProgram setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/FM/bg_cell_select.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2]
                                     forState:UIControlStateHighlighted
         ];
        [btnAddModeProgram setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnAddModeProgram setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [btnAddModeProgram setContentEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        [btnAddModeProgram setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [btnAddModeProgram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btnAddModeProgram setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [btnAddModeProgram addTarget:self action:@selector(onTouchAddModeProgram:) forControlEvents:UIControlEventTouchUpInside];
        btnAddModeProgram.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tableView.tableHeaderView = btnAddModeProgram;
        
        UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnEdit setTitle:LocalizedString(@"bianji") forState:UIControlStateNormal];
        [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnEdit setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [btnEdit addTarget:self action:@selector(onTouchEdit) forControlEvents:UIControlEventTouchUpInside];
        [btnEdit sizeToFit];
        _viewNav.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
    }
    else {
        UIButton *btnRestore = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnRestore setTitle:LocalizedString(@"huifu") forState:UIControlStateNormal];
        [btnRestore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnRestore setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [btnRestore addTarget:self action:@selector(onTouchRestore) forControlEvents:UIControlEventTouchUpInside];
        [btnRestore sizeToFit];
        _viewNav.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRestore];
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
    [_viewSync resizeBottomSuperView];
    
    CGRect rc = CGRectMake(0, _viewNav.bottom, self.view.width, _viewSync.top-_viewNav.bottom);
    _tableView.frame = rc;
}

#pragma mark - private methods
- (void)onTouchBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onValueChanged:(UISwitch *)swt
{
    ModelModeProgram *modelModeProgram = _arrModeProgram[swt.tag];
    modelModeProgram.updateTime = [[NSDate date] timeIntervalSince1970];
    modelModeProgram.on = swt.on;
    if ([ADOModeProgram updateModel:modelModeProgram]) {
        if (_callbackDidUpdateMode) {
            _callbackDidUpdateMode(_modelMode.pkid);
        }
        
        if (_callbackGetCurrModePkid) {
            if (_modelMode.pkid==_callbackGetCurrModePkid()) {
                [FMLocalNotificationManager updateModeProgram:modelModeProgram enable:modelModeProgram.on];
            }
        }
        
        // TODO: 同步更新 模式-节目
        if (modelModeProgram.pkid_server>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeReminder]) {
            [[SyncHelper shareSync] syncUpdateArrModeProgram:@[modelModeProgram] completion:^{
                
            } fail:^(NSError *error) {
                
            }];
        }
    }
    else {
        swt.on = !swt.on;
        modelModeProgram.on = swt.on;
    }
}

/**
 *  添加一个 预约
 *
 *  @param btn
 */
- (void)onTouchAddModeProgram:(UIButton *)btn
{
    UIControllerAddProgram *controllerAddProgram = [UIControllerAddProgram controllerFromXib];
    controllerAddProgram.title = LocalizedString(@"xinzengyuyue");
    controllerAddProgram.actionType = ProgramActionTypeAddModeProgram;
    controllerAddProgram.modePkid = _modelMode.pkid;
    [controllerAddProgram setCallbackDidAddModeProgram:^(ModelModeProgram *modelModeProgram) {
        [_arrModeProgram removeAllObjects];
        [_arrModeProgram addObjectsFromArray:[ADOModeProgram queryWithModePkid:_modelMode.pkid]];
        
        [_tableView reloadData];
        
        if (_callbackDidUpdateMode) {
            _callbackDidUpdateMode(_modelMode.pkid);
        }
        
        if (_callbackGetCurrModePkid) {
            if (_modelMode.pkid==_callbackGetCurrModePkid()) {
                [FMLocalNotificationManager addNotificationWithModeProgram:modelModeProgram];
            }
        }
    }];
    [controllerAddProgram setCallbackWillRemoveLocalNotificationWithModeProgramPkid:^(NSInteger modeProgramPkid) {
        if (_callbackGetCurrModePkid) {
            if (_modelMode.pkid==_callbackGetCurrModePkid()) {
                [FMLocalNotificationManager removeNotificationWithModeProgramPkid:modeProgramPkid];
            }
        }
    }];
    
    [self.navigationController pushViewController:controllerAddProgram animated:YES];
}

- (void)onTouchEdit
{
    [_tableView setEditing:YES animated:YES];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:LocalizedString(@"wancheng") forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnDone addTarget:self action:@selector(onTouchDone) forControlEvents:UIControlEventTouchUpInside];
    [btnDone sizeToFit];
    _viewNav.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
}

- (void)onTouchDone
{
    [_tableView setEditing:NO animated:YES];
    
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEdit setTitle:LocalizedString(@"bianji") forState:UIControlStateNormal];
    [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnEdit setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnEdit addTarget:self action:@selector(onTouchEdit) forControlEvents:UIControlEventTouchUpInside];
    [btnEdit sizeToFit];
    _viewNav.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnEdit];
}

/**
 *  系统推荐模式 的 恢复 启用开关 操作
 */
- (void)onTouchRestore
{
    BOOL shouldUpdateNotification = NO;
    if (_callbackGetCurrModePkid) {
        if (_modelMode.pkid==_callbackGetCurrModePkid()) {
            shouldUpdateNotification = YES;
        }
    }
    for (ModelModeProgram *modeProgram in _arrModeProgram) {
        // 不用修改的项
        if (modeProgram.on)
            continue;
        
        if ([ADOModeProgram updateOn:YES withPkid:modeProgram.pkid]) {
            modeProgram.on = YES;
            if (shouldUpdateNotification) {
                /**
                 *  更新通知
                 */
                [FMLocalNotificationManager updateModeProgram:modeProgram enable:modeProgram.on];
            }
        }
    }
    
    [_tableView reloadData];
}

/**
 *  将 重复模式枚举值 转成 文字描述
 *
 *  @param repeatMode 重复模式
 *
 *  @return 重复模式文字描述
 */
- (NSString *)stringFromRepeatMode:(RemindRepeatMode)repeatMode
{
    if (RemindRepeatModeNone==repeatMode) {
        return LocalizedString(@"buchongfu");
    }
    else if (RemindRepeatModeWeekdays==repeatMode) {
        return LocalizedString(@"gongzuori");
    }
    else if (RemindRepeatModeWeekend==repeatMode) {
        return LocalizedString(@"zhoumo");
    }
    else if (RemindRepeatModeEveryDay==repeatMode) {
        return LocalizedString(@"meitian");
    }
    
    NSMutableString *str = [NSMutableString stringWithString:@""];
    NSArray *arrRepeat = @[@{@"title":@"zhou1",
                             @"repeat":@(RemindRepeatMode1)},
                           @{@"title":@"zhou2",
                             @"repeat":@(RemindRepeatMode2)},
                           @{@"title":@"zhou3",
                             @"repeat":@(RemindRepeatMode3)},
                           @{@"title":@"zhou4",
                             @"repeat":@(RemindRepeatMode4)},
                           @{@"title":@"zhou5",
                             @"repeat":@(RemindRepeatMode5)},
                           @{@"title":@"zhou6",
                             @"repeat":@(RemindRepeatMode6)},
                           @{@"title":@"zhou0",
                             @"repeat":@(RemindRepeatMode0)}
                           ];

    for (NSInteger i=0; i<arrRepeat.count; i++) {
        NSDictionary *dict = arrRepeat[i];
        RemindRepeatMode repeat = [dict[@"repeat"] integerValue];
        if (repeat&repeatMode) {
            NSString *title = LocalizedString(dict[@"title"]);
            
            [str appendString:title];
            [str appendString:@"、"];
        }
    }
    
    if (str.length>1) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    
    return str;
}

- (void)refreshModeProgram
{
    [_arrModeProgram removeAllObjects];
    [_arrModeProgram addObjectsFromArray:[ADOModeProgram queryWithModePkid:_modelMode.pkid]];
    [_tableView reloadData];
}

#pragma mark - UITableViewDatasource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrModeProgram.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"UICellModeProgram";
    UICellModeProgram *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [UICellModeProgram cellFromXib];
        
        UISwitch *swt = [[UISwitch alloc] init];
        [swt addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        cell.accessoryView = swt;
    }
    
    cell.accessoryView.tag = indexPath.row;
    
    ModelModeProgram *modelModeProgram = _arrModeProgram[indexPath.row];
    cell.labelTime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)modelModeProgram.time/3600, (long)modelModeProgram.time%3600/60];
    cell.labelTitle.text = modelModeProgram.modelProgram.title;
    cell.labelRepeat.text = [self stringFromRepeatMode:modelModeProgram.repeatMode];
    
    [(UISwitch *)cell.accessoryView setOn:modelModeProgram.on];
    
    return cell;
}

/**
 *  进入自定义预约 的编辑模式
 *
 *  @param tableView tableView description
 *  @param indexPath indexPath description
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_modelMode.sysRecommend) {
        return;
    }
    
    ModelModeProgram *modelModeProgram = _arrModeProgram[indexPath.row];
    
    UIControllerAddProgram *controllerAddProgram = [UIControllerAddProgram controllerFromXib];
    controllerAddProgram.title = LocalizedString(@"bianjiyuyue");
    controllerAddProgram.actionType = ProgramActionTypeEditModeProgram;
    [controllerAddProgram setEditModelModeProgram:modelModeProgram];
    controllerAddProgram.modePkid = _modelMode.pkid;
    [controllerAddProgram setCallbackDidEditModeProgram:^(ModelModeProgram *modelModeProgram) {
        [_arrModeProgram removeAllObjects];
        [_arrModeProgram addObjectsFromArray:[ADOModeProgram queryWithModePkid:_modelMode.pkid]];
        
        [_tableView reloadData];
        
        if (_callbackDidUpdateMode) {
            _callbackDidUpdateMode(_modelMode.pkid);
        }
        
        if (_callbackGetCurrModePkid) {
            if (_modelMode.pkid==_callbackGetCurrModePkid()) {
                [FMLocalNotificationManager addNotificationWithModeProgram:modelModeProgram];
            }
        }
    }];
    [controllerAddProgram setCallbackWillRemoveLocalNotificationWithModeProgramPkid:^(NSInteger modeProgramPkid) {
        if (_callbackGetCurrModePkid) {
            if (_modelMode.pkid==_callbackGetCurrModePkid()) {
                [FMLocalNotificationManager removeNotificationWithModeProgramPkid:modeProgramPkid];
            }
        }
    }];
    
    [self.navigationController pushViewController:controllerAddProgram animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !_modelMode.sysRecommend;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _DEBUG_LOG(@"%s", __FUNCTION__);
    ModelModeProgram *modelModeProgram = _arrModeProgram[indexPath.row];
    if ([ADOModeProgram deleteWithPkid:modelModeProgram.pkid]) {
        [_arrModeProgram removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        // 需要更新 UISwitch 的 tag 值
        NSArray *arrVisibleIndexPath = [_tableView indexPathsForVisibleRows];
        [arrVisibleIndexPath enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            UICellModeProgram *cell = (UICellModeProgram *)[_tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryView.tag = indexPath.row;
        }];
        
        if (_callbackDidUpdateMode) {
            _callbackDidUpdateMode(_modelMode.pkid);
        }
        
        if (_callbackGetCurrModePkid) {
            if (_modelMode.pkid==_callbackGetCurrModePkid()) {
                [FMLocalNotificationManager removeNotificationWithModeProgramPkid:modelModeProgram.pkid];
            }
        }
        
        // TODO: 同步删除
        if (modelModeProgram.pkid_server>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeReminder]) {
            ModelSyncDelete *modelSyncDelete = [ModelSyncDelete modelWithPkidServer:modelModeProgram.pkid_server syncDataType:SyncDataTypeModeProgram userId:[UserManager shareUserManager].currUser.uid];
            modelSyncDelete.pkid = [ADOSyncDelete addModel:modelSyncDelete];
            if (modelSyncDelete.pkid>0) {
                [[SyncHelper shareSync] syncDeleteModeWithArrSyncDelete:@[modelSyncDelete] completion:^{
                    
                } fail:^(NSError *error) {
                    
                }];
            }
        }
    }
}

@end