//
//  UIViewRecommendSubCate.m
//  ChinaBrowser
//
//  Created by David on 14/11/5.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIViewRecommendSubCate.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UIViewSectionHeader.h"
#import "MJRefreshHeaderView.h"
#import "UICellRecommend.h"

#import "ModelRecommend.h"
#import "ModelPlayItem.h"

#import "CBAudioPlayer.h"

@interface UIViewRecommendSubCate () <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *_tableView;
    MJRefreshHeaderView *_refreshView;
    
    NSMutableArray *_arrRecommendFM;
    NSMutableArray *_arrRecommendWeb;
    AFJSONRequestOperation *_afReqRecommend;
    
    UIViewSectionHeader *_viewSectionHeaderFM;
    UIViewSectionHeader *_viewSectionHeaderWeb;
    
    NSIndexPath *_indexPathPlay;
}

@end

@implementation UIViewRecommendSubCate

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (instancetype)viewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:@"UIViewRecommendSubCate" owner:nil options:nil][0];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _arrRecommendFM = [NSMutableArray array];
    _arrRecommendWeb = [NSMutableArray array];
    
    _viewSectionHeaderFM = [[UIViewSectionHeader alloc] initWithFrame:CGRectZero];
    _viewSectionHeaderFM.labelTitle.text = LocalizedString(@"FM");
    _viewSectionHeaderFM.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    
    _viewSectionHeaderWeb = [[UIViewSectionHeader alloc] initWithFrame:CGRectZero];
    _viewSectionHeaderWeb.labelTitle.text = LocalizedString(@"Web");
    _viewSectionHeaderWeb.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    [_viewSectionHeaderWeb.labelTitle removeFromSuperview];
    
    _refreshView = [MJRefreshHeaderView header];
    _refreshView.scrollView = _tableView;
    
    __weak UIViewRecommendSubCate* wSelf = self;
    _refreshView.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        [wSelf reqRecommend];
    };
}

- (void)dealloc
{
    _refreshView.beginRefreshingBlock = nil;
    _refreshView.scrollView = nil;
    [_afReqRecommend cancel];
    _afReqRecommend = nil;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0?_arrRecommendFM.count:_arrRecommendWeb.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"UICellRecommend";
    UICellRecommend *cell = (UICellRecommend *)[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [UICellRecommend viewFromXib];
        cell.imageViewIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    ModelRecommend *model = indexPath.section==0?_arrRecommendFM[indexPath.row]:_arrRecommendWeb[indexPath.row];
    
    [cell.imageViewIcon setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"no_pic.png"]];
    cell.labelTitle.text = model.name;
    cell.btnPlay.hidden = model.type!=RecommendTypeLiveStream;
    
    if (RecommendTypeLiveStream==model.type) {
        if ([[cell.btnPlay actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count]<=0) {
            [cell.btnPlay addTarget:self action:@selector(onTouchBtnPlay:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.btnPlay.tag = indexPath.row;
        
        if ([[CBAudioPlayer player].playItem.link isEqualToString:model.link]) {
            _indexPathPlay = indexPath;
            cell.playing = [CBAudioPlayer isPlaying];
        }
        else {
            cell.playing = NO;
        }
        
        /*
        if (_indexPathPlay && indexPath.section==_indexPathPlay.section && indexPath.row==_indexPathPlay.row) {
            cell.playing = YES;
        }
        else {
            cell.playing = NO;
        }
         */
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return section==0?nil:_viewSectionHeaderWeb;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0?0:(_arrRecommendFM.count+_arrRecommendWeb.count)>0?1:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row%2)?[UIColor colorWithWhite:0.95 alpha:1]:[UIColor clearColor];
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0!=indexPath.section) {
        /*
        if (_indexPathPlay) {
            [CBAudioPlayer stop];
            
            UICellRecommend *cell = (UICellRecommend *)[_tableView cellForRowAtIndexPath:_indexPathPlay];
            cell.playing = NO;
            _indexPathPlay = nil;
        }
         */
        
        ModelRecommend *model = _arrRecommendWeb[indexPath.row];
        [_delegate viewRecommendSubCate:self reqLink:model.link];
    }
    else {
        [self playOrPauseAtIndexPath:indexPath];
    }
}

#pragma mark - private methods
- (void)reqRecommend
{
    [_afReqRecommend cancel];
    _afReqRecommend = nil;
    
    BOOL (^resolveNews)(NSDictionary *)=^(NSDictionary *dicResult){
        [_arrRecommendFM removeAllObjects];
        [_arrRecommendWeb removeAllObjects];
        
        BOOL ret = NO;
        do {
            if (![dicResult isKindOfClass:[NSDictionary class]]) break;
            NSArray *arrDicNews = dicResult[@"data"];
            if (![arrDicNews isKindOfClass:[NSArray class]]) break;
            for (NSDictionary *dicNews in arrDicNews) {
                ModelRecommend *model = [ModelRecommend modelWithDict:dicNews];
                if (RecommendTypeLiveStream==model.type) {
                    [_arrRecommendFM addObject:model];
                }
                else if (RecommendTypeLink==model.type) {
                    [_arrRecommendWeb addObject:model];
                }
            }
            
            ret = (_arrRecommendFM.count+_arrRecommendWeb.count)>0;
            
        } while (NO);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_refreshView endRefreshing];
            [_tableView reloadData];
        });
        
        return ret;
    };
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSDictionary *dicParam = @{@"device":IsiPad?@"ipad":@"iphone",
                               @"catid":@(_cateId)};
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_RecommendSubCate) parameters:dicParam];
    NSString *filepath = [GetCacheDataDir() stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    _afReqRecommend = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (resolveNews(JSON)) {
            [_afReqRecommend.responseData writeToFile:filepath atomically:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            resolveNews([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
        }
        else {
            resolveNews(nil);
        }
    }];
    
    [_afReqRecommend start];
}

- (void)onTouchBtnPlay:(UIButton *)btnPlay
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btnPlay.tag inSection:0];
    [self playOrPauseAtIndexPath:indexPath];
}

- (void)playOrPauseAtIndexPath:(NSIndexPath *)indexPath
{
    ModelRecommend *model = _arrRecommendFM[indexPath.row];
    
    if (_indexPathPlay) {
        if (_indexPathPlay.row==indexPath.row) {
            UICellRecommend *cell = (UICellRecommend *)[_tableView cellForRowAtIndexPath:indexPath];
            
            // 点击同一个，播放/暂停
            if ([CBAudioPlayer player].playbackState==MPMoviePlaybackStatePlaying) {
                [CBAudioPlayer pause];
                cell.playing = NO;
            }
            else {
                [CBAudioPlayer play];
                cell.playing = YES;
            }
        }
        else {
            // TODO: 播放新的
            [CBAudioPlayer playWithItem:[ModelPlayItem modelWithTitle:model.name link:model.link fm:nil icon:model.icon]];
            
            UICellRecommend *cell = (UICellRecommend *)[_tableView cellForRowAtIndexPath:_indexPathPlay];
            cell.playing = NO;
            
            cell = (UICellRecommend *)[_tableView cellForRowAtIndexPath:indexPath];
            cell.playing = YES;
        }
    }
    else {
        // TODO: 播放新的
        [CBAudioPlayer playWithItem:[ModelPlayItem modelWithTitle:model.name link:model.link fm:nil icon:model.icon]];
        
        UICellRecommend *cell = (UICellRecommend *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.playing = YES;
    }
    _indexPathPlay = indexPath;
}

#pragma mark - public methods
- (void)refreshData
{
    [_refreshView beginRefreshing];
}

@end
