//
//  CreateFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/7.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CreateFamilyViewController.h"
#import "AppDelegate.h"


@interface CreateFamilyViewController ()

@end

@implementation CreateFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createBtnClick:(UIButton *)sender {
    NSLog(@"create family");
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLFamilyController *manager = delegate.let.familyManager;
    BLFamilyInfo *familyInfo = [[BLFamilyInfo alloc] init];
    
    familyInfo.familyName = @"MyHome";
    familyInfo.familyDescription = @"LALA";
    familyInfo.familyLimit = 2;
    familyInfo.familyLongitude = 0;
    familyInfo.familyLatitude = 0;
    
    [manager createNewFamilyWithInfo:familyInfo iconImage:nil completionHandler:^(BLFamilyInfoResult * _Nonnull result) {
        if ([result succeed]) {
            NSLog(@"familyID:%@ version:%@ Name:%@ Description:%@", result.familyInfo.familyId, result.familyInfo.familyVersion, result.familyInfo.familyName, result.familyInfo.familyDescription);
        } else {
            NSLog(@"ERROR :%@", result.msg);
        }
    }];
}
@end
