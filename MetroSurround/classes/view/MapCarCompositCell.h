//
//  MapCarCompositCell.h
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCarCompositCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *tranferInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *surroundInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *icoTransInfo;
@property (weak, nonatomic) IBOutlet UILabel *icoSurroundInfo;
@property (weak, nonatomic) IBOutlet UIImageView *icoArrow;

@end
