//
//  CarCompositDetailViewController.h
//  MetroSurround
//
//  Created by as on 2015/06/07.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarCompositDetailViewController : UITableViewController

@property(assign,nonatomic)int metroId;
@property(weak,nonatomic) NSString *stationId;
@property(assign,nonatomic)BOOL isUpDirection;
@property(assign,nonatomic)int carNumber;

@end
