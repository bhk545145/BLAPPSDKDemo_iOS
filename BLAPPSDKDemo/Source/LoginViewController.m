//
//  LoginViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "LoginViewController.h"

#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import "BLLet.h"

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    self.userNameField.text = [userDefault getUserName];
    self.passwordField.text = [userDefault getPassword];
    
    __weak typeof(self) weakSelf = self;
    
    if ([userDefault getUserId] && [userDefault getSessionId]) {
        BLAccount *account = [BLLet sharedLet].account;
        NSDate *date = [NSDate date];
        NSLog(@"-----Start time: %f", date.timeIntervalSinceNow);
        [account localLoginWithUsrid:[userDefault getUserId] session:[userDefault getSessionId] completionHandler:^(BLLoginResult * _Nonnull result) {
            NSLog(@"-----Block time: %f", date.timeIntervalSinceNow);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf performSegueWithIdentifier:@"MainView" sender:nil];
            });
        }];
        NSLog(@"-----End time: %f", date.timeIntervalSinceNow);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButtonClick:(UIButton *)sender {
    [self performSegueWithIdentifier:@"RegisterView" sender:nil];
}

- (IBAction)loginButtonClick:(UIButton *)sender {
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    BLAccount *account = [BLLet sharedLet].account;
    __weak typeof(self) weakSelf = self;
    [self showIndicatorOnWindowWithMessage:@"Logging..."];
    [account login:userName password:password completionHandler:^(BLLoginResult * _Nonnull result) {

        if ([result succeed]) {
            BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
            [userDefault setUserName:userName];
            [userDefault setPassword:password];
            [userDefault setUserId:[result getUserid]];
            [userDefault setSessionId:[result getLoginsession]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
                [weakSelf performSegueWithIdentifier:@"MainView" sender:nil];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            });
        }
    }];
    
}

- (IBAction)loginWithoutNameButtonClick:(UIButton *)sender {
    NSString *thirdID = @"123456789";
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    BLAccount *account = [BLLet sharedLet].account;
    __weak typeof(self) weakSelf = self;
    [self showIndicatorOnWindowWithMessage:@"Logging..."];
    [account thirdAuth:thirdID completionHandler:^(BLLoginResult * _Nonnull result) {
        
        if ([result succeed]) {
            BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
            [userDefault setUserId:[result getUserid]];
            [userDefault setSessionId:[result getLoginsession]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
                [weakSelf performSegueWithIdentifier:@"MainView" sender:nil];
            });
        } else {
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
