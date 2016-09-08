//
//  UIScrollViewApp.m
//  ChinaBrowser
//
//  Created by David on 14-9-29.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIScrollViewApp.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#import "UIControlItemApp.h"
#import "ModelAppCate.h"
#import "ModelApp.h"
#import "ADOApp.h"
#import "ADOLinkIcon.h"
#import "KTAnimationKit.h"

#define kMinCateItemW (90.0f)
#define kMinPaddingLR (0.0f)

@interface UIScrollViewApp () <UIControlItemAppDelegate>

@end

@implementation UIScrollViewApp
{
    // App Model
    NSMutableArray *_arrApp;
    // App View Item
    NSMutableArray *_arrViewAppItem;
    
    /**
     *  添加按钮
     */
    UIControlItemApp *_controlItemAppAdd;
    
    AFJSONRequestOperation *_afReqApps;
    AFJSONRequestOperation *_afReqAppCate;
    
    /**
     *  分类项的宽高
     */
    CGFloat _fItemW;
    CGFloat _fItemH;
    /**
     *  但前布局的列数
     */
    NSInteger _iColCount;
    
    /**
     *  默认数量，服务器默认的应用数量
     */
    NSInteger _iDefaultNumber;
    
    // 重新排序的数组范围
    NSRange _rangeOrder;
    // 自动滚动计时器
    NSTimer *_timerOffset;
    // 正在拖拽的项
    UIControlItemApp *_controlItemAppDrag;
}

#pragma mark - property
- (void)setEdit:(BOOL)edit
{
    if (edit==_edit) {
        return;
    }
    _edit = edit;
    for (UIControlItemApp *controlItemApp in _arrViewAppItem) {
        if (controlItemApp.allowEdit) {
            controlItemApp.edit = edit;
        }
    }
    [_delegateApps scrollViewApp:self edit:_edit];
    
    _controlItemAppAdd.hidden = ![self canAdd]||edit;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)dealloc
{
    [_afReqApps cancel];
    _afReqApps = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self resizeItem];
    
    _DEBUG_LOG(@"%s", __FUNCTION__);
}

#pragma mark - AppLanguageProtocol
/**
 *  更新语言，需要更新 对应语言数据，所以需要重新请求数据
 */
- (void)updateByLanguage
{
    [self reqAppCate];
    [self reqApps];
}

#pragma mark - private methods
- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeItem) name:KNotificationDidChanageDesktopStyle object:nil];
    
    _controlItemAppAdd = [UIControlItemApp viewFromXibWithType:ControlItemTypeAppAdd];
    _controlItemAppAdd.delegate = self;
    [_controlItemAppAdd setBgColorNormal:[UIColor clearColor] highlighted:[UIColor colorWithWhite:0 alpha:0]];
    [_controlItemAppAdd setImageNormal:[UIImage imageWithBundleFile:@"iPhone/Home/add_0.png"]
                           highlighted:[UIImage imageWithBundleFile:@"iPhone/Home/add_1.png"]
                              selected:nil];
    _controlItemAppAdd.imageViewIcon.contentMode = UIViewContentModeCenter;
    _controlItemAppAdd.border = UIBorderAll;
    
    /*
    _controlItemAppAdd.layer.allowsEdgeAntialiasing = NO;
    _controlItemAppAdd.layer.shouldRasterize = YES;
    _controlItemAppAdd.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _controlItemAppAdd.layer.borderWidth = 0.5;
    _controlItemAppAdd.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
     */
    
    _controlItemAppAdd.borderColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    _controlItemAppAdd.borderWidth = 0.6;
    [_controlItemAppAdd addTarget:self action:@selector(onTouchAdd) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_controlItemAppAdd];
    
    _arrViewAppItem = [NSMutableArray array];
    _arrApp = [NSMutableArray array];
    _iDefaultNumber = 0;
    
    [self updateByLanguage];
}

