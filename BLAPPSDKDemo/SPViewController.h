//
//  SPViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BLDNADevice.h"
@interface SPViewController : BaseViewController
@property (nonatomic, strong) BLDNADevice *device;
@property (weak, nonatomic) IBOutlet UIButton *SPswitchtxt;
@end
