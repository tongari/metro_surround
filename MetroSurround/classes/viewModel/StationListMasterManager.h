//
//  StationListMasterManager.h
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StationListMasterManager : NSObject

+(StationListMasterManager *)sharedManager;

-(NSMutableArray *)getData:(int) pageId;
-(NSMutableArray *)getAllData;

@end
