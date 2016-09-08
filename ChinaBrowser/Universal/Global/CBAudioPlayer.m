//
//  CBAudioPlayer.m
//  ChinaBrowser
//
//  Created by David on 14/11/17.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "CBAudioPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ModelPlayItem.h"

#import "SDImageCache.h"

static CBAudioPlayer *_player;

@implementation CBAudioPlayer
{
    UIBackgroundTaskIdentifier bgTask;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerPlaybackStateDidChangeNotification:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
         */
        
        self.allowsAirPlay = YES;
        self.movieSourceType = MPMovieSourceTypeStreaming;
        self.repeatMode = MPMovieRepeatModeOne;
        bgTask = 0;
        
        // 允许后台播放
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)play
{
    if([UIApplication sharedApplication].applicationState==UIApplicationStateBackground) {
        [super play];
        
        UIApplication *application = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier newTask = [application beginBackgroundTaskWithExpirationHandler:nil];
        if(bgTask!= UIBackgroundTaskInvalid) {
            [application endBackgroundTask: bgTask];
        }
        
        bgTask = newTask;
    }
    else {
        [super play];
    }
}

- (void)playerPlaybackStateDidChangeNotification:(NSNotification *)notification
{
    _DEBUG_LOG(@"%s===state:%ld", __FUNCTION__, (long)self.playbackState);
}

/**
 *  锁屏播放信息
 */
- (void)configNowPlayingInfoCenter {
    MPNowPlayingInfoCenter *playInfo = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//    MPMediaItemArtwork *itemArtwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
    
    [dict setObject:_playItem.title?:@"" forKey:MPMediaItemPropertyTitle];
    [dict setObject:_playItem.fm?:@"" forKey:MPMediaItemPropertyAlbumTitle];
//    [dict setObject:itemArtwork forKey:MPMediaItemPropertyArtwork];
    [playInfo setNowPlayingInfo:dict];
}

- (void)setPlayItem:(ModelPlayItem *)playItem
{
    _playItem = playItem;
    [self setContentURL:[NSURL URLWithString:_playItem.link]];
    
    [self configNowPlayingInfoCenter];
}

#pragma mark -
// ----------------------------
+ (instancetype)player
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player = [[CBAudioPlayer alloc] init];
    });
    return _player;
}

+ (void)playWithItem:(ModelPlayItem *)playItem
{
    CBAudioPlayer *player = [CBAudioPlayer player];
    player.playItem = playItem;
    [player play];
}

+ (void)play
{
    CBAudioPlayer *player = [CBAudioPlayer player];
    [player play];
}

+ (void)pause
{
    CBAudioPlayer *player = [CBAudioPlayer player];
    [player pause];
}

+ (void)stop
{
    CBAudioPlayer *player = [CBAudioPlayer player];
    [player stop];
}

+ (void)reset
{
    CBAudioPlayer *player = [CBAudioPlayer player];
    [player stop];
    [player setPlayItem:nil];
}

+ (BOOL)isPlaying;
{
    return [CBAudioPlayer player].playbackState == MPMoviePlaybackStatePlaying;
}

+ (void)setPlayItem:(ModelPlayItem *)playItem
{
    [[CBAudioPlayer player] setPlayItem:playItem];
}

@end
