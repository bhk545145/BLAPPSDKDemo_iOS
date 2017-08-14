//
//  IRCodeTestViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/24.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "IRCodeTestViewController.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"
#import "CateGoriesTableViewController.h"

@interface IRCodeTestViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *testTableView;
@property (nonatomic, strong) NSArray *testList;
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) NSString *ircodeString;

@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *randkey;
@property (nonatomic, strong) NSString *savePath;

@property (nonatomic, assign) NSUInteger locateid;
@property (nonatomic, assign) NSUInteger isleaf;
@property (nonatomic, assign) NSUInteger providerid;
@property(nonatomic, assign) NSInteger devtype;
@end

@implementation IRCodeTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.testList = @[@"Recognize IRCode",
                      @"AC IRCode",
                      @"TV IRCode",
                      @"STB IRCode"];
    
    self.locateid = 0;
    self.providerid = 0;
    self.isleaf = 0;
    
    self.ircodeString = @"2600ca008d950c3b0f1410380e3a0d160e160d3b0d150e150e3910150d160d3a0f36101411380d150f3a0e390d3910370f150f38103a0d3a0e1211140f1411121038101310150f3710380e390e150f160d160e1410140f131113101310380e3b0f351137123611ad8e9210370f1511370e390f140f1410380f1311130f39101211130f390f380f150f390f1310380f3810380f380f141038103710380f1411121014101310380f14101310380f3810381013101311121014101211131014101310370f3910361138103710000d05";
    
    self.testTableView.delegate = self;
    self.testTableView.dataSource = self;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"IRCODETESTCELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.testList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
//            [self queryDeviceVersionWithTypeId:BL_IRCODE_DEVICE_TV brandId:5];
            [self queryIRCodeDownloadUrlWithTypeId:BL_IRCODE_DEVICE_TV brandId:5 versionId:0];
            break;
        case 1:
            _devtype = BL_IRCODE_DEVICE_AC;
            [self performSegueWithIdentifier:@"CateGoriesTableView" sender:nil];
            break;
        case 2:
            _devtype = BL_IRCODE_DEVICE_TV;
            [self performSegueWithIdentifier:@"CateGoriesTableView" sender:nil];
            break;
        case 3:
            _devtype = BL_IRCODE_DEVICE_TV_BOX;
            [self performSegueWithIdentifier:@"CateGoriesTableView" sender:nil];
            break;
        default:
            break;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CateGoriesTableView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[CateGoriesTableViewController class]]) {
            CateGoriesTableViewController* opVC = (CateGoriesTableViewController *)target;
            opVC.devtype = _devtype;
        }
    }
}

#pragma mark - 
- (void)queryDeviceVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    [self.blcontroller requestIRCodeDeviceVersionWithType:typeId brand:brandId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
        }
    }];
}

- (void)querySubAreaLocateid {
    if (self.isleaf != 1) {
        [self.blcontroller requestSubAreaWithLocateid:self.locateid completionHandler:^(BLBaseBodyResult * _Nonnull result) {
            NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
            if ([result succeed]) {
                NSLog(@"response:%@", result.responseBody);
                NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:[result.responseBody dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSArray *subareainfos = [resp objectForKey:@"subareainfo"];
                if (subareainfos && subareainfos.count > 0) {
                    NSDictionary *subareainfo = subareainfos[0];
                    self.locateid = [subareainfo[@"locateid"] unsignedIntegerValue];
                    self.isleaf = [subareainfo[@"isleaf"] unsignedIntegerValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Now locateid=%ld isleaf=%ld", self.locateid, self.isleaf]];
                    });
                }
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Now locateid=%ld isleaf=%ld don't need request again!", self.locateid, self.isleaf]];
        });
    }

}

- (void)querySTBProvider {
    [self.blcontroller requestSTBProviderWithLocateid:self.locateid completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:[result.responseBody dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSArray *providerinfos = [resp objectForKey:@"providerinfo"];
            
            if (providerinfos && providerinfos.count > 0) {
                NSDictionary *providerinfo = providerinfos.firstObject;
                self.providerid = [providerinfo[@"providerid"] unsignedIntegerValue];
                NSString *providerName = providerinfo[@"providername"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Now providerid=%ld name=%@", self.providerid, providerName]];
                });
            }
        }
    }];
}

- (void)querySTBIRCodeDownloadUrl {
    [self.blcontroller requestSTBIRCodeScriptDownloadUrlWithLocateid:self.locateid providerid:self.providerid completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:[result.responseBody dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSArray *downloadInfos = [resp objectForKey:@"downloadinfo"];
            if (downloadInfos && downloadInfos.count > 0) {
                self.downloadUrl = downloadInfos[0][@"downloadurl"];
                self.randkey = downloadInfos[0][@"randkey"];
                NSString *name = downloadInfos[0][@"name"];
                self.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:name];
            }
        }
    }];
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
                }
            }
        }
    }];
}

- (void)queryIRCodeDownloadWithIRCodeDataString:(NSString *)codeString {
    [self.blcontroller recognizeIRCodeWithHexString:codeString completionHandler:^(BLBaseBodyResult * _Nonnull result) {
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
                }
            }
        }
    }];
}

- (void)downloadIRCodeScript {
    [self.blcontroller downloadIRCodeScriptWithUrl:self.downloadUrl savePath:self.savePath randkey:self.randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"savepath:%@", result.savePath);
        }
    }];
}

- (void)queryIRCodeScriptInfo {
    BLIRCodeInfoResult *result = [self.blcontroller queryIRCodeInfomationWithScript:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_TV_BOX];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"info:%@", result.infomation);
    }
}

- (void)queryACIRCodeData {
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

- (void)queryTVIRCodeData {
    
    NSString *funcname = @"power";
    BLIRCodeDataResult *result = [self.blcontroller queryTVIRCodeDataWithScript:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_TV_BOX funcname:funcname];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"data:%@", result.ircode);
    }
    
}


@end