- (BOOL)resolveApp:(NSDictionary *)dictResult
{
    BOOL retVal = NO;
    do {
        if (![dictResult isKindOfClass:[NSDictionary class]]) break;
        NSArray *arrDictAppCate = dictResult[@"data"];
        if (![arrDictAppCate isKindOfClass:[NSArray class]]) break;
        
        for (NSDictionary *dictAppCate in arrDictAppCate) {
            ModelAppCate *modelAppCate = [ModelAppCate modelWithDict:dictAppCate];
            
            /**
             *  将网站、图标信息保存到数据中
             */
            for (ModelApp *modelApp in modelAppCate.arrApp) {
                if (modelApp.appType!=AppTypeWeb) {
                    continue;
                }
                NSString *host = HostWithLink(modelApp.link);
                if ([ADOLinkIcon isExistWithLink:host]) {
                    [ADOLinkIcon updateWithLink:host icon:modelApp.icon];
                }
                else {
                    [ADOLinkIcon addLink:host icon:modelApp.icon];
                }
            }
        }
        retVal = arrDictAppCate.count>0;
    } while (NO);
    
    return retVal;
}

- (void)reqAppCate
{
    [_afReqAppCate cancel];
    _afReqAppCate = nil;
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSDictionary *dicParam = @{@"device":IsiPad?@"ipad":@"iphone"};
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_AppCate) parameters:dicParam];
    NSString *filepath = [GetCacheDataDir() stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    
    _afReqAppCate = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([self resolveApp:JSON]) {
            [_afReqAppCate.responseData writeToFile:filepath atomically:YES];
        }
    } failure:nil];
    
    [_afReqAppCate start];
}

/**
 *  网络请求 默认App 数据
 */
- (void)reqApps
{
    [_afReqApps cancel];
    _afReqApps = nil;
    
    BOOL (^showDefualtApp)(NSDictionary *) = ^(NSDictionary *dicResult){
        [_arrViewAppItem makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_arrViewAppItem removeAllObjects];
        [_arrApp removeAllObjects];
        _iDefaultNumber = 0;
        
        _controlItemAppAdd.frame = [self frameAtIndex:0];
        
        BOOL ret = NO;
        do {
            if (![dicResult isKindOfClass:[NSDictionary class]]) break;
            
            NSArray *arrDicCate = dicResult[@"data"];
            if (![arrDicCate isKindOfClass:[NSArray class]]) break;
            
            _iDefaultNumber = arrDicCate.count;
            
            // 解析成模型对象
            for (NSDictionary *dicCate in arrDicCate) {
                ModelApp *model = [ModelApp modelWithDict:dicCate];
                [self addAppWithModel:model isCustom:NO];
            }
            
            ret = _arrApp.count>0;
        } while (NO);
        
        return ret;
    };
    
    NSDictionary *dicParam = @{@"device":IsiPad?@"ipad":@"iphone"};
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_AppDefault) parameters:dicParam];
    NSString *filepath = [GetCacheDataDir() stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    _afReqApps = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (showDefualtApp(JSON)) {
            [_afReqApps.responseData writeToFile:filepath atomically:YES];
        }
        
        [self loadCustomApp];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            showDefualtApp([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]);
        }
        else {
            showDefualtApp(nil);
        }
        
        [self loadCustomApp];
    }];
    [_afReqApps start];
}

/**
 *  加载用户自定义App
 */
- (void)loadCustomApp
{
    NSArray *arrApp = [ADOApp queryWithUserId:[UserManager shareUserManager].currUser.uid];
    for (ModelApp *model in arrApp) {
        [self addAppWithModel:model isCustom:YES];
    }
}

/**
 *  添加一个App到UI
 *
 *  @param model    App 实体对象
 *  @param isCustom 是否自定义App
 */
- (void)addAppWithModel:(ModelApp *)model isCustom:(BOOL)isCustom
{
    [self addAppWithModel:model isCustom:isCustom animated:NO];
}

/**
 *  添加一个App到UI
 *
 *  @param model    App 实体对象
 *  @param isCustom 是否自定义Ap
 *  @param animated 是否动画
 */
