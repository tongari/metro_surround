//
//  GlobalNavButton.m
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "GlobalNavButton.h"
#import "MetroRailwayMasterManager.h"

@interface GlobalNavButton()

@property(strong,nonatomic) NSMutableArray *globalNavColor;

@end

@implementation GlobalNavButton


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(4, 4)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    
    [self addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSArray *masterData = [[MetroRailwayMasterManager sharedManager] getAllData];
    self.globalNavColor = [NSMutableArray array];
    
    for(int i = 0; i<masterData.count; i++){
        
        [self.globalNavColor addObject:masterData[i][@"Color"]];
    }

}


-(void)onTap:(UIButton *)sender{
    
    NSString *pageId = [NSString stringWithFormat:@"%ld",(long)self.tag];
    
    NSDictionary *parameters = @{ @"pageId" :pageId };
    
    [[NSNotificationCenter defaultCenter]
     postNotification:[NSNotification notificationWithName:@"onTapGlobalNavButton"
                                                    object:self
                                                  userInfo:parameters
                       ]];
    
    NSDictionary *bgColor = self.globalNavColor[self.tag];
    
    self.backgroundColor = [UIColor colorWithRed:[bgColor[@"r"] floatValue]/255.0f
                                                 green:[bgColor[@"g"] floatValue]/255.0f
                                                  blue:[bgColor[@"b"] floatValue]/255.0f
                                                 alpha:1];
}

@end
