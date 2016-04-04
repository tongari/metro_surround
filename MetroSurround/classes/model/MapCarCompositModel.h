//
//  MapCarCompositModel.h
//  MetroSurround
//
//  Created by as on 2015/07/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapCarCompositModel : NSObject

+(MapCarCompositModel *)sharedManager;

-(void)fetchStationDetailData:(NSDictionary *)info;
-(int)getPageId;
-(NSString *)getStationId;
-(NSString *)getStationName;

-(NSMutableArray *)getUpDirectionList;
-(NSMutableArray *)getDownDirectionList;

@end
