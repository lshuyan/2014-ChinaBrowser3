//
//  API.m
//  WKBrowser
//
//  Created by David on 13-10-18.
//  Copyright (c) 2013年 VeryApps. All rights reserved.
//

#import "API.h"

static NSDictionary *dicHost;

/**
 *  得到完整api
 *
 *  @param api api名称
 *
 *  @return 完整的api路径
 */
inline NSString * GetApiWithName(NSString *api)
{
    NSString *host = GetApiBaseUrl();
    NSString *retApi = [host stringByAppendingString:api];
    _DEBUG_LOG(@"------：%@", retApi);
    return retApi;
}

inline NSString * GetApiBaseUrl()
{
    NSString *lan = [LocalizationUtil currLanguage];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dicHost = [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_DEBUG?@"api_host_debug.plist":@"api_host_release.plist"]];
    });
    NSString *host = dicHost[lan];
    if (!host) {
        // 如果没对应的语种的主机地址，那就是用App默认语种
        host = dicHost[kDefaultLanguage];
    }
    return host;
}

// -------------------- 启动图
/**
 *  启动图接口
 *  device=android|iphone|iphone5|iphone6|iphone6plus|ipad
 *  date: yyyyMMdd
 */
NSString * const API_LaunchImg = @"/zhie/index.php?m=index&a=start";

// -------------------- 检查更新
/**
 *  检查更新
 *  device=android|iphone|ipad
 */
NSString * const API_CheckVersion = @"/zhie/index.php?m=index&a=check_version";

// -------------------- 推荐屏
/**
 *  推荐屏广告
 *  device=android|iphone|ipad
 */
NSString * const API_RecommendAd = @"/zhie/index.php?m=index&a=home_ad";

/**
 *  推荐屏分类
 *  device=android|iphone|ipad
 */
NSString * const API_RecommendCate = @"/zhie/index.php?m=index&a=home_cate_header";

/**
 *  推荐屏子分类
 *  device=android|iphone|ipad
 *  catid：分类id
 */
NSString * const API_RecommendSubCate = @"/zhie/index.php?m=index&a=home_cate_cri";

/**
 *  新闻列表
 *  device=android|iphone|ipad
 *  catid：分类id
 *  pagesize：不传默认 10 条
 *  sid：最后一条数据id
 */
NSString * const API_RecommendNews = @"/zhie/index.php?m=index&a=news_list";

/**
 *  推荐屏轮动新闻
 *  device=android|iphone|ipad
 */
NSString * const API_RecommendScrollNews = @"/zhie/index.php?m=index&a=recommend";

// -------------------- 应用屏
/**
 *  应用分类
 *  device=android|iphone|ipad
 */
NSString *const API_AppCate = @"/zhie/index.php?m=index&a=home_app_show";

/**
 *  大家都在搜的App
 *  device=android|iphone|ipad
 *  pagesize:
 *  Keyword:
 */
NSString *const API_AppHotSearch = @"/zhie/index.php?m=index&a=home_app_dsearch";

/**
 *  应用搜索
 *  device=android|iphone|ipad
 *  Keyword:
 *  page:
 *  pagesize:
 *  sid:
 */
NSString *const API_AppSearch = @"/zhie/index.php?m=index&a=home_app_search";

/**
 *  默认推荐应用
 *  device=android|iphone|ipad
 */
NSString *const API_AppDefault = @"/zhie/index.php?m=index&a=home_app";


// -------------------- 情景翻译
/**
 *  翻译顶部图
 *  device=android|iphone|ipad
 */
NSString * const API_TransTopImg = @"/zhie/index.php?m=index&a=scene";

// -------------------- 旅游模块
/**
 *  旅游顶部图片
 *  device=android|iphone|ipad
 */
NSString * const API_TravelAd = @"/zhie/index.php?m=index&a=travelad";

/**
 *  旅游城市瀑布流列表
 *  device=android|iphone|ipad
 */
NSString * const API_Travel = @"/zhie/index.php?m=index&a=travel";

/**
 *  旅游城市详细，视频瀑布流列表
 *  device=android|iphone|ipad
 *  cid: 省份ID
 */
NSString * const API_TravelDetail = @"/zhie/index.php?m=index&a=travel_show";

// -------------------- 搜索模块
/**
 *  搜索引擎
 *  device=android|iphone|ipad
 */
NSString * const API_SearchEngine = @"/zhie/index.php?m=index&a=app_search";

/**
 *  【热门话题/热门搜索关键字】
 *  device=android|iphone|ipad
 */
NSString * const API_SearchHot = @"";

// -------------------- 分享项
/**
 *  分享项列表
 *  device=android|iphone|ipad
 */
NSString * const API_ShareList = @"/zhie/index.php?m=index&a=app_share";

// -------------------- 用户接口
/**
 *  用户注册
 *  username:邮箱/手机号
 *  nickname:昵称
 *  passwd:密码
 */
NSString * const API_UserRegister = @"/zhie/index.php?m=member&a=register";

/**
 *  用户登录
 *  username:邮箱/手机号 
 *  passwd:密码
 */
NSString * const API_UserLogin = @"/zhie/index.php?m=member&a=login";

/**
 *  第三方登陆
 *  uid:登录id
 *  access_token:授权access_token(必须)
 *  expires_in:授权access_token过期时间(必须)
 *  nickname:昵称
 *  avatar:图像
 */
NSString * const API_UserSDKLogin = @"/zhie/index.php?m=member&a=sdklogin";

