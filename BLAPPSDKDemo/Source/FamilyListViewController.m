//
//  FamilyListViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/6.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyListViewController.h"
#import "FamilyDetailViewController.h"
#import "AppDelegate.h"

@interface FamilyListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSArray<BLFamilyIdInfo *> *familyIds;

@end

@implementation FamilyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.familyListTableView.delegate = self;
    self.familyListTableView.dataSource = self;
    [self setExtraCellLineHidden:self.familyListTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryFamilyIdListInAccount];
}

#pragma mark - tabel delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.familyIds.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"FAMILY_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.familyIds[indexPath.row].familyId;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *familyId = self.familyIds[indexPath.row].familyId;
    NSArray *idlist = @[familyId];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLFamilyController *manager = delegate.let.familyManager;
    
    [manager queryFamilyInfoWithIds:idlist completionHandler:^(BLAllFamilyInfoResult * _Nonnull result) {
        if ([result succeed]) {
            BLFamilyAllInfo *familyAllInfo = result.allFamilyInfoArray.firstObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"FamilyDetailView" sender:familyAllInfo];
            });
            
        } else {
            NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
        }
    }];
}

#pragma mark - private method
- (void)queryFamilyIdListInAccount {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLFamilyController *manager = delegate.let.familyManager;
    
    [manager queryLoginUserFamilyIdListWithCompletionHandler:^(BLFamilyIdListGetResult * _Nonnull result) {
        if ([result succeed]) {
            self.familyIds = result.idList;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.familyListTableView reloadData];
            });
            
        } else {
            NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
        }
    }];
}

- (IBAction)addFamilyBtnClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"CreateFamilyView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FamilyDetailView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[FamilyDetailViewController class]]) {
            FamilyDetailViewController* vc = (FamilyDetailViewController *)target;
            vc.familyAllInfo = (BLFamilyAllInfo *)sender;
        }
    }
}


@end
