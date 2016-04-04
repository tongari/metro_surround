//
//  ApiConnectorManager.h
//  MetroSurround
//
//  Created by as on 2015/06/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiConnectorManager : NSObject

+(ApiConnectorManager *)sharedManager;


/**
 *  駅施設詳細の情報を取得
 *
 *  @param info
 */
-(void)fetchStationDetailData:(NSDictionary *)info;

@end
