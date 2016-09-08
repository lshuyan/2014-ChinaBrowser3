//
//  UITableViewMode.m
//  ChinaBrowser
//
//  Created by David on 14/11/18.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UITableViewMode.h"

#import "UIViewFMPlayer.h"

#import "UICellFMMode.h"
#import "BlockUI.h"

#import "ModelMode.h"
#import "ModelModeProgram.h"
#import "ModelProgram.h"
#import "ModelUser.h"
#import "ModelFMHistory.h"
#import "ModelUserSettings.h"
#import "ModelSyncDelete.h"

#import "ADOMode.h"
#import "ADOModeProgram.h"
#import "ADOProgram.h"
#import "ADOFMHistory.h"
#import "ADOSyncDelete.h"

#import "CBAudioPlayer.h"
#import "ModelPlayItem.h"

#import "FMLocalNotificationManager.h"

@interface UITableViewMode () <UITableViewDataSource, UITableViewDelegate>
{
    UIViewFMPlayer *_viewFMPlayer;
    
    NSMutableArray *_arrMode;
    NSInteger _currIndex;
    NSInteger _iDefaultCount;
    
    AFJSONRequestOperation *_afReqDefaultMode;
    AFJSONRequestOperation *_afReqProgram;
    
    ModelMode *_modeEditing;
}

@end

@implementation UITableViewMode

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _arrMode = [NSMutableArray array];
    
    self.dataSource = self;
    self.delegate = self;
    
    CGRect rc = self.bounds;
    _viewFMPlayer = [UIViewFMPlayer viewFromXib];
    rc.size.height = _viewFMPlayer.height;
    _viewFMPlayer.frame = rc;
    _viewFMPlayer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
    self.tableHeaderView = _viewFMPlayer;
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) wSelf = self;
    [_viewFMPlayer setCallbackWillAdd:^{
        if ([wSelf.delegateMode respondsToSelector:@selector(tableViewModeWillAdd:)]) {
            [wSelf.delegateMode tableViewModeWillAdd:wSelf];
        }
    }];
    
    _currIndex = -1;
    
    [self reqProgramList:^{
        [self reqDefaultMode];
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrMode.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UICellFMMode *cell = (UICellFMMode *)[tableView dequeueReusableCellWithIdentifier:@"UICellFMMode"];
    if (!cell) {
        cell = [UICellFMMode cellFromXib];
        [cell.btnRadio addTarget:self action:@selector(onTouchRadio:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        [cell addGestureRecognizer:longPressGesture];
    }
    
    ModelMode *mode = _arrMode[indexPath.row];
    
    cell.btnRadio.tag = indexPath.row;
    cell.tag = indexPath.row;
    cell.labelTitle.text = mode.name;
    
    [cell updateBtnRadioImageWithSelect:indexPath.row==_currIndex];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ModelMode *mode = _arrMode[indexPath.row];
    
    [_delegateMode tableViewMode:self showDetailMode:mode];
}

#pragma mark - private methods
- (void)onTouchRadio:(UIButton *)btnRadio
{
    if (btnRadio.selected) {
        return;
    }
    [self setSelectModeIndex:btnRadio.tag shouldUpdateDb:YES];
}

- (void)setSelectModeIndex:(NSInteger)index shouldUpdateDb:(BOOL)updateDb
{
    [(UICellFMMode *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currIndex inSection:0]] updateBtnRadioImageWithSelect:NO];
    _currIndex = index;
    [(UICellFMMode *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currIndex inSection:0]] updateBtnRadioImageWithSelect:YES];
    
    ModelMode *modelMode = _arrMode[_currIndex];
    [_viewFMPlayer setModePkid:modelMode.pkid];
    
    if (updateDb) {
        // 查找当前用户的 播放记录
        ModelFMHistory *fmHistory = [ADOFMHistory queryWithUserId:[UserManager shareUserManager].currUser.uid];
        if (!fmHistory) {
            fmHistory = [ModelFMHistory model];
            fmHistory.userid = [UserManager shareUserManager].currUser.uid;
            fmHistory.modePkid = modelMode.pkid;
            fmHistory.modeProgramPkid = 0;
            [ADOFMHistory addModel:fmHistory];
        }
        else {
            [ADOFMHistory updateModePkid:modelMode.pkid withUserId:[UserManager shareUserManager].currUser.uid];
        }
        
        /**
         *  更新 FM本地通知
         */
        [FMLocalNotificationManager resetNotificationWithModePkid:modelMode.pkid];
    }
    else {
        if ([FMLocalNotificationManager numberOfLocalNotification]==0) {
            /**
             *  更新 FM本地通知
             */
            [FMLocalNotificationManager resetNotificationWithModePkid:modelMode.pkid];
        }
    }
}

/**
 *  长按手势响应事件
 *
 *  @param longPressGesture longPressGesture description
 */
- (void)longPressGesture:(UILongPressGestureRecognizer *)longPressGesture
{
    if (UIGestureRecognizerStateBegan!=longPressGesture.state) {
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForCell:(UICellFMMode *)longPressGesture.view];
    
    NSInteger index = indexPath.row;
    ModelMode *mode = _arrMode[index];
    if (mode.sysRecommend) {
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:LocalizedString(@"quxiao") destructiveButtonTitle:LocalizedString(@"shanchu") otherButtonTitles:LocalizedString(@"chongmingming"), nil];
    [actionSheet showInView:self.window.rootViewController.view withCompletionHandler:^(NSInteger buttonIndex) {
        if (buttonIndex==actionSheet.cancelButtonIndex) {
            return;
        }
        
        if (0==buttonIndex) {
            // 删除
            if ([ADOMode deleteWithPkid:mode.pkid]) {
                ModelMode *modeDel = _arrMode[index];
                
                if (modeDel.pkid_server>0) {
                    ModelSyncDelete *modelSyncDelete = [ModelSyncDelete modelWithPkidServer:modeDel.pkid_server syncDataType:SyncDataTypeMode userId:[UserManager shareUserManager].currUser.uid];
                    modelSyncDelete.pkid = [ADOSyncDelete addModel:modelSyncDelete];
                    if (modelSyncDelete.pkid>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeMode]) {
                        [[SyncHelper shareSync] syncDeleteModeWithArrSyncDelete:@[modeDel] completion:^{
                            
                        } fail:^(NSError *error) {
                            
                        }];
                    }
                }
                
                /**
                 *  删除
                 */
                [ADOModeProgram deleteWithModePkid:mode.pkid];
                
                [_arrMode removeObjectAtIndex:index];
                [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                if (_arrMode.count==0) {
                    return;
                }
                
                /**
                 *  更新 cell.btnRadio.tag
                 */
                NSArray *arrVisibleIndexPath = [self indexPathsForVisibleRows];
                [arrVisibleIndexPath enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                    UICellFMMode *cell = (UICellFMMode *)[self cellForRowAtIndexPath:indexPath];
                    cell.btnRadio.tag = indexPath.row;
                    if (0==indexPath.row) {
                        [cell updateBtnRadioImageWithSelect:YES];
                    }
                }];
                
                if (modeDel.pkid==_viewFMPlayer.modePkid) {
                    // 设置新的模式
                    [self setSelectModeIndex:0 shouldUpdateDb:YES];
                }
            }
        }
        else if (1==buttonIndex) {
            // 重命名
            _modeEditing = mode;
            [_delegateMode tableViewMode:self willRenameName:_modeEditing.name];
        }
    }];
}

