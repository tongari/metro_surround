//
//  CarCompositModel.h
//  MetroSurround
//
//  Created by as on 2015/06/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarCompositModel : NSObject
+(CarCompositModel *)sharedManager;

-(void)fetchStationDetailData:(NSDictionary *)info;
-(int)getPageId;
-(NSString *)getStationId;
-(NSString *)getStationName;

-(NSMutableArray *)getUpDirectionList;
-(NSMutableArray *)getDownDirectionList;

@end