- (void)addAppWithModel:(ModelApp *)model isCustom:(BOOL)isCustom animated:(BOOL)animated
{
    if (![self canAdd]) {
        return;
    }
    
    [_arrApp addObject:model];
    
    UIControlItemApp *viewAppItem = [UIControlItemApp viewFromXibWithType:ControlItemTypeApp];
    viewAppItem.frame = _controlItemAppAdd.frame;
    viewAppItem.delegate = self;
    viewAppItem.imageViewIcon.contentMode = UIViewContentModeScaleAspectFit;
    if (model.icon.length>0) {
        __unsafe_unretained UIImageView *wImageViewIcon = viewAppItem.imageViewIcon;
        [viewAppItem.imageViewIcon setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageWithBundleFile:@"iPhone/App/ic_app_default.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (!image) {
                wImageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/App/ic_app_default.png"];
            }
            else {
                wImageViewIcon.image = image;
                [KTAnimationKit animationEaseIn:wImageViewIcon];
            }
        }];
    }
    else {
        viewAppItem.imageViewIcon.image = [UIImage imageWithBundleFile:@"iPhone/App/ic_app_default.png"];
    }
    viewAppItem.labelTitle.text = model.title;
    [viewAppItem addTarget:self action:@selector(onTouchItem:) forControlEvents:UIControlEventTouchUpInside];
    [_arrViewAppItem addObject:viewAppItem];
    [self insertSubview:viewAppItem belowSubview:_controlItemAppAdd];
    
    [viewAppItem setBgColorNormal:[UIColor clearColor] highlighted:[UIColor colorWithWhite:0.93 alpha:0.2]];
    [viewAppItem setTextColorNormal:[UIColor whiteColor] highlighted:[UIColor colorWithWhite:0.9 alpha:1]];
    
    viewAppItem.borderColor = _controlItemAppAdd.borderColor;
    viewAppItem.borderWidth = _controlItemAppAdd.borderWidth;
    viewAppItem.border = UIBorderAll;
    
    /*
     viewAppItem.layer.allowsEdgeAntialiasing = _controlItemAppAdd.layer.allowsEdgeAntialiasing;
     viewAppItem.layer.shouldRasterize = _controlItemAppAdd.layer.shouldRasterize;
     viewAppItem.layer.borderWidth = _controlItemAppAdd.layer.borderWidth;
     viewAppItem.layer.borderColor = _controlItemAppAdd.layer.borderColor;
     viewAppItem.layer.rasterizationScale = _controlItemAppAdd.layer.rasterizationScale;
     */
    
    viewAppItem.allowEdit = isCustom?YES:NO;
    
    CGRect rcAdd;
    BOOL canAdd = [self canAdd];
    _controlItemAppAdd.hidden = !canAdd;
    if (canAdd) {
        rcAdd = [self frameAtIndex:_arrViewAppItem.count];
    }
    else {
        rcAdd = [self frameAtIndex:_arrViewAppItem.count-1];
    }
    
    if (animated) {
        viewAppItem.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:0.3 animations:^{
            viewAppItem.transform = CGAffineTransformIdentity;
            _controlItemAppAdd.frame = rcAdd;
            self.contentSize = CGSizeMake(self.width, _controlItemAppAdd.bottom);
        }];
    }
    else {
        _controlItemAppAdd.frame = rcAdd;
        self.contentSize = CGSizeMake(self.width, _controlItemAppAdd.bottom);
    }
}

/**
 *  添加一个自定义App到UI
 *
 *  @param model    App 实体对象
 *  @param animated 是否动画
 */
- (void)addAppWithModel:(ModelApp *)model animated:(BOOL)animated
{
    [self addAppWithModel:model isCustom:YES animated:animated];
}

/**
 *  添加自定义App前需要检查
 *  检查是否存在相同的数据
 *
 *  @param type       应用类型
 *  @param link       链接地址
 *  @param urlSchemes
 *
 *  @return BOOL
 */
- (BOOL)isExistWithType:(AppType)type link:(NSString *)link urlSchemes:(NSString *)urlSchemes
{
    NSArray *arrAppDefault = [_arrApp subarrayWithRange:NSMakeRange(0, _iDefaultNumber)];
    NSPredicate *predicate = nil;
    if (type==AppTypeNative) {
        predicate = [NSPredicate predicateWithFormat:@"appType==%d and urlSchemes==%@", type, urlSchemes];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"appType==%d and link==%@", type, link];
    }
    BOOL isExistDefault = [arrAppDefault filteredArrayUsingPredicate:predicate].count>0;
    BOOL isExistCustom = [ADOApp isExistWithAppType:type link:link urlSchemes:urlSchemes userId:[UserManager shareUserManager].currUser.uid];
    return isExistDefault|isExistCustom;
}

/**
 *  添加自定义App前需要检查
 *  检查是否还可添加App，不允许超过当前语言环境指定数量的App个数
 *
 *  @return BOOL
 */
- (BOOL)canAdd
{
    return _arrApp.count<kMaxAppNumber;
}

/**
 *  通过链接地址删除一个App
 *
 *  @param link 链接地址
 */
