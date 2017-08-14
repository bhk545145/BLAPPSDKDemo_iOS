//
//  AppDelegate.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "AppDelegate.h"
#import "AppMacro.h"
#import "DeviceDB.h"
#import "MainViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self loadAppSdk];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    [self handleOpenFromOtherApp:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    [self handleOpenFromOtherApp:url];
    return YES;
}

#pragma mark - private method
- (void)loadAppSdk {
    self.let = [BLLet sharedLetWithLicense:SDK_LICENSE];        // Init APPSDK
    self.let.debugLog = BL_LEVEL_ALL;                           // Set APPSDK debug log level
    
    [self.let.controller setSDKRawDebugLevel:BL_LEVEL_ERROR];     // Set DNASDK debug log level
    [self.let.controller startProbe];                           // Start probe device
    self.let.controller.delegate = self;
    
    self.let.configParam.controllerSendCount = 2;
    self.let.configParam.controllerRepeatCount = 3;
    
    NSArray *storeDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    if (storeDevices && storeDevices.count > 0) {
        [self.let.controller addDeviceArray:storeDevices];
    }
    
    NSString *cliendId = @"35b305aeb7abf3ef3847011556045b6e";
    self.blOauth = [[BLOAuth alloc] initWithCliendId:cliendId];
}

- (BOOL)isDeviceHasBeenScaned:(BLDNADevice *)device {
    for (BLDNADevice *dev in self.scanDevices) {
        if ([dev.getDid isEqualToString:device.getDid]) {
            return YES;
        }
    }
    return NO;
}

- (void)handleOpenFromOtherApp:(NSURL *)url {
    NSString *urlString = url.absoluteString;
    NSLog(@"%@", urlString);
    
    __weak typeof(self) weakSelf = self;
    
    [self.blOauth HandleOpenURL:url completionHandler:^(BOOL status, BLOauthResult *result) {
        if ([result succeed]) {
            NSLog(@"accessToken=%@ expirationDate=%@", result.accessToken, result.expirationDate);
            
            [weakSelf.let.account loginWithIhcAccessToken:result.accessToken completionHandler:^(BLLoginResult * _Nonnull result) {
                if ([result succeed]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MainViewController *vc = [MainViewController viewController];
                        [((UINavigationController*)(weakSelf.window.rootViewController)) pushViewController:vc animated:YES];
                    });
                }
            }];
        }else{
            NSLog(@"error=%ld msg=%@", result.error, result.msg);
        }
    }];
}

#pragma mark - BLControllerDelegate
- (Boolean)shouldAdd:(BLDNADevice *)device {
    return NO;
}

- (void)onDeviceUpdate:(BLDNADevice *)device isNewDevice:(Boolean)isNewDevice {
    //Only device reset, newconfig=1
    //Not all device support this.
    //NSLog(@"=====probe device pid(%@) newconfig(%hhu)====", device.pid, device.newConfig);
    
    if (isNewDevice) { //Device did not add SDK
        if (![self isDeviceHasBeenScaned:device]) {
            //[device setLastStateRefreshTime:[NSDate timeIntervalSinceReferenceDate]];
            [self.scanDevices addObject:device];
        }
    } else { //Device has been added SDK
        
        
        if (device.newConfig) {
            //Update Device Info
            [[DeviceDB sharedOperateDB] updateSqlWithDevice:device];
        }
    }
}

- (void)statusChanged:(BLDNADevice *)device status:(BLDeviceStatusEnum)status {
    
}

#pragma mark - property
- (NSMutableArray *)scanDevices {
    if (!_scanDevices) {
        _scanDevices = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _scanDevices;
}


@end
