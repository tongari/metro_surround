//
//  MapRailwayViewController.m
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapRailwayViewController.h"
#import "MetroRailwayMasterManager.h"
#import "StationListMasterManager.h"
#import "MapCarCompositModel.h"
#import "StationListViewCell.h"
#import "MapCarCompositViewController.h"

@interface MapRailwayViewController ()

@property(weak,nonatomic) NSMutableArray *stationListData;
@property(weak,nonatomic) MetroRailwayMasterManager *metoroRailwayManager;
@property(weak,nonatomic) MapCarCompositModel *carCompositModel;

@end

@implementation MapRailwayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        
    //路線マスタ情報の管理インスタンスを取得
    self.metoroRailwayManager = [MetroRailwayMasterManager sharedManager];
    //路線の駅リストを取得
    self.stationListData = [[StationListMasterManager sharedManager] getData:self.pageId ];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StationListCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.carCompositModel = [MapCarCompositModel sharedManager];
    
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
    self.navigationController.navigationBar.barTintColor = [self.metoroRailwayManager getColorCode:self.pageId                                                                                                           alphaValue:1];
    
    self.navigationItem.title = [self.metoroRailwayManager getAllData][self.pageId][@"Name"];
}



#pragma mark - Table view data source
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
    
    return 60;
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
    MapCarCompositViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"MapCarCompositViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}




@end
