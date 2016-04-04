//
//  RailwayMasterManager.h
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface RailwayMasterManager : NSObject

+(RailwayMasterManager *)sharedManager;

-(NSDictionary *)getRailwayName:(NSString *) railwayId;
-(UIColor *)getColorCode:(NSString *) railwayId alphaValue:(float) alphaValue;

@end
