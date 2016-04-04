//
//  NearStationListViewController.m
//  MetroSurround
//
//  Created by as on 2015/07/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "NearStationListViewController.h"
#import "NearStationListViewCell.h"
#import "MetroRailwayMasterManager.h"
#import "MapStationDetailViewController.h"

@interface NearStationListViewController ()

@end

@implementation NearStationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NearStationListCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.alpha = 1;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    NSString *titleName = @"最寄り駅一覧";
    
    //同じ駅が複数ある場合
    if(self.isSameStation){
        titleName = [NSString stringWithFormat:@"%@駅（路線別）",self.stationName];
    }
    
    self.navigationItem.title = titleName;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.nearList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NearStationListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *stationName = self.nearList[indexPath.row][@"stationName"];
    NSString *stationEnName = self.nearList[indexPath.row][@"stationId"];
    NSString *distance = [NSString stringWithFormat:@"およそ%@m先",self.nearList[indexPath.row][@"distance"]];
    
    cell.stationNameText.text = stationName;
    cell.stationEnNameText.text = stationEnName;
    cell.distanceLabel.text = distance;
    
    int railwayId = [self.nearList[indexPath.row][@"railwayId"] intValue];
    
    cell.numberingMark.image = [cell.numberingMark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.numberingMark.tintColor = [[MetroRailwayMasterManager sharedManager ] getColorCode:railwayId alphaValue:1];
    
    //IOS8以上なら
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        cell.preservesSuperviewLayoutMargins = false;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    MapStationDetailViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"MapStationDetailViewController"];
    
    vc.stationId = self.nearList[indexPath.row][@"stationId"];
    vc.stationName = self.nearList[indexPath.row][@"stationName"];
    vc.railwayId = [self.nearList[indexPath.row][@"railwayId"] intValue];
    vc.distance = [self.nearList[indexPath.row][@"distance"] intValue];
    vc.latitude = [self.nearList[indexPath.row][@"latitude"] floatValue];
    vc.longitude = [self.nearList[indexPath.row][@"longitude"] floatValue];
    
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
