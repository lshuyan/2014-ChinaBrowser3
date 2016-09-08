//
//  UIControllerLabelsList.m
//  ChinaBrowser
//
//  Created by 石显军 on 14/11/11.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "UIControllerLabelsList.h"
#import "UIScrollViewLablesList.h"
#import "UIScrollViewAppItemList.h"
#import "UIControllerManuallyAdd.h"
#import "UICellItemList.h"
#import "UIViewNav.h"

#import "ModelAppCate.h"
#import "ModelApp.h"

#import "ADOLinkIcon.h"

#define itemCellIdentifier @"UICellItemList"

@interface UIControllerLabelsList () <UITableViewDataSource, UITableViewDelegate>
{
    UIViewNav *_viewNav;
    // 分类列表
    IBOutlet UIScrollViewLablesList *_classificationList;
    // 自定义列表
    IBOutlet UITableView *_tableViewCustom;
    
    AFJSONRequestOperation *_afReqItemList;
}


@property (strong, nonatomic) IBOutlet UIScrollViewAppItemList *appItemList;
@property (nonatomic, strong) NSMutableArray *itemsArr;

@end

@implementation UIControllerLabelsList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LocalizedString(@"tianjiayingyong");
    _itemsArr = [[NSMutableArray alloc] init];
    
    [self loadSubViews];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSDictionary *dicParam = @{@"device":IsiPad?@"ipad":@"iphone"};
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_AppCate) parameters:dicParam];
    NSString *filepath = [GetCacheDataDir() stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    if (data) {
        [self resolveApp:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    }
    else {
        [self reqItemList];
    }
}

- (void)dealloc
{
    [_afReqItemList cancel];
    _afReqItemList = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutSubViewsWithInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (IsiPad) return;
    [_viewNav resizeWithOrientation:orientation];
    
    [_appItemList layoutScrollViewSubviews];
    
    CGRect rc = _appItemList.frame;
    rc.origin.y = _viewNav.bottom;
    rc.size.height = self.view.height-rc.origin.y;
    _appItemList.frame = rc;
    
    CGRect classificationListRc = _classificationList.frame;
    classificationListRc.origin.y = _viewNav.bottom;
    classificationListRc.size.height = self.view.height-classificationListRc.origin.y;
    _classificationList.frame = classificationListRc;
    
    CGRect tableViewRc = _tableViewCustom.frame;
    tableViewRc.origin.y = _viewNav.bottom;
    tableViewRc.size.height = self.view.height-tableViewRc.origin.y;
    _tableViewCustom.frame = tableViewRc;
    
    [_tableViewCustom reloadData];
}

#pragma mark - Request Data
- (void)reqItemList
{
    [_afReqItemList cancel];
    _afReqItemList = nil;
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@""]];
    NSDictionary *dicParam = @{@"device":IsiPad?@"ipad":@"iphone"};
    NSMutableURLRequest *req = [client requestWithMethod:@"GET" path:GetApiWithName(API_AppCate) parameters:dicParam];
    NSString *filepath = [GetCacheDataDir() stringByAppendingPathComponent:[req.URL.absoluteString fileNameMD5WithExtension:@"json"]];
    
    _afReqItemList = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([self resolveApp:JSON]) {
            [_afReqItemList.responseData writeToFile:filepath atomically:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSData *data = [NSData dataWithContentsOfFile:filepath];
        if (data) {
            [self resolveApp:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
        }
        else {
            [self resolveApp:nil];
        }
    }];
    
    [_afReqItemList start];
}

#pragma mark - Private Method
- (void)loadSubViews
{
    __weak typeof(self) weakself = self;
    _appItemList.callbackAddApp = _callbackAddApp;
    _appItemList.callbackIsExistApp = _callbackIsExistApp;
    _appItemList.callbackCanAddApp = _callbackCanAddApp;
    _appItemList.callbackOpen = _callbackOpen;
    
    _viewNav = [UIViewNav viewNav];
    _viewNav.title = self.title;
    [self.view addSubview:_viewNav];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(onTouchBack) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_0.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageWithBundleFile:@"iPhone/back_1.png"] forState:UIControlStateHighlighted];
    [btnBack sizeToFit];
    _viewNav.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    
    _classificationList.lableListDelegate = ^(NSInteger index){
        weakself.appItemList.hidden = !index;
        
        ModelAppCate *cateModel = weakself.itemsArr[index];
        weakself.appItemList.appList = cateModel.arrApp;
    };
}

- (BOOL)resolveApp:(NSDictionary *)dictResult
{
    BOOL retVal = NO;
    [_itemsArr removeAllObjects];
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
            
            [_itemsArr addObject:modelAppCate];
        }
        retVal = _itemsArr.count>0;
    } while (NO);
    
    ModelAppCate *appCate = [ModelAppCate model];
    appCate.name = LocalizedString(@"zidingyi");
    [_itemsArr insertObject:appCate atIndex:0];
    
    _classificationList.lableList = _itemsArr;
    
    return retVal;
}

#pragma mark - Action Method
- (void)onTouchBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UICellItemList *cell = [tableView dequeueReusableCellWithIdentifier:itemCellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UICellItemList1" owner:nil options:nil] lastObject];
    }
    cell.customIcon.image = [UIImage imageWithBundleFile:@"iPhone/App/add_write.png"];
    cell.customTitle.text = LocalizedString(@"shoudongshuru");
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableViewCustom deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakself = self;
    UIControllerManuallyAdd *manuallyAdd = [UIControllerManuallyAdd controllerFromXib];
    manuallyAdd.title = LocalizedString(@"shoudongtianjia");
    manuallyAdd.callbackDidEdit = ^(ModelApp *model){
        if (weakself.callbackAddApp) {
            weakself.callbackAddApp(model);
        }
    };
    [self.navigationController pushViewController:manuallyAdd animated:YES];
}

@end