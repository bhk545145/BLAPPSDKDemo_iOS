//
//  OperateViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//
#import <sys/sysctl.h>
#import <netinet/in.h>
#import <net/if.h>
#import <netdb.h>
#import <sys/socket.h>
#import <arpa/inet.h>

#import "OperateViewController.h"
#import "DataPassthoughViewController.h"
#import "DNAControlViewController.h"
#import "DeviceWebControlViewController.h"

#import "BLStatusBar.h"
#import "AppDelegate.h"
#import "AppMacro.h"
#import "SSZipArchive.h"
#import "SPViewController.h"
#import "RMViewController.h"
@interface OperateViewController ()

@property (nonatomic, weak)NSTimer *stateTimer;

@end

@implementation OperateViewController {
    BLController *_blController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    
    UILabel *nameLabel = (UILabel *)[self.view viewWithTag:101];
    nameLabel.text = [nameLabel.text stringByAppendingString:[_device getName]];
    
    UILabel *didLabel = (UILabel *)[self.view viewWithTag:102];
    didLabel.text = [didLabel.text stringByAppendingString:[_device getDid]];
    
    UILabel *pidLabel = (UILabel *)[self.view viewWithTag:103];
    pidLabel.text = [pidLabel.text stringByAppendingString:[_device getPid]];
    
    UILabel *macLabel = (UILabel *)[self.view viewWithTag:104];
    macLabel.text = [macLabel.text stringByAppendingString:[_device getMac]];
    
    UILabel *netstateLabel = (UILabel *)[self.view viewWithTag:105];
    netstateLabel.text = [netstateLabel.text stringByAppendingString:@"Getting..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self copyCordovaJsToUIPathWithFileName:DNAKIT_CORVODA_JS_FILE];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    if (![_stateTimer isValid]) {
        __weak typeof(self) weakSelf = self;
        _stateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf networkState];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([_stateTimer isValid]) {
        [_stateTimer invalidate];
        _stateTimer = nil;
    }
}

- (IBAction)operateButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 201:
            [self getScriptVersion];
            break;
        case 202:
            [self downloadScript];
            break;
        case 203:
            [self getUIVersion];
            break;
        case 204:
            [self downloadUI];
            break;
        case 205:
            [self getFirmwareVersion];
            break;
        case 206:
            [self bindDeviceToServer];
            break;
        case 207:
            [self dataPassthough];
            break;
        case 208:
            [self dnaControl];
            break;
        case 209:
            [self webViewControl];
            break;
        case 210:
            [self getServerTime];
        default:
            break;
    }
}

#pragma mark - private method
- (void)networkState {
    BLDeviceStatusEnum state = [_blController queryDeviceState:[_device getDid]];
    NSString *stateString = @"State UnKown";
    switch (state) {
        case BL_DEVICE_STATE_LAN:
            stateString = @"LAN";
            break;
        case BL_DEVICE_STATE_REMOTE:
            stateString = @"REMOTE";
            break;
        case BL_DEVICE_STATE_OFFLINE:
            stateString = @"OFFLINE";
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *netstateLabel = (UILabel *)[self.view viewWithTag:105];
        netstateLabel.text = [NSString stringWithFormat:@"NetState:%@", stateString];
    });
}

- (void)getScriptVersion {
    BLQueryResourceVersionResult *result = [_blController queryScriptVersion:[self.device getPid]];
    if ([result succeed]) {
        BLResourceVersion *version = [result.versions firstObject];
        _resultText.text = [NSString stringWithFormat:@"Script Pid:%@\n Version:%@", version.pid, version.version];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)getUIVersion {
    BLQueryResourceVersionResult *result = [_blController queryUIVersion:[self.device getPid]];
    if ([result succeed]) {
        BLResourceVersion *version = [result.versions firstObject];
        _resultText.text = [NSString stringWithFormat:@"UI Pid:%@\n Version:%@", version.pid, version.version];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)downloadScript {
    [self showIndicatorOnWindowWithMessage:@"Script Downloading..."];
    NSLog(@"Start downloadScript");
    [_blController downloadScript:[self.device getPid] completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"End downloadScript");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                _resultText.text = [NSString stringWithFormat:@"ScriptPath:%@", [result getSavePath]];
            } else {
                _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            }
        });
    }];
}

