//
//  ProductModelsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//


#import "ProductModelsTableViewController.h"
#import "AppDelegate.h"
#import "ControlViewController.h"

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
    [self queryDeviceVersionWithTypeId:_devtype brandId:_cateGory.brandid];
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
    _model = _modelsArray[indexPath.row];
    cell.textLabel.text = _model.name;
    cell.detailTextLabel.text = @"Tap to download";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Model *model = _modelsArray[indexPath.row];
    model.brandId = _cateGory.brandid;
    [self performSegueWithIdentifier:@"controllerView" sender:model];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ControlViewController class]]) {
            ControlViewController* opVC = (ControlViewController *)target;
            opVC.model = (Model *)sender;
        }
    }
}
@end
