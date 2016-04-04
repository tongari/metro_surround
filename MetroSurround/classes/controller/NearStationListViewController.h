//
//  NearStationListViewController.h
//  MetroSurround
//
//  Created by as on 2015/07/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearStationListViewController : UITableViewController
@property(strong,nonatomic)NSArray *nearList;
@property(assign,nonatomic)BOOL isSameStation;
@property(weak,nonatomic)NSString *stationName;

@end
