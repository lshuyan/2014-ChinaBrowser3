//
//  UIControllerDrawView.m
//  DrawView
//
//  Created by HHY on 14-10-22.
//  Copyright (c) 2014年 koto. All rights reserved.
//

#import "UIControllerDrawView.h"
#import "UIViewBrushSet.h"
#import "UIImage+Ex.h"
#import "UIViewEraserSet.h"
#import "UIViewPopShareOption.h"

@interface UIControllerDrawView ()<UIViewBrushSetDelegate,UIViewEraserSetDelegate>
{
    NSMutableArray *_arrAllControlItem;
    
    BOOL _rotateLockOriginal;
}
@end

@implementation UIControllerDrawView

+ (UIControllerDrawView *)UIControllerDrawViewFromXib
{
    return [[UIControllerDrawView alloc]initWithNibName:@"UIControllerDrawView" bundle:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [RotateUtil shareRotateUtil].shouldShowRotateLock = NO;
    _rotateLockOriginal = [RotateUtil shareRotateUtil].rotateLock;
    [RotateUtil shareRotateUtil].rotateLock = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [RotateUtil shareRotateUtil].shouldShowRotateLock = YES;
    [RotateUtil shareRotateUtil].rotateLock = _rotateLockOriginal;
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    _controlItemback.labelTitle.text = LocalizedString(@"fanhui");
    _controlItemBrush.labelTitle.text = LocalizedString(@"huabi");
    _controlItemEraser.labelTitle.text = LocalizedString(@"xiangpi");
    _controlItemRedo.labelTitle.text = LocalizedString(@"qingchu");
    _controlItemShare.labelTitle.text = LocalizedString(@"baocun_fenxiang");

    [_controlItemback setImageNormal:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/back_0.png"] highlighted:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/back_1.png"] selected:nil];
    [_controlItemBrush setImageNormal:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/paint_0.png"] highlighted:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/paint_1.png"] selected:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/paint_2.png"]];
    [_controlItemEraser setImageNormal:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/rubbe_0.png"] highlighted:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/rubbe_1.png"] selected:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/rubbe_2.png"]];
    [_controlItemRedo setImageNormal:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/delete_0.png"] highlighted:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/delete_1.png"] selected:nil];
    [_controlItemShare setImageNormal:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/save_0.png"] highlighted:[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/save_1.png"] selected:nil];
    [_controlItemback setTextColorNormal:[UIColor blackColor] highlighted:[UIColor lightGrayColor]];
    [_controlItemBrush setTextColorNormal:[UIColor blackColor] highlighted:[UIColor lightGrayColor]];
    [_controlItemEraser setTextColorNormal:[UIColor blackColor] highlighted:[UIColor lightGrayColor]];
    [_controlItemRedo setTextColorNormal:[UIColor blackColor] highlighted:[UIColor lightGrayColor]];
    [_controlItemShare setTextColorNormal:[UIColor blackColor] highlighted:[UIColor lightGrayColor]];
    _viewBottom.layer.borderWidth = 1;
    _viewBottom.layer.borderColor = [UIColor grayColor].CGColor;
}

