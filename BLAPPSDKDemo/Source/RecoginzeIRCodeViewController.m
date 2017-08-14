//
//  RecoginzeIRCodeViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/14.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RecoginzeIRCodeViewController.h"
#import "AppDelegate.h"
#import "ControlViewController.h"

@interface RecoginzeIRCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ResultTxt;
@property (nonatomic, strong) BLController *blcontroller;
@end

@implementation RecoginzeIRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downLoadIRCodeScript:(id)sender {
    if (_model.devtype == BL_IRCODE_DEVICE_AC) {
        [self queryIRCodeDownloadUrlWithTypeId:_model.devtype brandId:_model.brandId versionId:_model.modelId];
    }else if (_downloadinfo.devtype == BL_IRCODE_DEVICE_TV){
        self.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:_downloadinfo.name];
        [self downloadIRCodeScript:_downloadinfo.downloadUrl savePath:self.savePath randkey:self.randkey];
    }
    
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    if (_model.devtype == BL_IRCODE_DEVICE_AC) {
        [self queryIRCodeScriptInfoSavePath:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
    }else if (_downloadinfo.devtype == BL_IRCODE_DEVICE_TV){
        [self queryIRCodeScriptInfoSavePath:self.savePath randkey:_downloadinfo.randkey deviceType:BL_IRCODE_DEVICE_TV];
    }
}

- (IBAction)getIRCodeData:(id)sender {
    [self performSegueWithIdentifier:@"controllerView" sender:self.savePath];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                _ResultTxt.text = result.savePath;
            });
            
        }
    }];
}

- (void)queryIRCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    BLIRCodeInfoResult *result = [self.blcontroller queryIRCodeInfomationWithScript:savePath randkey:randkey deviceType:devicetype];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"info:%@", result.infomation);
        dispatch_async(dispatch_get_main_queue(), ^{
            _ResultTxt.text = result.infomation;
        });
        
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ControlViewController class]]) {
            ControlViewController* opVC = (ControlViewController *)target;
            opVC.savePath = (NSString *)sender;
        }
    }
}


@end
