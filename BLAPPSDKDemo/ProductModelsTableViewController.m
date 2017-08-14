//
//  ProductModelsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//


#import "ProductModelsTableViewController.h"
#import "AppDelegate.h"
#import "RecoginzeIRCodeViewController.h"

@interface Brand ()
@property(nonatomic, readwrite, assign) NSInteger cateGoryId;
@end

@implementation Brand

- (instancetype)initWithDic: (NSDictionary *)dic {
    self = [super init];
    if (self) {
        _name = dic[@"brand"];
        _brandId = [dic[@"brandid"] integerValue];
        NSNumber *famous = dic[@"famousstatus"];
        _famous = [famous boolValue];
    }
    return self;
}

@end

@implementation Model

- (instancetype)initWithDic: (NSDictionary *)dic {
    self = [super init];
    if (self) {
        _name = dic[@"version"];
        _modelId = [dic[@"versionid"] integerValue];
    }
    return self;
}

@end

@implementation downloadInfo

- (instancetype)initWithDic: (NSDictionary *)dic {
    self = [super init];
    if (self) {
        _downloadUrl = dic[@"downloadurl"];
        _name = dic[@"name"];
        _randkey = dic[@"randkey"];
    }
    return self;
}

@end

@interface ProductModelsTableViewController ()
@property (nonatomic, strong) BLController *blcontroller;
@property(nonatomic, strong) NSArray *modelsArray;
@end

@implementation ProductModelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelsArray = [NSArray array];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    if (_devtype == BL_IRCODE_DEVICE_AC) {
        [self queryDeviceVersionWithTypeId:_devtype brandId:_cateGory.brandid];
    }else if (_devtype == BL_IRCODE_DEVICE_TV){
        [self queryIRCodeDownloadUrlWithTypeId:_devtype brandId:_cateGory.brandid versionId:0];
    }
    
}

- (void)queryDeviceVersionWithTypeId:(NSInteger)typeId brandId:(NSInteger)brandId {
    [self.blcontroller requestIRCodeDeviceVersionWithType:typeId brand:brandId completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            NSData *jsonData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *responseBodydic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&err];
            NSMutableArray *array = [NSMutableArray new];
            for (NSDictionary *pdic in responseBodydic[@"version"]) {
                Model *model = [[Model alloc] initWithDic: pdic];
                [array addObject: model];

            }
            _modelsArray = array;
            [self.tableView reloadData];

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
                
                NSMutableArray *array = [NSMutableArray new];
                for (NSDictionary *pdic in responseDic[@"downloadinfo"]) {
                    downloadInfo *model = [[downloadInfo alloc] initWithDic:pdic];
                    [array addObject: model];
                }
                _modelsArray = array;
                [self.tableView reloadData];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"SelectModelCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (_devtype == BL_IRCODE_DEVICE_AC) {
        _model = _modelsArray[indexPath.row];
        cell.textLabel.text = _model.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)_model.modelId];
    }else if (_devtype == BL_IRCODE_DEVICE_TV){
        _downloadinfo = _modelsArray[indexPath.row];
        cell.textLabel.text = _downloadinfo.name;
        cell.detailTextLabel.text = _downloadinfo.downloadUrl;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_devtype == BL_IRCODE_DEVICE_AC) {
        Model *model = _modelsArray[indexPath.row];
        model.brandId = _cateGory.brandid;
        model.devtype = _devtype;
        [self performSegueWithIdentifier:@"RecoginzeIRCodeView" sender:model];
    }else if (_devtype == BL_IRCODE_DEVICE_TV){
        downloadInfo *downloadinfo = _modelsArray[indexPath.row];
        downloadinfo.brandId = _cateGory.brandid;
        downloadinfo.devtype = _devtype;
        [self performSegueWithIdentifier:@"RecoginzeIRCodeView" sender:downloadinfo];
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RecoginzeIRCodeView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[RecoginzeIRCodeViewController class]]) {
            RecoginzeIRCodeViewController* opVC = (RecoginzeIRCodeViewController *)target;
            if (_devtype == BL_IRCODE_DEVICE_AC) {
                opVC.model = (Model *)sender;
            }else if (_devtype == BL_IRCODE_DEVICE_TV){
                opVC.downloadinfo = (downloadInfo *)sender;
            }
            
        }
    }
}
@end