/**
 *  资料修改
 *  POST
 *
 *  uid: 必填
 *  token: 必填
 *
 *  nickname:昵称
 *  Email:邮箱
 *  pwd:密码
 *  avatar:图像
 */
NSString * const API_UserEdit = @"/zhie/index.php?m=member&a=edit";

// --------------------- 个性化定制
/**
 *  App推荐 模式
 */
NSString * const API_ModeProgramRecommend = @"/zhie/index.php?m=program&a=index";

/**
 *  中华浏览器 节目库
 */
NSString * const API_ProgramList = @"/zhie/index.php?m=program&a=ulist";

// --------------------- 同步相关 ----------【clear】(***** 谨慎使用，测试用)
NSString * const API_ClearUserData = @"/zhie/index.php?m=member&a=clearUserData";

// --------------------- 同步相关接口 ------- 【add】
/**
 *  uid 会员id (必填项) 
 *  token:验证密钥 (必填项) 
 *  bookmark: 历史记录(数据)json格式。
 *  格式参数http://cn.china-plus.net/zhie/index.php?m=member&a=btest
 */
NSString * const API_AddUserBookmark = @"/zhie/index.php?m=member&a=addbookmark";
/**
 *  uid 会员id (必填项) 
 *  token:验证密钥 (必填项) 
 *  history: 历史记录(数据)json格式。
 *  格式参数http://cn.china-plus.net/zhie/index.php?m=member&a=htest
 */
NSString * const API_AddUserHistory = @"/zhie/index.php?m=member&a=addhistory";
NSString * const API_AddUserMode = @"/zhie/index.php?m=member&a=addMode";
NSString * const API_AddUserModeProgram = @"/zhie/index.php?m=member&a=addProgram";

// --------------------- 同步相关接口 ------- 【update】
/**
 *  update 用户设置
 *  POST
 *
 *  uid 会员id (必填项)
 *  token:验证密钥 (必填项)
 *  sync_bookmark: 书签(1:同步,0:不同步)
 *  sync_lastvisit:历史记录(1:同步,0:不同步)
 *  sync_reminder:个性化定制(1:同步,0:不同步)
 *  sync_style:同步方式(0:wifi,1:自动,2:手动)
 */
NSString * const API_UpdateUserSettings = @"/zhie/index.php?m=member&a=usettings";
NSString * const API_UpdateUserBookmark = @"/zhie/index.php?m=member&a=updatebookmark";
/**
 *  update 历史记录 （最近浏览）
 *  POST
 *
 *  uid 会员id (必填项)
 *  token:验证密钥 (必填项)
 *  history: 历史记录(数据)json格式。
 */
NSString * const API_UpdateUserHistory = @"/zhie/index.php?m=member&a=updatehistory";
NSString * const API_UpdateUserMode = @"/zhie/index.php?m=member&a=updateMode";
NSString * const API_UpdateUserModeProgram = @"/zhie/index.php?m=member&a=updateProgram";

// --------------------- 同步相关接口 ------- 【delete】
/**
 *  uid 会员id (必填项)
 *  token:验证密钥 (必填项)
 *  bookmark: 历史记录(数据)json格式。
 *  格式参数http://cn.china-plus.net/zhie/index.php?m=member&a=bdtest
 */
NSString * const API_DeleteUserBookmark = @"/zhie/index.php?m=member&a=delbookmark";
/**
 *  uid 会员id (必填项)
 *  token:验证密钥 (必填项)
 *  history: 历史记录(数据)json格式。
 *  格式参数http://cn.china-plus.net/zhie/index.php?m=member&a=dtest
 */
NSString * const API_DeleteUserHistory = @"/zhie/index.php?m=member&a=delhistory";
/**
 *  删除模式
 *  uid 会员id          （必填项）
 *  token：验证密钥    （必填项）
 *  mode：模式信息 [{pkid}];
 */
NSString * const API_DeleteUserMode = @"/zhie/index.php?m=member&a=delmode";
NSString * const API_DeleteUserModeProgram = @"t/zhie/index.php?m=member&a=delProgram";

// --------------------- 同步相关接口 ------- 【get】
NSString * const API_GetUserSettings = @"/zhie/index.php?m=member&a=getuSettings";
NSString * const API_GetUserBookmark = @"/zhie/index.php?m=member&a=getbookmark";
/**
 *  get 历史记录接口 (最近浏览)
 *  POST
 *
 *  uid 会员id (必填项) 
 *  token:验证密钥 (必填项)
 *  pagesize: 显示条数 
 *  sid:最后一条列表id(此参数是下拉刷新使用)
 */
NSString * const API_GetUserHistory = @"/zhie/index.php?m=member&a=gethistory";
NSString * const API_GetUserMode = @"/zhie/index.php?m=member&a=getMode";
NSString * const API_GetUserModeProgram = @"/zhie/index.php?m=member&a=getProgram";

// --------------------- 其他网页地址(意见反馈，帮助中心，产品介绍，中华浏览器用户服务协议)
NSString * const API_Feedback = @"/zhie/index.php/Suggest/index";
NSString * const API_Help = @"/zhie/index.php/article/index/id/4";
NSString * const API_Intro = @"/zhie/index.php/article/index/id/3";
NSString * const API_UserProtocol = @"/zhie/index.php/article/index/id/5";

/**
 *  忘记密码
 */
NSString * const API_UserForgotPwd = @"";

// --------------------- AppStore 接口
/**
 *  AppStore 评分地址
 */
NSString * const API_AppStoreRate = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
/**
 *  AppStore 下载地址
 */
NSString * const API_AppStoreDownload = @"itms-apps://itunes.apple.com/app/id%@";
