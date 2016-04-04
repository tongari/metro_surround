//
//  TextIco.m
//  MetroSurround
//
//  Created by as on 2015/06/07.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "TextIco.h"
#import <QuartzCore/QuartzCore.h>

@implementation TextIco


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //枠線
    self.layer.borderWidth = 1.0f;
    //枠線の色
    self.layer.borderColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f].CGColor;
//    self.layer.borderColor = [UIColor redColor].CGColor;
    
}

@end
