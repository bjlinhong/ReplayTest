# ReplayTest

1. 请登录官网获取AppKey, Token 和 roomId, 填写在 SampleHandler.m的下面方法中

    // 请填写您的 AppKey
    
    self.appKey = @"";
    
    // 请填写用户的 Token
    
    self.token = @"";
    
    // 请指定房间号
    
    self.roomId = @"";
    
2. 在 pod repo update 之后, 使用 pod install 安装 podfile 中指定好的融去SDK库

3. pod install 完成后, 打开生成的 ReplayTest.xcworkspace

4. 受 ReplayKit 库限制, 在 App 中调用 Extension 启动屏幕共享时, 只能作用于 App 内, 如果退出 App 则无法得到屏幕内容

5. 如果通过长按控制台的屏幕录制弹出的菜单中选择 retest 启动屏幕共享是可以突破 App 内屏幕共享的限制, 退出 App 后也可以得到屏幕内容

6. ViewController.m 的 startBtnAction 方法中提供了两种 App 内启动屏幕共享的方式. 第一, 弹出可选 Extension 页面, 点击后启动; 第二, 代码中指定 Extension 的 Bundle ID 直接启动; 两种方式均无法突破 App 内屏幕共享的限制

7. BroadcastSetupViewController.m 的 userDidFinishSetup 方法中, 可以通过 setupInfo 传递数据到 SampleHandler.m 的
```
- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo 
```

 方法参数中, 提供给 RTCLib 使用. 如果在 SampleHandler.m 中指定 AppKey, Token, RoomID 也可以使用

8. 受限于 RongIMLib 库中的默认2分钟断开连接的限制, 需要修改如下 pod 路径下的 .plist 配置文件:
 ReplayTest/Pods/RongCloudIM/RongCloudIM/RCConfig.plist
 在此文件中添加:

 ```
 {
     Connection : {
 						ForceKeepAlive : 1
                  }
 
 
 }
 ```
 其中: Connection 和 ForceKeepAlive 类型为 Key值, 1 的类型为 Number
 
 
 