- (void)removeWithLink:(NSString *)link
{
    NSArray *arrAppCustom = [_arrApp subarrayWithRange:NSMakeRange(_iDefaultNumber, _arrApp.count-_iDefaultNumber)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appType==%d and link==%@", AppTypeWeb, link];;
    if ([[arrAppCustom filteredArrayUsingPredicate:predicate] count]>0) {
        ModelApp *modelApp = arrAppCustom[0];
        [self removeItemAtIndex:[_arrApp indexOfObject:modelApp] animated:NO];
    }
}

/**
 *  重新加载自定义App
 */
- (void)reloadCustomApp
{
    NSRange rangOfCustom = NSMakeRange(_iDefaultNumber, _arrApp.count-_iDefaultNumber);
    
    NSArray *arrCustomView = [_arrViewAppItem subarrayWithRange:rangOfCustom];
    [arrCustomView makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_arrApp removeObjectsInRange:rangOfCustom];
    [_arrViewAppItem removeObjectsInRange:rangOfCustom];
    
    _controlItemAppAdd.frame = [self frameAtIndex:_iDefaultNumber];
    
    [self setContentSize:CGSizeMake(self.width, _controlItemAppAdd.bottom)];
    
    [self loadCustomApp];
}

/**
 *  根据样式和最小项宽计算允许容纳的最大列数
 *
 *  @return 列数
 */
- (NSInteger)getColCount
{
    // 默认按横屏允许的最小宽高计算列数
    CGFloat baseMinItemWidth = kMinCateItemW;
    if (IsPortrait) {
        // 竖屏时，需要根据App设置的桌面样式计算列数
        NSInteger colTotal = (NSInteger)[AppSetting shareAppSetting].desktopStyle;
        baseMinItemWidth = floorf(self.width/colTotal);
    }
    CGFloat w = kMinPaddingLR+baseMinItemWidth;
    NSInteger colCount = 0;
    while (w+kMinPaddingLR<=self.bounds.size.width) {
        colCount++;
        w+=baseMinItemWidth;
    }
    return colCount;
}

- (CGRect)frameAtIndex:(NSInteger)index
{
    NSInteger col = GetColWithIndexCol(index, _iColCount);
    NSInteger row = GetRowWithIndexCol(index, _iColCount);
    CGRect rc = CGRectMake((_fItemW*col),
                           (_fItemH)*row,
                           _fItemW,
                           _fItemH);
    return rc;
}

/**
 *  重新调整大小布局
 */
- (void)resizeItem
{
    [self resizeItemExceptItem:nil];
}

/**
 *  重新调整大小布局
 *
 *  @param exceptItem 排除项
 */
- (void)resizeItemExceptItem:(UIControlItemApp *)exceptItem
{
    _iColCount = [self getColCount];
    _fItemW = self.width/_iColCount;
    _fItemH = _fItemW+30;
    
    NSInteger itemCount = _arrViewAppItem.count;
    NSInteger beginIndex = 0;
    for (NSInteger i=beginIndex; i<itemCount; i++) {
        NSInteger newIndex = i-(IsPortrait?0:beginIndex);
        UIControlItemApp *viewItemApp = _arrViewAppItem[i];
        if (viewItemApp!=exceptItem) {
            viewItemApp.frame = [self frameAtIndex:newIndex];
        }
        
        viewItemApp.border = UIBorderAll;
    }
    
    CGRect rcAdd;
    BOOL canAdd = [self canAdd];
    if (canAdd) {
        _controlItemAppAdd.hidden = _edit;
        rcAdd = [self frameAtIndex:_arrViewAppItem.count];
    }
    else {
        rcAdd = [self frameAtIndex:_arrViewAppItem.count-1];
        _controlItemAppAdd.hidden = YES;
    }
    
    _controlItemAppAdd.frame = rcAdd;
    self.contentSize = CGSizeMake(self.width, _controlItemAppAdd.bottom);
}

/**
 *  递减
 */
- (void)startDecrementOffset
{
    [self stopTimerOffset];
    // 启动
    _timerOffset = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(offsetDecrement) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timerOffset forMode:NSRunLoopCommonModes];
}

- (void)offsetDecrement
{
    // 递减
    CGPoint pt = self.contentOffset;
    pt.y--;
    CGPoint centerBeforDrag = _controlItemAppDrag.center;
    centerBeforDrag.y--;
    if (pt.y<0) {
        [self stopTimerOffset];
    }
    else {
        self.contentOffset = pt;
        _controlItemAppDrag.center = centerBeforDrag;
    }
}

