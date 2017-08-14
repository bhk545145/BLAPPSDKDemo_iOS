//
//  CreateFamilyViewController.h
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/7.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface CreateFamilyViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *familyNameField;
@property (weak, nonatomic) IBOutlet UIImageView *familyIconView;

- (IBAction)createBtnClick:(UIButton *)sender;

@end