- (void)reqDefaultMode
{
    [_afReqDefaultMode cancel];
    _afReqDefaultMode = nil;
    
    BOOL (^resolve)(NSDictionary *) = ^(NSDictionary *dicResult) {
        [_arrMode removeAllObjects];
        _iDefaultCount = 0;
        
        BOOL retVal = NO;
        do {
            if (![dicResult isKindOfClass:[NSDictionary class]]) break;
            NSArray *arrModeDict = dicResult[@"data"];
            if (![arrModeDict isKindOfClass:[NSArray class]]||arrModeDict.count<=0) break;
            
            for (NSDictionary *dictMode in arrModeDict) {
                ModelMode *mode = [ModelMode modelWithDict:dictMode];
                mode.lan = [LocalizationUtil currLanguage];
                mode.updateTime = [[NSDate date] timeIntervalSince1970];
                mode.updateTimeServer = mode.updateTime;
                NSMutableArray *arrModeProgram = nil;
                NSArray *arrDictModeProgram = dictMode[@"item"];
                if ([arrDictModeProgram isKindOfClass:[NSArray class]]) {
                    arrModeProgram = [NSMutableArray arrayWithCapacity:arrDictModeProgram.count];
                    for (NSDictionary *dictModeProgram in arrDictModeProgram) {
                        ModelModeProgram *modeProgram = [ModelModeProgram modelWithDict:dictModeProgram];
                        [arrModeProgram addObject:modeProgram];
                    }
                }
                
                ModelMode *modeLocal = [ADOMode queryWithPkidServer:mode.pkid_server];
                NSInteger modePkid = modeLocal.pkid;
                NSInteger modePkidServer = modeLocal.pkid_server;
                if (modeLocal) {
                    // 如果本地存在则
                    if (modeLocal.updateTime<mode.updateTimeServer) {
                        mode.pkid = modeLocal.pkid;
                        [ADOMode updateModel:mode];
                    }
                    [_arrMode addObject:modeLocal];
                }
                else {
                    mode.pkid = [ADOMode addModel:mode];
                    if (mode.pkid>0) {
                        modePkid = mode.pkid;
                        modePkidServer = mode.pkid_server;
                        [_arrMode addObject:mode];
                    }
                }
                
                if (modePkid>0) {
                    for (ModelModeProgram *modeProgram in arrModeProgram) {
                        modeProgram.modePkid = modePkid;
                        modeProgram.modePkidServer = modePkidServer;
                        ModelModeProgram *modeProgramLocal = [ADOModeProgram queryWithModePkid:modeProgram.modePkid time:modeProgram.time];
                        if (modeProgramLocal) {
                            modeProgram.pkid = modeProgramLocal.pkid;
                            [ADOModeProgram updateModel:modeProgram];
                        }
                        else {
                            modeProgram.pkid = [ADOModeProgram addModel:modeProgram];
                        }
                    }
                }
            }
            
            _iDefaultCount = _arrMode.count;
            
            retVal  = YES;
        } while (NO);
        return retVal;
    };
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_ModeProgramRecommend) parameters:nil];
    NSString *filepath = [GetCacheDataDir()  stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    _afReqDefaultMode = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (resolve(JSON)) {
            [_afReqDefaultMode.responseData writeToFile:filepath atomically:YES];
        }
        
        [self loadCustomMode];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            resolve([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
        }
        else {
            resolve(nil);
        }
        
        [self loadCustomMode];
    }];
    [_afReqDefaultMode start];
}

