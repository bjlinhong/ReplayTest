//
//  BroadcastSetupViewController.m
//  retestSetupUI
//
//  Created by LiuLinhong on 2020/03/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController


- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setFrame:CGRectMake(100, 100, 100, 100)];
    [startBtn setBackgroundColor:[UIColor purpleColor]];
    [startBtn setTitle:@"开始共享" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(userDidFinishSetup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(230, 100, 100, 100)];
    [closeBtn setBackgroundColor:[UIColor redColor]];
    [closeBtn setTitle:@"结束共享" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(userDidCancelSetup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/streamID"];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    NSMutableDictionary *setupInfo = [NSMutableDictionary dictionary];
    setupInfo[@"appkey"] = @""; // 也可从此处传递到 SampleHandler.m 的 broadcastStartedWithSetupInfo: 方法中
    setupInfo[@"token"] = @"";
    setupInfo[@"roomid"] = @"";
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

@end
