//
//  UIControllerImageAssets.m
//  ChinaBrowser
//
//  Created by HHY on 14/12/6.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerImageAssets.h"

#define kBtnWH 70
#define kMinSpacing 8

@interface UIControllerImageAssets ()
{
    NSInteger _count;
    //所有图片信息
    NSMutableArray *_arrAssets;
    ALAssetsLibrary *_assetsLibrary;
    //所有图片按钮
    NSMutableArray *_arrBtn;
    //底部提示图片张数
    UILabel *_label;
}
@end

@implementation UIControllerImageAssets

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrBtn = [[NSMutableArray alloc]init];
    
    _viewNav = [UIViewNav viewNav];
    [self.view addSubview:_viewNav];
    //导航栏设置
    UIButton *btnBack =[UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(onTouchBtnback) forControlEvents:UIControlEventTouchUpInside];
    [btnBack sizeToFit];
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
    
    [self setupAssets];
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
    
    //每行最多图片数
    NSInteger maxRow = (_scrollView.width - kMinSpacing)/(kBtnWH + kMinSpacing);
    //图片间的间隔
    float spacing = (_scrollView.width - maxRow*kBtnWH)/(maxRow + 1);
    for (int i = 0; i<_arrBtn.count; i++) {
        UIButton *btn = _arrBtn[i];
        btn.frame = CGRectMake((i%maxRow+1)*spacing+i%maxRow*kBtnWH, (i/maxRow+1)*spacing+i/maxRow*kBtnWH, kBtnWH, kBtnWH);
        
        if (i == _arrBtn.count-1) {
            _label.center = CGPointMake(_scrollView.center.x, btn.bottom+30);
            _scrollView.contentSize = CGSizeMake(self.view.width, _label.bottom+20);
            _scrollView.contentOffset = CGPointMake(0,
                                                    (_scrollView.contentSize.height - _scrollView.frame.size.height)>0?(_scrollView.contentSize.height - _scrollView.frame.size.height):0);
        }
    }
    
    
}

/**
 *  返回按钮
 */
- (void)onTouchBtnback
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [super dismissModalViewControllerAnimated:animated];
     _DEBUG_LOG(@"%s,销毁",__FUNCTION__);
}

/**
 *  获得相册里的相片资源
 */
- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    _viewNav.title = self.title;
    
    if (!_arrAssets)
        _arrAssets = [[NSMutableArray alloc] init];
    else
        [_arrAssets removeAllObjects];
    
    //枚举相片成功调用的block
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset)
        {
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            //资源类型为图片才加到数据源中
            if ([type isEqual:ALAssetTypePhoto])
                [_arrAssets addObject:asset];
            
        }
        //asset为空,  说明相片以及枚举完.  并且 已经得到大于一张相片
        else if (!asset && _arrAssets.count > 0)
        {

            //把相片显示到btn上
            for (int i=0; i<_arrAssets.count; i++) {
                ALAsset *result = _arrAssets[i];
                
                UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = i;
                //result.thumbnail  获得正方形的缩略图
                [btn setImage:[UIImage imageWithCGImage:result.thumbnail] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onTouchAssetsImage:) forControlEvents:UIControlEventTouchUpInside];
                
                [_arrBtn addObject:btn];
                [_scrollView addSubview:btn];
                
                if(i==_arrAssets.count-1)
                {
                    UILabel *label  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
                    label.font      = [UIFont systemFontOfSize:18.0];
                    label.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
                    label.textAlignment     = NSTextAlignmentCenter;
                    label.text      = [NSString stringWithFormat:@"%ld %@",(long)[self.assetsGroup numberOfAssets],LocalizedString(@"zhangtupian")];
                    _label = label;
                    
                    [_scrollView addSubview:label];
                }
            }
        }
        else
        {
            //没有相片的情况
            [self showNoAssets];
        }
    };
    
    //开始枚举相册里的照片
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

/**
 *  点击图片action
 *
 *  @param sender
 */
-(void)onTouchAssetsImage:(UIButton *)sender
{
    ALAsset *asset = _arrAssets[sender.tag];
    if ([self.delegate respondsToSelector:@selector(controller:didFinishPickingAssets:)])
    [self.delegate controller:self didFinishPickingAssets:asset];
}


/**
 *  没有照片时显示
 */
- (void)showNoAssets
{
    UIView *noAssetsView    = [[UIView alloc] initWithFrame:self.view.bounds];
    
    CGRect rect             = CGRectInset(self.view.bounds, 10, 10);
    UILabel *title          = [[UILabel alloc] initWithFrame:rect];
    
    title.text              = LocalizedString(@"meiyoutupian");
//    NSLocalizedString(@"No Photos or Videos", nil);
    title.font              = [UIFont systemFontOfSize:26.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    
    [title sizeToFit];
    
    title.center            = CGPointMake(noAssetsView.center.x, noAssetsView.center.y - 150 - title.frame.size.height / 2);
    
    [noAssetsView addSubview:title];
    
    noAssetsView.autoresizingMask  =
    title.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin|
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;
    
    [_scrollView addSubview:noAssetsView];
//    self.tableView.tableHeaderView  = noAssetsView;
//    self.tableView.scrollEnabled    = NO;
}


@end