- (void)reqProgramList:(void(^)())completion
{
    [_afReqProgram cancel];
    _afReqProgram = nil;
    
    BOOL (^resolve)(NSDictionary *) = ^(NSDictionary *dicResult) {
        BOOL retVal = NO;
        do {
            if (![dicResult isKindOfClass:[NSDictionary class]]) break;
            NSArray *arrDicCate = dicResult[@"data"];
            if (![arrDicCate isKindOfClass:[NSArray class]]||arrDicCate.count<=0) break;
            
            for (NSInteger i=0; i<arrDicCate.count; i++) {
                NSDictionary *dicCate = arrDicCate[i];
                NSArray *arrProgramDict = dicCate[@"list"];
                for (NSInteger j=0; j<arrProgramDict.count; j++) {
                    NSDictionary *dicProgram = arrProgramDict[j];
                    ModelProgram *model = [ModelProgram modelWithDict:dicProgram];
                    if (0==i) {
                        if (model.arrSubProgram.count>0) {
                            ModelProgram *modelLocal = [ADOProgram queryWithPkidServer:model.pkid_server];
                            if (modelLocal) {
                                // 如果存在，是否需要修改数据
                                [ADOProgram updateParentPkidServer:model.parent_pkid_server withPkidServer:model.pkid_server];
                                // 检查子项数据是否有增加
                                for (ModelProgram *subProgram in model.arrSubProgram) {
                                    modelLocal = [ADOProgram queryWithPkidServer:subProgram.pkid_server];
                                    if (modelLocal) {
                                        [ADOProgram updateParentPkidServer:subProgram.parent_pkid_server withPkidServer:subProgram.pkid_server];
                                    }
                                    else {
                                        NSInteger subPkid = [ADOProgram addModel:subProgram];
                                        if (subPkid>0) {
                                            subProgram.pkid = subPkid;
                                        }
                                    }
                                }
                            }
                            else {
                                NSInteger pkid = [ADOProgram addModel:model];
                                if (pkid>0) {
                                    model.pkid = pkid;
                                    // 检查子项数据是否有增加
                                    for (ModelProgram *subProgram in model.arrSubProgram) {
                                        modelLocal = [ADOProgram queryWithPkidServer:subProgram.pkid_server];
                                        if (modelLocal) {
                                            [ADOProgram updateParentPkidServer:subProgram.parent_pkid_server withPkidServer:subProgram.pkid_server];
                                        }
                                        else {
                                            NSInteger subPkid = [ADOProgram addModel:subProgram];
                                            if (subPkid>0) {
                                                subProgram.pkid = subPkid;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        ModelProgram *modelLocal = [ADOProgram queryWithPkidServer:model.pkid_server];
                        if (modelLocal) {
                            // 如果存在，是否需要修改数据
                            [ADOProgram updateParentPkidServer:model.parent_pkid_server withPkidServer:model.pkid_server];
                            // 检查子项数据是否有增加
                            for (ModelProgram *subProgram in model.arrSubProgram) {
                                modelLocal = [ADOProgram queryWithPkidServer:subProgram.pkid_server];
                                if (modelLocal) {
                                    [ADOProgram updateParentPkidServer:subProgram.parent_pkid_server withPkidServer:subProgram.pkid_server];
                                }
                                else {
                                    NSInteger subPkid = [ADOProgram addModel:subProgram];
                                    if (subPkid>0) {
                                        subProgram.pkid = subPkid;
                                    }
                                }
                            }
                        }
                        else {
                            [ADOProgram addModel:model];
                        }
                    }
                }
            }
            
            retVal  = YES;
        } while (NO);
        return retVal;
    };
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_ProgramList) parameters:nil];
    NSString *filepath = [GetCacheDataDir()  stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    _afReqProgram = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (resolve(JSON)) {
            [_afReqProgram.responseData writeToFile:filepath atomically:YES];
        }
        
        if (completion) completion();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            resolve([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
        }
        else {
            resolve(nil);
        }
        if (completion) completion();
    }];
    [_afReqProgram start];
}

- (void)loadCustomMode
{
    NSArray *arrModeCustom = [ADOMode queryWithUserId:[UserManager shareUserManager].currUser.uid sysRecommend:NO];
    [_arrMode addObjectsFromArray:arrModeCustom];
    [self reloadData];
    
    if (_arrMode.count<=0) {
        [FMLocalNotificationManager clearNotification];
        return;
    }
    
    // 设置上次用户的选项
    ModelFMHistory *fmHistory = [ADOFMHistory queryWithUserId:[UserManager shareUserManager].currUser.uid];
    if (fmHistory) {
        NSInteger modeIndex = -1;
        for (NSInteger i=0; i<_arrMode.count; i++) {
            ModelMode *mode = _arrMode[i];
            if (mode.pkid==fmHistory.modePkid) {
                modeIndex = i;
                break;
            }
        }
        if (modeIndex>=0) {
            [self setSelectModeIndex:modeIndex shouldUpdateDb:NO];
        }
        else {
            [self setSelectModeIndex:0 shouldUpdateDb:YES];
        }
    }
    else {
        [self setSelectModeIndex:0 shouldUpdateDb:YES];
    }
}

#pragma mark - public method
- (NSInteger)currModePkid
{
    return _viewFMPlayer.modePkid;
}

/**
 *  添加模式
 *
 *  @param model ModelMode
 */
- (void)addMode:(ModelMode *)model
{
    [_arrMode addObject:model];
    [self reloadData];
}

/**
 *  重命名正在编辑的模型
 *
 *  @param name 新名字
 */
- (void)setEditingModeName:(NSString *)name
{
    _modeEditing.updateTime = [[NSDate date] timeIntervalSince1970];
    _modeEditing.name = name;
    if ([ADOMode updateModel:_modeEditing]) {
        if (_modeEditing.pkid_server>0 && [SyncHelper shouldAutoSync] && [SyncHelper shouldSyncWithType:SyncDataTypeMode]) {
            [[SyncHelper shareSync] syncUpdateArrMode:@[_modeEditing] completion:^{
                
            } fail:^(NSError *error) {
                
            }];
        }
        _modeEditing.name = name;
        [self reloadData];
    }
    
    _modeEditing = nil;
}

/**
 *  即将更新节目列表
 *
 *  @param modePkid
 */
- (void)updatePListIfNeedWithModePkid:(NSInteger)modePkid
{
    [_viewFMPlayer updatePListIfNeedWithModePkid:modePkid];
}

- (void)reloadCustomMode
{
    NSRange rangOfCustom = NSMakeRange(_iDefaultCount, _arrMode.count-_iDefaultCount);
    [_arrMode removeObjectsInRange:rangOfCustom];
    
    [self loadCustomMode];
}

#pragma mark - AppLanguageProtocol
- (void)updateByLanguage
{
    [FMLocalNotificationManager clearNotification];
    
    [_viewFMPlayer updateByLanguage];
    
    [_arrMode removeAllObjects];
    [self reloadData];
    
    [self reqProgramList:^{
        [self reqDefaultMode];
    }];
    
}

@end