//
//  CateGoriesTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CateGory : NSObject
@property(nonatomic, assign) NSInteger brandid;
@property(nonatomic, strong) NSString *brand;
@end

@interface CateGoriesTableViewController : UITableViewController
@property(nonatomic, assign) NSInteger devtype;
@end
