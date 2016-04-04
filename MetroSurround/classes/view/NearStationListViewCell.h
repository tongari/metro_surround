//
//  NearStationListViewCell.h
//  MetroSurround
//
//  Created by as on 2015/07/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearStationListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stationNameText;
@property (weak, nonatomic) IBOutlet UILabel *stationEnNameText;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *numberingMark;

@end
