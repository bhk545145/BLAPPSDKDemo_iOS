//
//  CateGoriesTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CateGoriesTableViewController.h"
#import "AppDelegate.h"
#import "ProductModelsTableViewController.h"



@implementation CateGory
- (instancetype)initWithDic: (NSDictionary *)dic {
    self = [super init];
    if (self) {
        _brandid = [dic[@"brandid"] integerValue];
        _brand = dic[@"brand"];
    }
    return self;
}

@end

@interface CateGoriesTableViewController ()
@property (nonatomic, strong) BLController *blcontroller;
@property(nonatomic, strong) NSArray<CateGory *> *categories;
@end

@implementation CateGoriesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    [self queryDeviceTypes];
    _categories = [NSArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDevtype:(NSInteger)devtype{
    _devtype = devtype;
}

- (void)queryDeviceTypes {
    if (_devtype == BL_IRCODE_DEVICE_AC || _devtype == BL_IRCODE_DEVICE_TV) {
        [self.blcontroller requestIRCodeDeviceBrandsWithType:_devtype completionHandler:^(BLBaseBodyResult * _Nonnull result) {
            NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
            if ([result succeed]) {
                NSLog(@"response:%@", result.responseBody);
                NSData *jsonData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *responseBodydic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:&err];
                NSMutableArray *array = [NSMutableArray new];
                for (NSDictionary *dic in responseBodydic[@"brand"]) {
                    [array addObject: [[CateGory alloc] initWithDic:dic]];
                }
                _categories = array;
                [self.tableView reloadData];
                
            }
        }];
    }else if(_devtype == BL_IRCODE_DEVICE_TV_BOX){
        
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"listCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    CateGory *cateGory = _categories[indexPath.row];
    cell.textLabel.text = cateGory.brand;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CateGory *cateGory = _categories[indexPath.row];
    [self performSegueWithIdentifier:@"ProductModelsView" sender:cateGory];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProductModelsView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ProductModelsTableViewController class]]) {
            ProductModelsTableViewController* opVC = (ProductModelsTableViewController *)target;
            opVC.cateGory = (CateGory *)sender;
            opVC.devtype = _devtype;
        }
    }
}
@end
