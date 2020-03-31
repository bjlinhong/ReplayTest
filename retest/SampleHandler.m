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


@interface SampleHandler () <RongRTCRoomDelegate>

@property (nonatomic, strong) RongRTCRoom *room;
@property (nonatomic, strong) RongRTCAVOutputStream *videoOutputStream;
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
    // 连接 IM
    [[RCIMClient sharedRCIMClient] connectWithToken:self.token success:^(NSString *userId) {
        NSLog(@"connectWithToken success userId: %@", userId);
        // 加入房间
        [[RongRTCEngine sharedEngine] joinRoom:self.roomId completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
            self.room = room;
            self.room.delegate = self;
            [self publishScreenStream];
        }];
    } error:^(RCConnectErrorCode status) {
        NSLog(@"ERROR status: %zd", status);
    } tokenIncorrect:^{
        NSLog(@"tokenIncorrect");
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
    [[RongRTCEngine sharedEngine] leaveRoom:self.roomId completion:^(BOOL isSuccess, RongRTCCode code) {
        self.videoOutputStream = nil;
    }];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    NSLog(@"processSampleBuffer: %zd", sampleBufferType);
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
    RongRTCStreamParams *param = [[RongRTCStreamParams alloc] init];
    param.videoSizePreset = RongRTCVideoSizePreset1280x720;
    self.videoOutputStream = [[RongRTCAVOutputStream alloc] initWithParameters:param tag:@"RongRTCScreenVideo"];
    [self.room publishAVStream:self.videoOutputStream extra:@"" completion:^(BOOL isSuccess, RongRTCCode desc) {
    }];
}

@end
