//
//  ViewController.m
//  ReplayTest
//
//  Created by LiuLinhong on 2020/03/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>

@interface ViewController () <RPBroadcastControllerDelegate, RPBroadcastActivityViewControllerDelegate>

@property (nonatomic, strong) RPBroadcastController *broadcastController;
@property (nonatomic, strong) UIButton *startBtn;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setFrame:CGRectMake(100, 200, 180, 80)];
    [self.startBtn setBackgroundColor:[UIColor blueColor]];
    [self.startBtn setTitle:@"App开启屏幕共享" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
}

- (void)startBtnAction {
    if (![RPScreenRecorder sharedRecorder].isRecording) {
        [self.startBtn setTitle:@"停止" forState:UIControlStateNormal];
        // 方式一: 弹出可选 Extension 页面, 点击触发 SampleHandler
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            if (error) {
                NSLog(@"RPBroadcast err %@", [error localizedDescription]);
            }
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }];
        
        // 方式二: 指定直接使用 Extension, 直接触发 RecoderSetupUI View Controller
        /*
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithPreferredExtension:@"cn.rongcloud.replaytest.RecoderSetupUI" handler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
            [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }];
         */
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
//    NSLog(@"BundleID %@", broadcastController.broadcastExtensionBundleID);
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
