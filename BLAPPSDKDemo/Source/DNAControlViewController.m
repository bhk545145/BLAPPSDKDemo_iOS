//
//  DNAControlViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DNAControlViewController.h"
#import "AppDelegate.h"

@interface DNAControlViewController ()<UITextFieldDelegate>

@end

@implementation DNAControlViewController {
    BLController *_blController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    
    _valInputTextField.delegate = self;
    _paramInputTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self testDnaControl];
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 101) {
        NSString *param = _paramInputTextField.text;
        NSString *action = @"get";
        
        [self dnaControlWithAction:action param:param val:nil];
    } else if (sender.tag == 102) {
        NSString *val = _valInputTextField.text;
        NSString *param = _paramInputTextField.text;
        NSString *action = @"set";
        
        [self dnaControlWithAction:action param:param val:val];
    } else if (sender.tag == 103) {
        [self queryTaskList];
    } else if (sender.tag == 104) {
        [self setTask];
    } else if (sender.tag == 105) {
        [self getDeviceProfile];
    }
}

- (void)testDnaControl {
    NSString *action = @"set";
    NSString *param = @"pwr";
    NSString *val;
    NSUInteger failedCount = 0;
    NSDate *date = [NSDate date];
    
    for (int i = 0; i < 2000; i++) {
        val = (i % 2 == 0) ? @"1" : @"0";
        
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setValue:val forParam:param];
        
        BLStdControlResult *result = [_blController dnaControl:self.device.did stdData:stdData action:action];
        if (![result succeed]) {
            failedCount++;
        }
        NSLog(@"====UDP_TEST====Did:%@ Type:%ld getError:%ld getMsg:%@ sendCount:%d failed:%lu",
              self.device.did, self.device.type, (long)result.error, result.msg, i, (unsigned long)failedCount);
        usleep(50 * 1000);
    }
    NSLog(@"====UDP_TEST====Over spend time : %f", [date timeIntervalSinceNow]);
    
}

- (void)dnaControlWithAction:(NSString *)action param:(NSString *)param val:(NSString *)val {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:val forParam:param];
    
    BLStdControlResult *result = [_blController dnaControl:[_device getDid] stdData:stdData action:action];
    
    if ([result succeed]) {
        NSDictionary *dic = [[result getData] toDictionary];
        
        NSString *resultString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        _resultTextView.text = resultString;
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    
    BLPicker *picker = [BLLet sharedLet].picker;

    [picker trackErrorWithErrorNo:result.error msg:result.msg function:[NSString stringWithUTF8String:__FUNCTION__] externData:nil];
    
}

- (void)getDeviceProfile {
    NSArray *temp = @[@(1), @(2)];
    NSLog(@"Crash test %@", temp[3]);
    
    BLProfileStringResult *result = [_blController queryProfile:[_device getDid]];
    if ([result succeed]) {
        _resultTextView.text = [result getProfile];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)queryTaskList {
    BLQueryTaskResult *result = [_blController queryTask:[_device getDid]];
    if ([result succeed]) {
        NSArray *timeTask = [result getTimer];
        NSArray *PeriodTask = [result getPeriod];
        _resultTextView.text = [NSString stringWithFormat:@"timeTask:%ld  PeriodTask:%ld", (unsigned long)timeTask.count, (unsigned long)PeriodTask.count];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)setTask {
    BLTimerInfo *timerInfo = [[BLTimerInfo alloc] init];
    [timerInfo setIndex:1];
    [timerInfo setEnable:YES];
    [timerInfo setYear:2017];
    [timerInfo setMonth:10];
    [timerInfo setDay:1];
    [timerInfo setHour:10];
    [timerInfo setMinute:0];
    [timerInfo setSeconds:0];
    
    BLStdData *stdData = [[BLStdData alloc] init];
    NSString *val = @"1";
    NSString *param = @"pwr";
    [stdData setValue:val forParam:param];
    
    BLQueryTaskResult *result = [_blController addTimerTask:[_device getDid] timerInfo:timerInfo stdData:stdData];
    if ([result succeed]) {
        NSArray *timeTask = [result getTimer];
        _resultTextView.text = [NSString stringWithFormat:@"timeTask:%ld", (unsigned long)timeTask.count];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}


@end