-(void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
// [_btnLogin setBackgroundImage:[[UIImage imageWithBundleFile:@"iPhone/User/log_in_0.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
    CGRect rect;
    //根据图片大小  设置位置  (居中)
    rect.size = self.bgImge.size;
    rect.origin = CGPointMake(0.5*self.view.bounds.size.width-0.5*rect.size.width, 0.5*self.view.bounds.size.height-0.5*rect.size.height-0.5*_viewBottom.height - 10);
    if (rect.origin.y <=  20) {
        rect.origin.y = 20;
        rect.size.height = self.view.bounds.size.height-_viewBottom.height-20;
        rect.size.width = rect.size.height/self.bgImge.size.height * rect.size.width;
        rect.origin.x = 0.5*self.view.bounds.size.width-0.5*rect.size.width;
    }
    _viewBg.frame = rect;
    
    //阴影背景
    UIImageView *imageViewShadow = [[UIImageView alloc]init];
//    imageViewShadow.contentMode = UIViewContentModeScaleAspectFill;
    imageViewShadow.frame = CGRectMake(rect.origin.x-5, rect.origin.y-5, rect.size.width+10, rect.size.height+10);
    imageViewShadow.image = [[UIImage imageWithBundleFile:@"iPhone/Settings/Draw/bg_draw_panel.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    imageViewShadow.userInteractionEnabled = NO;
    
    [self.view addSubview:imageViewShadow];
    [self.view sendSubviewToBack:imageViewShadow];
    
    
    //截屏的背景图 做画板背景
    rect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];

    imageView.image = self.bgImge;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_viewBg addSubview:imageView];
    
    //加上画板
    UIViewDraw *viewDraw =  [[UIViewDraw alloc] initWithFrame:rect];
    viewDraw.backgroundColor = [UIColor clearColor];
    [_viewBg addSubview:viewDraw];
    
    //初始化画板属性
    
    viewDraw.lineColor = [UIColor redColor];
    //红色对应的是 第四个按钮
    viewDraw.colorWithBtnTag = 4;
    viewDraw.eraserLineWidth = 10;
    viewDraw.brushLineWidth = 2;
    
    self.isSave = NO;
    
    _controlItemBrush.selected = YES;
    _viewDraw = viewDraw;
    
    //下边按钮栏放到屏幕最前面
    [self.view bringSubviewToFront:_viewBottom];
    

    NSUInteger i = 0;
    float spacing  = (self.view.frame.size.width-320)/6.0;
    for (UIView * subView in _viewBottom.subviews) {
        if ([subView isMemberOfClass:[UIControlItem class]]) {
            UIControlItem *but = (UIControlItem *)subView;
            but.frame = CGRectMake(spacing+(64+spacing)*1.0*i, 0, 64, 64);
            i++;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
//放回按钮
- (IBAction)onTouchBack
{

    if(self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//画笔按钮
- (IBAction)onTouchBrush
{
    _viewDraw.lineWidth = _viewDraw.brushLineWidth;
    //只有在选中状态才创建选择界面
    if(_controlItemBrush.selected == YES)
    {
        //创建选择界面  设置选择界面值
        UIViewBrushSet *viewBrushSet = [UIViewBrushSet viewBrushSetFromXib];
        
        viewBrushSet.delegate = self;
        [viewBrushSet setColor:_viewDraw.lineColor width:_viewDraw.brushLineWidth btnColorForTag:_viewDraw.colorWithBtnTag];
        
        [self.view addSubview:viewBrushSet];
        [viewBrushSet showInView:self.view completion:nil];
    }
   
    
    //按钮状态
    _viewDraw.isClearMode = NO;
    _controlItemBrush.selected = YES;
    _controlItemEraser.selected = NO;

}

//橡皮按钮
- (IBAction)onTouchEraser
{
    _viewDraw.lineWidth = _viewDraw.eraserLineWidth;
    //只有在选中状态才创建选择界面
    if (_controlItemEraser.selected == YES) {
        UIViewEraserSet *viewBrushSet = [UIViewEraserSet viewEraserSetFromXib];
        
        viewBrushSet.delegate = self;
        [viewBrushSet setEraserWidth:_viewDraw.eraserLineWidth];
        
        [self.view addSubview:viewBrushSet];
        [viewBrushSet showInView:self.view completion:nil];
    }
    
    //按钮状态
    _viewDraw.isClearMode = YES;
    _controlItemBrush.selected = NO;
    _controlItemEraser.selected = YES;
    
}

//清除按钮
- (IBAction)onTouchRedo
{
    [_viewDraw clear];
}

- (IBAction)onTouchMore
{
    UIViewPopShareOption *viewPop = [UIViewPopShareOption viewFromXibWithStyle:ShareOptionStyleScreenshot];
    viewPop.labelTitle.text = LocalizedString(@"fenxiangdao");
    [viewPop setCallbackSelectShareType:^(ShareType type) {
        NSString *title = [LocalizedString(@"zhonghualiulanqi") stringByAppendingFormat:@" %@", LocalizedString(@"jietutuya")];
        NSString *content = LocalizedString(@"shiyongzhonghualiulanqijietutuyagongnengbingfenxiang");
        content = [content stringByAppendingFormat:@" %@", kShareDefaultWebsite];
        SendShareContent(type, [UIImage imageFromView:_viewBg opaque:YES], title, content, kShareDefaultWebsite);
    }];
    [viewPop setCallbackSelectSaveImage:^{
        UIImage *image = [UIImage imageFromView:_viewBg opaque:YES];
        [SVProgressHUD showWithStatus:LocalizedString(@"zhengzaibaocuntupian") maskType:SVProgressHUDMaskTypeClear];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    [viewPop showInView:self.view completion:nil];
}

/**
 *  图片保存成功后的回调
 *
 *  @param image
 *  @param error
 *  @param contextInfo
 */
- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo
{
    if (error) {
        [SVProgressHUD showErrorWithStatus:[error localizedFailureReason]];
    }
    else {
        [SVProgressHUD showSuccessWithStatus:LocalizedString(@"tupianbaocunchenggong")];
    }
}

#pragma  mark UIViewBrushSetDelegate
- (void)viewBrushSetLineColor:(UIColor *)lineColor btnColorForTag:(NSInteger)tag
{
    _viewDraw.lineColor = lineColor;
    _viewDraw.colorWithBtnTag = tag;
}

- (void)viewBrushSetLineWidth:(CGFloat)lineWidth
{
    _viewDraw.brushLineWidth = lineWidth;
}

#pragma  mark UIViewEraserSetDelegate
- (void)viewEraserSetWidth:(CGFloat)eraserWidth
{
    _viewDraw.eraserLineWidth = eraserWidth;
}

@end