/**
 *  递增
 */
- (void)startIncrementOffset
{
    [self stopTimerOffset];
    // 启动
    _timerOffset = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(offsetIncrement) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timerOffset forMode:NSRunLoopCommonModes];
}

- (void)offsetIncrement
{
    // 递减
    CGPoint pt = self.contentOffset;
    pt.y++;
    CGPoint centerBeforDrag = _controlItemAppDrag.center;
    centerBeforDrag.y++;
    
    if (pt.y>self.contentSize.height-self.height) {
        [self stopTimerOffset];
    }
    else {
        self.contentOffset = pt;
        _controlItemAppDrag.center = centerBeforDrag;
    }
}

/**
 *  停止计时器
 */
- (void)stopTimerOffset
{
    if (_timerOffset) {
        [_timerOffset invalidate];
        _timerOffset = nil;
    }
}

/**
 *  将某个视图移动到某个索引处，更新位置
 *
 *  @param userInfo
 */
- (void)moveToIndexWithUserInfo:(NSDictionary *)userInfo
{
    NSInteger moveToIndex = [userInfo[@"index"] integerValue];
    UIControlItemApp *viewItem = userInfo[@"item"];
    
    NSInteger fromIndex = [_arrViewAppItem indexOfObject:viewItem];
    ModelApp *model = _arrApp[fromIndex];
    
    [_arrViewAppItem removeObjectAtIndex:fromIndex];
    [_arrApp removeObjectAtIndex:fromIndex];
    
    [_arrViewAppItem insertObject:viewItem atIndex:moveToIndex];
    [_arrApp insertObject:model atIndex:moveToIndex];
    viewItem.animating = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self resizeItemExceptItem:viewItem];
    } completion:^(BOOL finished) {
        viewItem.animating = NO;
    }];
}

/**
 *  点击某个App事件
 *
 *  @param item
 */
- (void)onTouchItem:(UIControlItemApp *)item
{
    ModelApp *model = _arrApp[[_arrViewAppItem indexOfObject:item]];
    if (_edit) {
        if (model.appType==AppTypeWeb) {
            [_delegateApps scrollViewApp:self willEditItem:model viewAppItem:item];
        }
        else {
            [SVProgressHUD showErrorWithStatus:LocalizedString(@"feiwangyeappbunengxiugaibiaotihelianjie")];
        }
    }
    else {
        if ([_delegateApps respondsToSelector:@selector(scrollViewApp:openModel:)]) {
            [_delegateApps scrollViewApp:self openModel:model];
        }
    }
}

/**
 *  天使按钮事件
 */
- (void)onTouchAdd
{
    [_delegateApps scrollViewAppWillAddItem:self];
}

/**
 *  删除某个索引处的App
 *
 *  @param index 索引
 */
- (void)removeItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    UIControlItemApp *willRemoveItemApp = _arrViewAppItem[index];
    ModelApp *model = _arrApp[index];
    if ([ADOApp deleteWithPkid:model.pkid]) {
        if (animated) {
            
            [_arrViewAppItem removeObjectAtIndex:index];
            [_arrApp removeObjectAtIndex:index];
            
            [UIView animateWithDuration:0.25 animations:^{
                willRemoveItemApp.transform = CGAffineTransformMakeScale(0.01, 0.01);
            } completion:^(BOOL finished) {
                [willRemoveItemApp removeFromSuperview];
                if (_arrApp.count-_iDefaultNumber==0) {
                    [self setEdit:NO];
                }
            }];
            
            [UIView animateWithDuration:0.35 animations:^{
                [self resizeItem];
            }];
        }
        else {
            [willRemoveItemApp removeFromSuperview];
            [_arrViewAppItem removeObjectAtIndex:index];
            [_arrApp removeObjectAtIndex:index];
            if (_arrApp.count-_iDefaultNumber==0) {
                [self setEdit:NO];
            }
            [self resizeItem];
        }
        
        // 更新 排序 索引
        for (NSInteger i=index; i<_arrApp.count; i++) {
            ModelApp *modelItem = _arrApp[i];
            modelItem.sortIndex = i-_iDefaultNumber;
            [ADOApp updateOrderIndex:modelItem.sortIndex withPkid:modelItem.pkid];
        }
    }
}

