//
//  StationListViewController.m
//  MetroSurround
//
//  Created by as on 2015/06/03.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

const float kStationListCellHeight = 60;
const float kStationListHeaderHeihght = 80;

#import "StationListViewController.h"
#import "MetroRailwayMasterManager.h"
#import "StationListMasterManager.h"
#import "StationListViewCell.h"
#import "CarCompositViewController.h"
#import "ApiConnectorManager.h"
#import "CarCompositModel.h"

@interface StationListViewController()

@property(weak,nonatomic) NSMutableArray *stationListData;
@property(assign,nonatomic) int pageId;
@property(weak,nonatomic) MetroRailwayMasterManager *metoroRailwayManager;
@property(weak,nonatomic) CarCompositModel *carCompositModel;

@end

@implementation StationListViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //ページIDを設定
    self.pageId = [self.dataObject intValue];
    //路線マスタ情報の管理インスタンスを取得
    self.metoroRailwayManager = [MetroRailwayMasterManager sharedManager];
    //路線の駅リストを取得
    self.stationListData = [[StationListMasterManager sharedManager] getData:self.pageId ];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StationListCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.carCompositModel = [CarCompositModel sharedManager];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSInteger resultNum = self.stationListData.count;
    return resultNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    StationListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *stationName = self.stationListData[indexPath.row][@"Name"];
    NSString *stationEnName = self.stationListData[indexPath.row][@"ID"];
    cell.stationNameText.text = stationName;
    cell.stationEnNameText.text = stationEnName;
    
    //IOS8以上なら
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        cell.preservesSuperviewLayoutMargins = false;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    cell.numberingMark.image = [cell.numberingMark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.numberingMark.tintColor = [self.metoroRailwayManager getColorCode:self.pageId alphaValue:1];

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return kStationListCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    header.backgroundColor = [self.metoroRailwayManager getColorCode:self.pageId alphaValue:1];
    self.view.backgroundColor = [self.metoroRailwayManager getColorCode:self.pageId alphaValue:1];
    
    UILabel *title = [ [UILabel alloc] initWithFrame:CGRectMake(0,20, 0, 0)];
    title.text = @"駅を選んでください";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    
    [title sizeToFit];
    title.center = CGPointMake(self.view.center.x, 45);
    
    [header addSubview:title];

    return header;
}

-(CGFloat)tableView:(UIView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kStationListHeaderHeihght;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *info = @{@"stationId":self.stationListData[indexPath.row][@"ID"],
                           @"stationName":self.stationListData[indexPath.row][@"Name"],
                           @"pageId":[NSString stringWithFormat:@"%d",self.pageId]
                           };
    
    [self.carCompositModel fetchStationDetailData:info];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCompFetchStationDetailData:)
                                                 name:@"ApiConnector.onCompFetchStationDetailData"
                                               object:nil];
}

/**
 *  api通信が完了
 *
 *  @param notification
 */
-(void)onCompFetchStationDetailData:(NSNotification *)notification{
    
    NSDictionary *info = [notification userInfo];
        
    if(info[@"apiData"]){
        
        [self transitionCarCompositVC];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ApiConnector.onCompFetchStationDetailData" object:nil];
}


/**
 *  詳細に遷移
 *
 *  @param info
 */
-(void)transitionCarCompositVC {
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    CarCompositViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"CarCompositViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
