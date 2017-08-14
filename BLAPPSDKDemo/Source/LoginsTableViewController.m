//
//  LoginsTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "LoginsTableViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
#import "BLLet.h"

@interface LoginsTableViewController (){
    NSArray *_listArray;
}

@end

@implementation LoginsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listArray = @[@"passwordLogin",@"CodeLogin",@"OauthLogin"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"Login_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = _listArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"passwordLogin" sender:nil];
    }else if(indexPath.row == 1){
        [self performSegueWithIdentifier:@"codeLogin" sender:nil];
    }else if (indexPath.row == 2){
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        BLOAuth *blOauth = delegate.blOauth;
        [blOauth authorize:nil];
    }
}
@end
