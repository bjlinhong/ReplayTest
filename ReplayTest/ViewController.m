//
//  ViewController.m
//  ReplayTest
//
//  Created by LiuLinhong on 2020/03/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <RPBroadcastControllerDelegate, RPBroadcastActivityViewControllerDelegate>

@property (nonatomic, strong) RPBroadcastController *broadcastController;
@property (nonatomic, strong) RPSystemBroadcastPickerView *systemBroadcastPickerView;
@property (nonatomic, strong) UIButton *startBtn;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //方式一
    [self initMode_1];
    
    // 方法二, 方式三时使用
//    [self initMode_2_3];
}


/*********************************************************************************************************/

// 方式一: 点击录制按钮后, 会直接弹出系统录制屏幕窗口, 并在列表中只显示指定Extension, 停止时点击的按钮与开启是同一个按钮. 此方法 App 内外的屏幕均可录制.

- (void)initMode_1 {
    self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 80)];
    self.systemBroadcastPickerView.preferredExtension = @"cn.rongcloud.replaytest.Recoder";
    self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.systemBroadcastPickerView.showsMicrophoneButton = NO;
    [self.view addSubview:self.systemBroadcastPickerView];
}


/*********************************************************************************************************/

/*!
 以下是方式二, 方式三
 */
- (void)initMode_2_3 {
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setFrame:CGRectMake((ScreenWidth - 180) / 2, 200, 180, 80)];
    [self.startBtn setBackgroundColor:[UIColor blueColor]];
    [self.startBtn setTitle:@"App开启屏幕共享" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
}

- (void)startBtnAction {
    if (![RPScreenRecorder sharedRecorder].isRecording) {
        // 方式二: 弹出可选 Extension 页面, 点击触发 SampleHandler. 此方法仅能录制 App 内的屏幕, 退出 App 无法录制.
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            if (error) {
                NSLog(@"RPBroadcast err %@", [error localizedDescription]);
            }
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }];
        
        
        // 方式三: 指定直接使用 Extension, 直接触发 RecoderSetupUI View Controller. 此方法仅能录制 App 内的屏幕, 退出 App 无法录制.
        /*
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithPreferredExtension:@"cn.rongcloud.replaytest.RecoderSetupUI" handler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }];
         */
        
        [self.startBtn setTitle:@"停止" forState:UIControlStateNormal];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否停止屏幕共享" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes",nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.startBtn setTitle:@"App开启屏幕共享" forState:UIControlStateNormal];
            [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"finishBroadcastWithHandler: %@", error.localizedDescription);
                }
            }];
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Broadcasting
- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *) broadcastActivityViewController
       didFinishWithBroadcastController:(RPBroadcastController *)broadcastController
                                  error:(NSError *)error {
    
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:nil];
    self.broadcastController = broadcastController;
    self.broadcastController.delegate = self;
    if (error) {
        NSLog(@"BAC: %@ didFinishWBC: %@, err: %@",
              broadcastActivityViewController,
              broadcastController,
              error);
        return;
    }

    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"-----start success----");
            // 这里可以添加camerPreview
        } else {
            NSLog(@"startBroadcast:%@",error.localizedDescription);
        }
    }];
}

// Watch for service info from broadcast service
- (void)broadcastController:(RPBroadcastController *)broadcastController
       didUpdateServiceInfo:(NSDictionary <NSString *, NSObject <NSCoding> *> *)serviceInfo {
    NSLog(@"didUpdateServiceInfo: %@", serviceInfo);
}

// Broadcast service encountered an error
- (void)broadcastController:(RPBroadcastController *)broadcastController
         didFinishWithError:(NSError *)error {
    NSLog(@"didFinishWithError: %@", error);
}

- (void)broadcastController:(RPBroadcastController *)broadcastController didUpdateBroadcastURL:(NSURL *)broadcastURL {
    NSLog(@"---didUpdateBroadcastURL: %@",broadcastURL);
}

@end
