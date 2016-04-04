//
//  Util.m
//  MetroSurround
//
//  Created by as on 2015/07/07.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "Util.h"

@implementation Util

+(UIImage *)createImageFromUIColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, [color CGColor]);
    CGContextFillRect(contextRef, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
};

@end
