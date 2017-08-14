//
//  FamilyDetailViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyDetailViewController.h"

@interface FamilyDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *familyIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyIconPathLabel;

@property (weak, nonatomic) IBOutlet UITableView *roomsTable;
@property (weak, nonatomic) IBOutlet UITableView *moduleTable;

@end

@implementation FamilyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.familyIdLabel.text = self.familyAllInfo.familyBaseInfo.familyId;
    self.familyVersionLabel.text = self.familyAllInfo.familyBaseInfo.familyVersion;
    self.familyNameLabel.text = self.familyAllInfo.familyBaseInfo.familyName;
    self.familyIconPathLabel.text = self.familyAllInfo.familyBaseInfo.familyIconPath;
    
    self.roomsTable.delegate = self;
    self.roomsTable.dataSource = self;
    
    self.moduleTable.delegate = self;
    self.moduleTable.dataSource = self;
    
    UIBarButtonItem *rButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addModule)];
    [self.navigationItem setRightBarButtonItem:rButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)addModule {
//    BLFamilyDeviceInfo *deviceInfo = [[BLFamilyDeviceInfo alloc] init];
//    deviceInfo.familyId = self.familyAllInfo.familyBaseInfo.familyId;
//    deviceInfo.did = @"00000000000000000000b4430d120af6";
//    deviceInfo.mac = @"b4:43:0d:12:0a:f6";
//    deviceInfo.pid = @"0000000000000000000000000794f0000";
//    deviceInfo.name = @"tcl净水器qwe";
//    deviceInfo.password = 66032949;
//    deviceInfo.type = 20345;
//    deviceInfo.aesKey = @"";
//    deviceInfo.terminalId = 1;
//    
//    BLModuleInfo *module = [[BLModuleInfo alloc] init];
//    module.familyId = self.familyAllInfo.familyBaseInfo.familyId;
//    module.name = @"tcl净水器qwe";
//    module.order = 1;
//    module.flag = 1;
//    module.moduleType = 1;
//    module.followDev = 1;
//    module.moduleDevs = @[@{
//                              @"did":deviceInfo.did,
//                              @"sdid":@"",
//                              @"order":@(1),
//                              @"content":@""
//                              }];
//
//    BLLet *let = [BLLet sharedLet];
//    BLFamilyController *familyController = let.familyManager;
//    
//    [familyController addModule:module toFamily:self.familyAllInfo.familyBaseInfo withDevice:deviceInfo subDevice:nil completionHandler:^(BLModuleControlResult * _Nonnull result) {
//        if ([result succeed]) {
//            NSLog(@"success:%ld Msg:%@", (long)result.error, result.msg);
//        } else {
//            NSLog(@"error:%ld Msg:%@", (long)result.error, result.msg);
//        }
//    }];
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 501) {
        return self.familyAllInfo.roomBaseInfoArray.count;
    } else {
        return self.familyAllInfo.moduleBaseInfo.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 501) {
        static NSString* cellIdentifier = @"ROOM_TABLE_CELL";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = self.familyAllInfo.roomBaseInfoArray[indexPath.row].name;
        
        return cell;
    } else {
        static NSString* cellIdentifier = @"MODULE_TABLE_CELL";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = self.familyAllInfo.moduleBaseInfo[indexPath.row].name;
        
        return cell;
    }
}


@end
