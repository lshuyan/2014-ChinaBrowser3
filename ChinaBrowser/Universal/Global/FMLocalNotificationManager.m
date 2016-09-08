//
//  FMLocalNotificationManager.m
//  ChinaBrowser
//
//  Created by David on 14/12/5.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "FMLocalNotificationManager.h"

#import "ADOModeProgram.h"
#import "ModelModeProgram.h"
#import "ModelProgram.h"

@implementation FMLocalNotificationManager


+ (NSInteger)numberOfLocalNotification
{
    return [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
}

/**
 *  更新本地通知，清除所有本地通知，然后注册指定模式的通知
 */
+ (void)resetNotificationWithModePkid:(NSInteger)modePkid
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSArray *arrModeProgram = [ADOModeProgram queryWithModePkid:modePkid];
    [arrModeProgram enumerateObjectsUsingBlock:^(ModelModeProgram *modeProgram, NSUInteger idx, BOOL *stop) {
        [FMLocalNotificationManager addNotificationWithModeProgram:modeProgram];
    }];
}

/**
 *  添加 一个节目 通知
 *
 *  @param modeProgram ModelModeProgram
 */
+ (void)addNotificationWithModeProgram:(ModelModeProgram *)modeProgram
{
    if (!modeProgram.on) return;
    
    if (modeProgram.repeatMode==RemindRepeatModeEveryDay) {
        [FMLocalNotificationManager addNotificationWithModeProgram:modeProgram repeatInterval:NSDayCalendarUnit weekday:0];
    }
    else {
        NSArray *arrRepeat = @[@(RemindRepeatMode0),
                               @(RemindRepeatMode1),
                               @(RemindRepeatMode2),
                               @(RemindRepeatMode3),
                               @(RemindRepeatMode4),
                               @(RemindRepeatMode5),
                               @(RemindRepeatMode6)];
        [arrRepeat enumerateObjectsUsingBlock:^(NSNumber *repeatMode, NSUInteger idx, BOOL *stop) {
            NSInteger weekday = idx+1;
            if (modeProgram.repeatMode&[repeatMode integerValue]) {
                [FMLocalNotificationManager addNotificationWithModeProgram:modeProgram repeatInterval:NSWeekCalendarUnit weekday:weekday];
            }
        }];
    }
}

/**
 *  添加 一个节目
 *
 *  @param modeProgram    modeProgram description
 *  @param repeatInterval repeatInterval description
 *  @param weekday        weekday description
 */
+ (void)addNotificationWithModeProgram:(ModelModeProgram *)modeProgram repeatInterval:(NSCalendarUnit)repeatInterval weekday:(NSInteger)weekday
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [self getFireDateWithTime:modeProgram.time weekday:weekday];
    notification.repeatInterval = repeatInterval;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = @{FMUserInfoKeyTitle:modeProgram.modelProgram.title,
                              FMUserInfoKeyFM:modeProgram.modelProgram.fm,
                              FMUserInfoKeyLink:modeProgram.modelProgram.link,
                              FMUserInfoKeySrcType:@(modeProgram.modelProgram.srcType),
                              FMUserInfoKeyCateId:@(modeProgram.modelProgram.recommendCateId),
                              FMUserInfoKeyModePkid:@(modeProgram.modePkid),
                              FMUserInfoKeyModeProgramPkid:@(modeProgram.pkid),
                              FMUserInfoKeyProgramPkidServer:@(modeProgram.modelProgram.pkid_server)};
    
    NSString *body = nil;
    NSString *action = nil;
    switch (modeProgram.modelProgram.srcType) {
        case ProgramSrcTypeFM:
        {
            NSString *strFormatRemindPlay = LocalizedString(@"nindingyuede_jijiangkaishi_shifoushouting");
            body = [NSString stringWithFormat:strFormatRemindPlay, modeProgram.modelProgram.title];
            action = LocalizedString(@"shouting");
        }break;
        case ProgramSrcTypeRecommendCate:
        {
            NSString *strFormatRemindRead = LocalizedString(@"nindingyuede_shijianyidao_shifouyuedu");
            body = [NSString stringWithFormat:strFormatRemindRead, modeProgram.modelProgram.title];
            action = LocalizedString(@"yuedu");
        }break;
        case ProgramSrcTypeWeb:
        {
            NSString *strFormatRemindRead = LocalizedString(@"nindingyuede_shijianyidao_shifouyuedu");
            body = [NSString stringWithFormat:strFormatRemindRead, modeProgram.modelProgram.title];
            action = LocalizedString(@"yuedu");
        }break;
            
        default:
            break;
    }
    notification.alertBody = body;
    notification.alertAction = action;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

/**
 *  是否启用 某个节目 通知
 *
 *  @param modeProgram modeProgram description
 *  @param enable      enable description
 */
+ (void)updateModeProgram:(ModelModeProgram *)modeProgram enable:(BOOL)enable
{
    /**
     *  无论什么情况，都必须先移除 指定节目的 所有通知
     */
    [FMLocalNotificationManager removeNotificationWithModeProgramPkid:modeProgram.pkid];
    
    if (enable) {
        [FMLocalNotificationManager addNotificationWithModeProgram:modeProgram];
    }
}

/**
 *  移除 一个节目通知
 *
 *  @param modeProgramPkid modeProgramPkid description
 */
+ (void)removeNotificationWithModeProgramPkid:(NSInteger)modeProgramPkid
{
    NSArray *arrLocalNotification = [[UIApplication sharedApplication] scheduledLocalNotifications];
    _DEBUG_LOG(@"xxxxxxxx LocalNotification.count = %lu", (unsigned long)arrLocalNotification.count);
    [arrLocalNotification enumerateObjectsUsingBlock:^(UILocalNotification *notification, NSUInteger idx, BOOL *stop) {
        NSInteger modeProgramPkikOfNotification = [notification.userInfo[FMUserInfoKeyModeProgramPkid] integerValue];
        if (modeProgramPkikOfNotification==modeProgramPkid) {
            _DEBUG_LOG(@"---------------- cancel local notification with modeProgramPkid = %ld", (long)modeProgramPkid);
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }];
}

/**
 *  清除所有本地 节目通知
 */
+ (void)clearNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

/**
 *  根据指定的一天内的 时间戳，和 重复的星期，计算偏移后的通知的 响应时间
 *
 *  @param time    一天内的时间戳
 *  @param weekday 星期，[1-7], 周日为1，如果为 0，表示不偏移
 *
 *  @return NSDate 通知响应时间
 */
+ (NSDate *)getFireDateWithTime:(NSInteger)time weekday:(NSInteger)weekday
{
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger currentTime = dateComp.hour*3600+dateComp.minute*60+dateComp.second;
    NSInteger offsetDay = weekday-dateComp.weekday;
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(time-currentTime)+((weekday==0)?0:86400*offsetDay)];
    return date;
}

@end