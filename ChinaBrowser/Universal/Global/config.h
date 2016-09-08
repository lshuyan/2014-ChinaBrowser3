//
//  config.h
//
//  Created by David on 13-2-19.
//  Copyright (c) 2013年 KOTO Inc. All rights reserved.
//

#ifndef multi_func_config_h
#define multi_func_config_h

// 百度统计 中华浏览器
#define BaiduMobAppKey @"0d0167cbc4"

//------ ShareSDK 相关
// 国广
#define SSK_AppId_ShareSDK @"405867c8219e"
/**
 *  百度统计Key
 */
#define kBaiduMobAppKey @"0d0167cbc4"
/**
 *  默认分享的网站地址
 */
#define kShareDefaultWebsite @"http://www.chinaplus.net.cn/"
/**
 *  皮肤文件夹
 */
#define kSkinDirName IsiPad?@"skin/iPad":@"skin/iPhone"
/**
 *  应用屏最大允许的数量
 */
#define kMaxAppNumber   (30)
/**
 *  最大的网页数量
 */
#define kMaxWebViewNumber (10)
/**
 *  最近访问数量(最近访问的历史记录数量限制)
 */
#define kLastVisitNumber (20)
/**
 *  地址栏显示标题，YES:优先显示标题，NO:直接显示网址
 */
#define kUrlBarShowTitle (YES)
/**
 *  个性化定制 提醒操作 时长
 */
#define kReminderActionDuration (20.0f)
/**
 *  标签切换动画时的 缩放比例
 */
#define  kSwipeAnimScale 0.9
/**
 *  标签切换动画 时长
 */
#define  kSwipeAnimDuration 0.35
/**
 *  标签切换动画 标签透明度
 */
#define  kSwipeAnimAlpha 0.2

#define kBgColorNav [UIColor colorWithRed:0.161 green:0.161 blue:0.161 alpha:1.000]
#define kBgColorNavHome [UIColor colorWithWhite:1 alpha:0]

/**
 *  中华浏览器 App Apple ID
 */
#define kAppId @"855734279"

#endif
