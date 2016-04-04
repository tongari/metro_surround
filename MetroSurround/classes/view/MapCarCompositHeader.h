//
//  MapCarCompositHeader.h
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCarCompositHeader : UITableViewHeaderFooterView
@property (strong, nonatomic) IBOutlet UIView *customContentView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icoDirectionArrow;
@end
