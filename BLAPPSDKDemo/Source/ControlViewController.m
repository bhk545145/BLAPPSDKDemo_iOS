//
//  ControlViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "ControlViewController.h"
#import "AppDelegate.h"
@interface ControlViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) BLController *blcontroller;
@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UITextField *modeTextField;
@property (weak, nonatomic) IBOutlet UITextField *windSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *directionTextField;
@property (weak, nonatomic) IBOutlet UITextField *tempTextField;

@property (strong, nonatomic) UIPickerView *pickerView;
@end

@implementation ControlViewController
int tag = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    [self queryIRCodeDownloadUrlWithTypeId:_devtype brandId:_model.brandId versionId:_model.modelId];
    
//    [self queryACIRCodeData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryIRCodeDownloadUrlWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId versionId:(NSInteger)versionId {
    [self.blcontroller requestIRCodeScriptDownloadUrlWithType:typeId brand:brandId version:versionId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                NSArray *downloadInfos = [responseDic objectForKey:@"downloadinfo"];
                if (downloadInfos && downloadInfos.count > 0) {
                    self.downloadUrl = downloadInfos[0][@"downloadurl"];
                    self.randkey = downloadInfos[0][@"randkey"];
                    NSString *name = downloadInfos[0][@"name"];
                    self.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:name];
                    [self downloadIRCodeScript:self.downloadUrl savePath:self.savePath randkey:self.randkey];
                }
            }
        }
    }];
}

- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    [self.blcontroller downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"savepath:%@", result.savePath);
            [self queryIRCodeScriptInfo];
        }
    }];
}


- (void)queryIRCodeScriptInfo {
    BLIRCodeInfoResult *result = [self.blcontroller queryIRCodeInfomationWithScript:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"info:%@", result.infomation);
    }
}
- (IBAction)queryACIRCodeData:(id)sender {
    BLQueryIRCodeParams *params = [[BLQueryIRCodeParams alloc] init];
    params.temperature = 20;
    params.state = 1;
    params.speed = 2;
    params.mode = 1;
    params.direct = 1;
    
    BLIRCodeDataResult *result = [self.blcontroller queryACIRCodeDataWithScript:self.savePath randkey:nil params:params];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"data:%@", result.ircode);
    }
}


@end
