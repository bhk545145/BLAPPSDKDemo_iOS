//
//  CodeLoginViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CodeLoginViewController.h"

#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import "BLLet.h"

@interface CodeLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumtxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordtxt;

@end

@implementation CodeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNumtxt.delegate = self;
    self.passwordtxt.delegate = self;
    
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    self.phoneNumtxt.text = [userDefault getUserName];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getCodebtn:(id)sender {
    BLAccount *account = [BLLet sharedLet].account;
    [account sendFastVCode:self.phoneNumtxt.text countryCode:@"0086" completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }];
}

- (IBAction)codeLoginbtn:(id)sender {
    [self.phoneNumtxt resignFirstResponder];
    [self.passwordtxt resignFirstResponder];
    
    BLAccount *account = [BLLet sharedLet].account;
    __weak typeof(self) weakSelf = self;
    [self showIndicatorOnWindowWithMessage:@"Logging..."];
    [account fastLoginWithPhoneOrEmail:self.phoneNumtxt.text countrycode:@"0086" vcode:self.passwordtxt.text completionHandler:^(BLLoginResult * _Nonnull result) {
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
                [weakSelf performSegueWithIdentifier:@"CodeMainView" sender:nil];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            });
        }
    }];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
