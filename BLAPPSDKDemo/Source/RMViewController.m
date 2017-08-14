//
//  RMViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/1.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RMViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
@interface RMViewController (){
    BLController *_blController;
    NSString *_irdaCodeStr;
}
@property (weak, nonatomic) IBOutlet UILabel *IrdaCode;

@end

@implementation RMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    [_IrdaCode sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)learnButton:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irdastudy"];
    BLStdControlResult *studyResult = [_blController dnaControl:[_device getDid] stdData:stdData action:@"get"];
    if ([studyResult succeed]) {
        _IrdaCode.text = @"进入学习状态";
    }
}


- (IBAction)GetIrdaCode:(id)sender {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irda"];
    BLStdControlResult *irdaResult = [_blController dnaControl:[_device getDid] stdData:stdData action:@"get"];
    NSDictionary *dic = [[irdaResult getData] toDictionary];
    _irdaCodeStr = dic[@"vals"][0][0][@"val"];
    _IrdaCode.text = _irdaCodeStr;
}


- (IBAction)SendIrdaCode:(id)sender {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:_irdaCodeStr forParam:@"irda"];
    BLStdControlResult *sendResult = [_blController dnaControl:[_device getDid] stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        _IrdaCode.text = @"红码发射成功";
    }
}

- (IBAction)TimerBtn:(id)sender {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@"0|1|19|30|1|打开电视|2|32:100@64:500|2600f000636463911312150f1510150f153415331534150f15341632143514351410170e160e1533151015331510150f1534150f15341533150f150f160f150f1633153415331632160f150f160f150f15341533163315331534150f1534150f160f1533160f1533150f160f150f150f1633153415331633150004fc6562658e160f150f160f150f153415331633150f1534153415331534150f160f150f153315101533160f150f1534150f15341533150f160f150f150f1633153415341533150f150f160f150f15341533163315331633150f1633150f160f1533160f1533150f160f150f1510153315341534153315000d050000000000000000" forParam:@"rmtimer"];
    BLStdControlResult *sendResult = [_blController dnaControl:[_device getDid] stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setValue:nil forParam:@"rmtimer"];
        BLStdControlResult *sendResult = [_blController dnaControl:[_device getDid] stdData:stdData action:@"get"];
        _IrdaCode.text = [NSString stringWithFormat:@"%@",[[sendResult getData] toDictionary][@"vals"][0]];
    }
}
@end
