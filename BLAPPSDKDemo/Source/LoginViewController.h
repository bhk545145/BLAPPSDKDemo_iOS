//
//  LoginViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)registerButtonClick:(UIButton *)sender;
- (IBAction)loginButtonClick:(UIButton *)sender;
- (IBAction)loginWithoutNameButtonClick:(UIButton *)sender;

@end
