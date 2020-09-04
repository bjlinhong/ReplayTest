//
//  SampleHandler.m
//  retest
//
//  Created by LiuLinhong on 2020/03/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//


#import "SampleHandler.h"
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>


@interface SampleHandler () <RCRTCRoomEventDelegate>

@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, strong) RCRTCVideoOutputStream *videoOutputStream;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *roomId;

@end


@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    
    // 请填写您的 AppKey
    self.appKey = @"";
    // 请填写用户的 Token
    self.token = @"";
    // 请指定房间号
    self.roomId = @"";
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:self.appKey];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    
    // 连接 IM
    [[RCIMClient sharedRCIMClient] connectWithToken:self.token
                                           dbOpened:^(RCDBErrorCode code) {
        NSLog(@"dbOpened: %zd", code);
    } success:^(NSString *userId) {
        NSLog(@"connectWithToken success userId: %@", userId);
        // 加入房间
        [[RCRTCEngine sharedInstance] joinRoom:self.roomId
                                    completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
            self.room = room;
            self.room.delegate = self;
            [self publishScreenStream];
        }];
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"ERROR status: %zd", errorCode);
    }];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [[RCRTCEngine sharedInstance] leaveRoom:self.roomId
                                 completion:^(BOOL isSuccess, RCRTCCode code) {
        self.videoOutputStream = nil;
    }];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    //NSLog(@"processSampleBuffer: %zd", sampleBufferType);
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self.videoOutputStream write:sampleBuffer error:nil];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
        default:
            break;
    }
}

#pragma mark - Private
- (void)publishScreenStream {
    self.videoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:@"RCRTCScreenVideo"];
    RCRTCVideoStreamConfig *videoConfig = self.videoOutputStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset1280x720;
    [self.videoOutputStream setVideoConfig:videoConfig];
    
    [self.room.localUser publishStream:self.videoOutputStream completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess)
            NSLog(@"发布自定义流成功");
        else
            NSLog(@"发布自定义流失败");
    }];
}

@end
