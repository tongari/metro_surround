//
//  MetroRailwayMasterManager.h
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MetroRailwayMasterManager : NSObject

+(MetroRailwayMasterManager *)sharedManager;

-(NSDictionary *)getAssingData:(int) pageId stationId:(NSString *)stationId;
-(NSArray *)getAllData;
-(UIColor *)getColorCode:(int) metroId alphaValue:(float) alphaValue;

@end