- (void)downloadUI {
    NSString *unzipPath = [_blController queryUIPath:[_device getPid]];
    [self showIndicatorOnWindowWithMessage:@"UI Downloading..."];
    NSLog(@"Start downloadUI");
    [_blController downloadUI:[self.device getPid] completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"End downloadUI");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });
        
        if ([result succeed]) {
            BOOL isUnzip = [SSZipArchive unzipFileAtPath:[result getSavePath] toDestination:unzipPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _resultText.text = [NSString stringWithFormat:@"isUnzip:%d \nDownload File:%@ \nUIPath:%@", isUnzip, [result getSavePath], unzipPath];
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            });
        }
        NSLog(@"End downloadUI zip");
    }];
}

- (void)getFirmwareVersion {
    BLFirmwareVersionResult *result = [_blController queryFirmwareVersion:[_device getDid]];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"Firmware Version:%@", [result getVersion]];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)upgradeFirmVersion {
    //Get URL From Servers
}

- (void)bindDeviceToServer {
    BLBindDeviceResult *result = [_blController bindDeviceWithServer:_device];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"BindMap : %@", [result getBindmap]];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)dataPassthough {
    [self performSegueWithIdentifier:@"DataPassthoughView" sender:nil];
}

- (void)dnaControl {
    NSString *profileFile = [_blController queryScriptFileName:[self.device getPid]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:profileFile]) {
        [BLStatusBar showTipMessageWithStatus:@"Please download script first!"];
        return;
    }
    
    if([self.device.pid isEqualToString:SPmini3] || [self.device.pid isEqualToString:SPmini]){
        [self performSegueWithIdentifier:@"SPminiControlView" sender:nil];
    }else if ([self.device.pid isEqualToString:RMmini3]|| [self.device.pid isEqualToString:RMpro]){
        [self performSegueWithIdentifier:@"RMminiControlView" sender:nil];
    }else{
        [self performSegueWithIdentifier:@"DNAControlView" sender:nil];
    }
    
    
}

- (void)webViewControl {
    if ([self copyCordovaJsToUIPathWithFileName:DNAKIT_CORVODA_JS_FILE] ) {
        [self performSegueWithIdentifier:@"DeviceWebControlView" sender:nil];
    }
}

- (void)getServerTime {
    BLDeviceTimeResult *result = [_blController queryDeviceTime:self.device.did];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"Time:%@ diff:%ld", result.time, result.difftime];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DataPassthoughView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[DataPassthoughViewController class]]) {
            DataPassthoughViewController* vc = (DataPassthoughViewController *)target;
            vc.device = _device;
        }
    } else if ([segue.identifier isEqualToString:@"DNAControlView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[DNAControlViewController class]]) {
            DNAControlViewController* vc = (DNAControlViewController *)target;
            vc.device = _device;
        }
    } else if ([segue.identifier isEqualToString:@"DeviceWebControlView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[DeviceWebControlViewController class]]) {
            DeviceWebControlViewController* vc = (DeviceWebControlViewController *)target;
            vc.selectDevice = _device;
        }
    } else if ([segue.identifier isEqualToString:@"SPminiControlView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[SPViewController class]]) {
            SPViewController* vc = (SPViewController *)target;
            vc.device = _device;
        }
    }else if ([segue.identifier isEqualToString:@"RMminiControlView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[RMViewController class]]) {
            RMViewController* vc = (RMViewController *)target;
            vc.device = _device;
        }
    }
}

- (BOOL)copyCordovaJsToUIPathWithFileName:(NSString*)fileName {
    NSString *uiPath = [[_blController queryUIPath:[_device getPid]] stringByDeletingLastPathComponent];  //  ../Let/ui/
    NSString *fullPathFileName = [uiPath stringByAppendingPathComponent:fileName];  // ../Let/ui/fileName
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPathFileName] == NO) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil inDirectory:@"www"];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:path toPath:fullPathFileName error:&error];
        if (success) {
            NSLog(@"%@ copy success",fileName);
            return YES;
        } else {
            NSLog(@"%@ copy failed",fileName);
            return NO;
        }
    }
    
    return YES;
}

@end
