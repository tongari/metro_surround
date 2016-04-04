//
//  MapCarCompositViewController.m
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapCarCompositViewController.h"
#import "MetroRailwayMasterManager.h"
#import "MapCarCompositModel.h"
#import "RailwayMasterManager.h"
#import "DirectionMasterManager.h"
#import "MapCarCompositHeader.h"
#import "MapCarCompositCell.h"
#import "MapCarCompositSmallCell.h"
#import "MapCarCompositDetailViewController.h"

@interface MapCarCompositViewController ()

@property(assign,nonatomic)int metroId;
@property(weak,nonatomic) NSString *stationId;
@property(weak,nonatomic) NSString *stationName;

@property(weak,nonatomic) NSMutableArray *upDirectionList;
@property(weak,nonatomic) NSMutableArray *downDirectionList;

@property(weak,nonatomic) MapCarCompositModel *carCompositModel;
@property(weak,nonatomic) MetroRailwayMasterManager *metroRailwayManager;

@end

@implementation MapCarCompositViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.carCompositModel = [MapCarCompositModel sharedManager];
    self.metroId = [self.carCompositModel getPageId];
    self.stationId = [self.carCompositModel getStationId];
    self.stationName = [self.carCompositModel getStationName];
    
    self.upDirectionList = [self.carCompositModel getUpDirectionList];
    self.downDirectionList = [self.carCompositModel getDownDirectionList];
    
    self.metroRailwayManager = [MetroRailwayMasterManager sharedManager];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MapCarCompositCell" bundle:nil] forCellReuseIdentifier:@"MapCarCompositCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MapCarCompositSmallCell" bundle:nil] forCellReuseIdentifier:@"MapCarCompositSmallCell"];
    [self.tableView registerClass:[MapCarCompositHeader class] forHeaderFooterViewReuseIdentifier:@"MapCarCompositHeader"];
    
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
    self.navigationController.navigationBar.barTintColor = [[MetroRailwayMasterManager sharedManager] getColorCode:self.metroId                                                                                                           alphaValue:1];
    
    self.navigationItem.title = self.stationName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSInteger resultNum;
    
    if(section == 0){
        resultNum = self.upDirectionList.count;
    }
    else if(section == 1){
        resultNum = self.downDirectionList.count;
    }
    
    return resultNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = [self judegeDirectionOfInfo:indexPath];
    
    NSDictionary *transInfoLabel = [self insertTransferInformation:info];
    NSDictionary *surroundInfoLabel = [self insertAurroundingAreaText:info];
    
    
    if([transInfoLabel[@"isHide"] boolValue] && [surroundInfoLabel[@"isHide"] boolValue]){
        
        MapCarCompositSmallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapCarCompositSmallCell" forIndexPath:indexPath];
        
        cell.smallCarNumberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
        cell.smallCarNumberLabel.textColor = [[MetroRailwayMasterManager sharedManager] getColorCode:self.metroId alphaValue:1];
        
        cell.userInteractionEnabled = NO;
        
        //セルの罫線のインデントをゼロに（IOS8以上の場合の処理)
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            cell.preservesSuperviewLayoutMargins = false;
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        
        return cell;
        
        
    } else {
        
        MapCarCompositCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MapCarCompositCell" forIndexPath:indexPath];
        
        cell.carNumberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
        cell.carNumberLabel.textColor = [[MetroRailwayMasterManager sharedManager] getColorCode:self.metroId alphaValue:1];
        
        cell.tranferInfoLabel.text = transInfoLabel[@"text"];
        cell.surroundInfoLabel.text = surroundInfoLabel[@"text"];
        
        cell.tranferInfoLabel.hidden = NO;
        cell.surroundInfoLabel.hidden = NO;
        cell.icoTransInfo.hidden = NO;
        cell.icoSurroundInfo.hidden = NO;
        cell.icoArrow.hidden = NO;
        cell.carNumberLabel.alpha = 1;
        cell.userInteractionEnabled = YES;
        
        //セルの罫線のインデントをゼロに（IOS8以上の場合の処理)
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            cell.preservesSuperviewLayoutMargins = false;
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        return cell;
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *info = [self judegeDirectionOfInfo:indexPath];
    
    NSDictionary *transInfoLabel = [self insertTransferInformation:info];
    NSDictionary *surroundInfoLabel = [self insertAurroundingAreaText:info];
    
    //乗り換え情報、周辺施設情報どちらもデータがない場合
    if([transInfoLabel[@"isHide"] boolValue] && [surroundInfoLabel[@"isHide"] boolValue]){
        //cellの高さを小さく
        return 30;
    }
    
    return 90;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSDictionary *railwayInfo = [self.metroRailwayManager getAssingData:self.metroId stationId:self.stationId];
    MapCarCompositHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MapCarCompositHeader"];
    
    headerView.titleLabel.text = railwayInfo[@"Direction"][section][@"Name"];
    headerView.icoDirectionArrow.image = [headerView.icoDirectionArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    headerView.icoDirectionArrow.tintColor = [[MetroRailwayMasterManager sharedManager] getColorCode:self.metroId alphaValue:1];
    
    if(section == 0){
        headerView.clipsToBounds = NO;
        headerView.icoDirectionArrow.transform = CGAffineTransformMakeRotation(0);
        headerView.icoDirectionArrow.transform = CGAffineTransformScale(headerView.icoDirectionArrow.transform, 1, 1);
        headerView.customContentView.frame = CGRectMake(0,0, self.view.frame.size.width, headerView.customContentView.frame.size.height);
        
    } else {
        headerView.clipsToBounds = YES;
        headerView.icoDirectionArrow.transform = CGAffineTransformMakeRotation(M_PI);
        headerView.icoDirectionArrow.transform = CGAffineTransformScale(headerView.icoDirectionArrow.transform, -1, 1);
        headerView.customContentView.frame = CGRectMake(0, -5, self.view.frame.size.width, headerView.customContentView.frame.size.height);
    }
    return headerView;
    
}


-(CGFloat)tableView:(UIView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    float resultHeight = 40;
    if(section !=0){
        resultHeight = 30;
    }
    
    return resultHeight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *stBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    MapCarCompositDetailViewController *vc = [stBoard instantiateViewControllerWithIdentifier:@"MapCarCompositDetailViewController"];
    
    vc.metroId = self.metroId;
    vc.stationId = self.stationId;
    if(indexPath.section == 0){
        vc.isUpDirection = YES;
    } else{
        vc.isUpDirection = NO;
    }
    
    vc.carNumber = (int)indexPath.row;
    
    [self.navigationController pushViewController:vc animated:YES];
}






#pragma mark- private method
-(NSDictionary *)judegeDirectionOfInfo:(NSIndexPath*) indexPath{
    NSDictionary *info;
    if(indexPath.section == 0){
        info = self.upDirectionList[indexPath.row];
    } else {
        info = self.downDirectionList[indexPath.row];
    }
    
    return info;
}


-(NSDictionary *)insertTransferInformation:(NSDictionary *)info{
    
    if(info[@"odpt:transferInformation"] != nil){
        
        NSString *transInfotext = @"";
        NSArray *transInfo = info[@"odpt:transferInformation"];
        
        NSString *addText;
        
        NSString *railDirection;
        NSString *railwayName;
        
        for(int i = 0; i<transInfo.count; i++){
            
            railDirection = [[DirectionMasterManager sharedManager] getDirectionName:transInfo[i][@"odpt:railDirection"]];
            railwayName = [[RailwayMasterManager sharedManager] getRailwayName:transInfo[i][@"odpt:railway"]][@"Name"];
            
            if(railwayName && railDirection){
                
                addText = [NSString stringWithFormat:@"%@(%@)",railwayName,railDirection];
            } else {
                
                addText = [NSString stringWithFormat:@"%@",railwayName];
            }
            
            
            if(i ==0){
                
                transInfotext = [ NSString stringWithFormat:@"%@",addText ];
            } else {
                
                transInfotext = [ NSString stringWithFormat:@"%@、%@",transInfotext,addText ];
            }
            
        }
        
        return @{@"text" : transInfotext , @"isHide" : @NO};
    }
    
    return @{@"text" : @"-" , @"isHide" : @YES};
}

-(NSDictionary *)insertAurroundingAreaText:(NSDictionary *)info{
    
    if(info[@"odpt:surroundingArea"] != nil){
        
        NSString *surroundText = @"";
        NSArray *surroundInfo = info[@"odpt:surroundingArea"];
        
        for(int j = 0; j<surroundInfo.count; j++){
            
            if(j == 0){
                
                surroundText = [ NSString stringWithFormat:@"%@",surroundInfo[j] ];
                
            } else {
                
                surroundText = [ NSString stringWithFormat:@"%@、%@",surroundText,surroundInfo[j] ];
            }
        }
        
        return @{@"text" : surroundText , @"isHide" : @NO};;
    }
    
    return @{@"text" : @"-" , @"isHide" : @YES};
    
}


@end
