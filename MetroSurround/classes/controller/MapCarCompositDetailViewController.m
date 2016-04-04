//
//  MapCarCompositDetailViewController.m
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapCarCompositDetailViewController.h"
#import "MetroRailwayMasterManager.h"
#import "MapCarCompositModel.h"
#import "RailwayMasterManager.h"
#import "DirectionMasterManager.h"
#import "MapCarCompositDetailCell.h"
#import "MapCarCompositDetailHeader.h"

@interface MapCarCompositDetailViewController ()

@property(weak,nonatomic) NSArray *transInfoData;
@property(weak,nonatomic) NSArray *surroundInfoData;

@property(weak,nonatomic) MapCarCompositModel *carCompositModel;
@property(weak,nonatomic) MetroRailwayMasterManager *metroRailwayManager;
@property(weak,nonatomic) RailwayMasterManager *railwayManager;

@end

@implementation MapCarCompositDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.carCompositModel = [MapCarCompositModel sharedManager];
    self.metroId = [self.carCompositModel getPageId];
    self.stationId = [self.carCompositModel getStationId];
    
    self.metroRailwayManager = [MetroRailwayMasterManager sharedManager];
    self.railwayManager = [RailwayMasterManager sharedManager];
    
    
    NSDictionary *platformInfo;
    if(self.isUpDirection){
        platformInfo = [self.carCompositModel getUpDirectionList][self.carNumber];
    } else {
        platformInfo = [self.carCompositModel getDownDirectionList][self.carNumber];
    }
    
    self.transInfoData = platformInfo[@"odpt:transferInformation"];
    self.surroundInfoData = platformInfo[@"odpt:surroundingArea"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MapCarCompositDetailCell" bundle:nil] forCellReuseIdentifier:@"MapCarCompositDetailCell"];
    [self.tableView registerClass:[MapCarCompositDetailHeader class] forHeaderFooterViewReuseIdentifier:@"MapCarCompositDetailHeader"];
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"%d%@", (self.carNumber+1) , @"両目"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    int stackCount = 0;
    
    stackCount += (self.transInfoData != nil) ? 1 : 0;
    stackCount += (self.surroundInfoData != nil) ? 1 : 0;
    
    return stackCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSInteger resultNum;
    
    //乗り換え・周辺施設どちらもある場合
    if(self.transInfoData && self.surroundInfoData){
        
        if(section == 0){
            resultNum = (NSInteger)self.transInfoData.count;
        }
        else {
            resultNum = (NSInteger)self.surroundInfoData.count;
        }
        
    }
    //乗り換えのみ
    else if(self.transInfoData) {
        resultNum = (NSInteger)self.transInfoData.count;
    } else {
        resultNum = (NSInteger)self.surroundInfoData.count;
    }
    
    
    
    return resultNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MapCarCompositDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapCarCompositDetailCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    
    if(self.transInfoData && self.surroundInfoData){
        if(indexPath.section == 0){
            
            [self setCellTransInfoData:indexPath cell:cell];
            
        } else{
            
            [self setCellSurroundInfoData:indexPath cell:cell];
        }
    }
    
    else if(self.transInfoData){
        
        [self setCellTransInfoData:indexPath cell:cell];
        
    } else {
        
        [self setCellSurroundInfoData:indexPath cell:cell];
    }
    
    
    //セルの罫線のインデントをゼロに（IOS8以上の場合の処理)
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        cell.preservesSuperviewLayoutMargins = false;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    MapCarCompositDetailHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MapCarCompositDetailHeader"];
    
    if(self.transInfoData && self.surroundInfoData){
        
        if(section == 0){
            headerView.clipsToBounds = NO;
            headerView.titleLabel.text = @"乗り換え";
            headerView.customContentView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerView.customContentView.frame.size.height);
        } else {
            headerView.clipsToBounds = YES;
            headerView.titleLabel.text = @"周辺施設";
            headerView.customContentView.frame = CGRectMake(0, -5, self.view.frame.size.width, headerView.customContentView.frame.size.height);
        }
    }
    
    else if(self.transInfoData){
        headerView.clipsToBounds = NO;
        headerView.titleLabel.text = @"乗り換え";
    } else {
        headerView.clipsToBounds = NO;
        headerView.titleLabel.text = @"周辺施設";
    }
    
    
    return headerView;
    
}


-(CGFloat)tableView:(UIView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    float resultNum = 60;
    
    if(section != 0){
        resultNum = 50;
    }
    
    return resultNum;
}


#pragma mark - private method

-(void)setCellTransInfoData:(NSIndexPath *) indexPath cell:(MapCarCompositDetailCell *)cell {
    
    NSDictionary *data = self.transInfoData[indexPath.row];
    NSString *railwayId = data[@"odpt:railway"];
    NSDictionary *railMasterData = [self.railwayManager getRailwayName:railwayId];
    NSString *railway = railMasterData[@"Name"];
    
    NSString *railDirection = [ [DirectionMasterManager sharedManager] getDirectionName:data[@"odpt:railDirection"] ];
    
    
    if(railway && railDirection ){
        NSString *direction = railDirection;
        
        railway = [NSString stringWithFormat:@"%@(%@)",railway,direction];
    }
    
    if(data[@"odpt:necessaryTime"]){
        railway = [NSString stringWithFormat:@"%@ - %@分",railway,data[@"odpt:necessaryTime"]];
    }
    
    
    cell.detailText.text = railway;
    
    if(railMasterData[@"Color"]){
        
        cell.numberingMark.hidden = NO;
        cell.numberingMark.image = [cell.numberingMark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.numberingMark.tintColor = [self.railwayManager getColorCode:railwayId alphaValue:1];
        
    } else {
        cell.numberingMark.hidden = YES;
    }
    
}

-(void)setCellSurroundInfoData:(NSIndexPath *) indexPath cell:(MapCarCompositDetailCell *)cell {
    
    NSString *data = self.surroundInfoData[indexPath.row];
    cell.detailText.text = data;
    
    cell.numberingMark.hidden = YES;
}


@end
