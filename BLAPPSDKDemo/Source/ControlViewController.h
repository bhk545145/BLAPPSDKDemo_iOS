//
//  ControlViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModelsTableViewController.h"
@class Model;
@interface ControlViewController : UIViewController
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *randkey;
@property (nonatomic, strong) NSString *savePath;
@property (nonatomic, strong) Model *model;
@property(nonatomic, assign) NSInteger devtype;
@end
