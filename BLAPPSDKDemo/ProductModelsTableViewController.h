//
//  ProductModelsTableViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CateGoriesTableViewController.h"
@interface Brand : NSObject
@property(nonatomic, readonly, strong) NSString *name;
@property(nonatomic, readonly, assign) NSInteger brandId;
@property(nonatomic, readonly, assign) NSInteger cateGoryId;
@property(nonatomic, readonly, assign) BOOL famous;
@end

@interface Model : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) NSInteger modelId;
@property(nonatomic, assign) NSInteger brandId;
@end


@class CateGory;
@interface ProductModelsTableViewController : UITableViewController
@property(nonatomic, strong) Model *model;
@property(nonatomic, strong) CateGory *cateGory;
@property(nonatomic, assign) NSInteger devtype;
@end
