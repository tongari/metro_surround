//
//  MapStationDetailViewController.h
//  MetroSurround
//
//  Created by as on 2015/07/01.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapStationDetailViewController : UIViewController

@property(assign,nonatomic)int railwayId;
@property(weak,nonatomic)NSString *stationName;
@property(weak,nonatomic)NSString *stationId;
@property(assign,nonatomic)float latitude;
@property(assign,nonatomic)float longitude;
@property(assign,nonatomic)int distance;

@end