#pragma mark - UIControlItemAppDelegate
/**
 *  刚开始拖拽
 *
 *  @param controlItemApp
 */
- (void)controlItemAppDidBeginDrag:(UIControlItemApp *)controlItemApp
{
    _rangeOrder.length = 0;
    _rangeOrder.location = [_arrViewAppItem indexOfObject:controlItemApp];
    _controlItemAppDrag = controlItemApp;
    
    [self bringSubviewToFront:controlItemApp];
//    controlItemApp.border = UIBorderAll;
    [UIView animateWithDuration:0.3 animations:^{
        controlItemApp.transform = CGAffineTransformMakeScale(1.1, 1.1);
    }];
}

/**
 *  正在拖拽某个App
 *
 *  @param controlItemApp
 */
- (void)controlItemAppMoving:(UIControlItemApp *)controlItemApp
{
    if (controlItemApp.animating) {
        // 动画过程中不允许重新排列顺序
//        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 检查是否需要滚动视图
    CGRect rcInSelf = controlItemApp.frame;
    if (self.contentOffset.y>0 && (rcInSelf.origin.y-self.contentOffset.y)<0) {
        // start self.offset.y--
        if (!_timerOffset) {
            [self startDecrementOffset];
        }
        return;
    }
    else if (self.contentOffset.y < (self.contentSize.height-self.height) && (rcInSelf.origin.y+rcInSelf.size.height-self.contentOffset.y) > (self.height)) {
        // start self.offset.y++
        if (!_timerOffset) {
            [self startIncrementOffset];
        }
        return;
    }
    else {
        [self stopTimerOffset];
    }
    
    // 当前正在拖拽的App的中心
    CGPoint centerMove = [controlItemApp convertPoint:CGPointMake(controlItemApp.width/2, controlItemApp.height/2) toView:self];
    NSInteger moveToIndex = -1; // 移动的目标索引，处事为-1
    for (NSInteger i=0; i<_arrViewAppItem.count; i++) {
        UIControlItemApp *item = _arrViewAppItem[i];
        // 过滤本身和不可编辑的的项
        if (item==controlItemApp || !item.allowEdit) {
            continue;
        }
        // 判断某个App是否包含了正在拖拽的App的中心
        if (CGRectContainsPoint(item.frame, centerMove)) {
            moveToIndex = i;
            break;
        }
    }
    
    if (moveToIndex>-1) {
        // 目标索引大于-1，表示可以变换位置重新排序了，延时排序
        [self performSelector:@selector(moveToIndexWithUserInfo:)
                   withObject:@{@"index":@(moveToIndex),@"item":controlItemApp}
                   afterDelay:0.1];
    }
}

/**
 *  停止拖拽
 *
 *  @param controlItemApp
 */
- (void)controlItemAppDidEndDrag:(UIControlItemApp *)controlItemApp
{
    // 取消排序
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // 停止滚动计时器
    [self stopTimerOffset];
    
    // 计算需要持久化的排序项目
    NSInteger moveToIndex = [_arrViewAppItem indexOfObject:controlItemApp];
    _rangeOrder.length = labs(moveToIndex-_rangeOrder.location);
    if (moveToIndex<_rangeOrder.location) {
        _rangeOrder.location = moveToIndex;
    }
    // 重新持久化排序
    if (_rangeOrder.length>0) {
        for (NSInteger i=_rangeOrder.location; i<=(_rangeOrder.location+_rangeOrder.length); i++) {
            ModelApp *model = _arrApp[i];
            model.sortIndex = i-_iDefaultNumber;
            [ADOApp updateOrderIndex:model.sortIndex withPkid:model.pkid];
        }
    }
    
    _controlItemAppDrag = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        controlItemApp.transform = CGAffineTransformIdentity;
        [self resizeItemExceptItem:nil];
    }];
}

- (void)controlItemAppWillEdit:(UIControlItemApp *)controlItemApp
{
    if (!_edit) {
        [self setEdit:YES];
    }
}

/**
 *  即将删除某个App
 *
 *  @param controlItemApp
 */
- (void)controlItemAppWillDelete:(UIControlItemApp *)controlItemApp
{
    NSInteger indexWillDelete = [_arrViewAppItem indexOfObject:controlItemApp];
    [self removeItemAtIndex:indexWillDelete animated:YES];
}

@end
