//
//  CarCompositModel.m
//  MetroSurround
//
//  Created by as on 2015/06/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarCompositModel.h"
#import "ApiConnectorManager.h"
#import "MetroRailwayMasterManager.h"

static CarCompositModel *sharedManager;

static int pageId;
static NSString *stationId;
static NSString *stationName;

static NSMutableArray *upDirectionList;
static NSMutableArray *downDirectionList;

@implementation CarCompositModel

+ (CarCompositModel *)sharedManager{
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        [[self alloc] init];
    });
    
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    __block id ret = nil;
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        sharedManager = [super allocWithZone:zone];
        ret           = sharedManager;
    });
    
    return  ret;
    
}

- (id)copyWithZone:(NSZone *)zone{
    
    return self;
}


/**
 *  駅詳細のデータを取得
 *
 *  @param info
 */
-(void)fetchStationDetailData:(NSDictionary *)info{
    
//    for (id key in [info keyEnumerator]) {
//        NSLog(@"Key:%@ Value:%@", key, [info valueForKey:key]);
//    }
    
    pageId = [info[@"pageId"] intValue];
    stationId = info[@"stationId"];
    stationName = info[@"stationName"];
    
    
    [[ApiConnectorManager sharedManager] fetchStationDetailData:info];
    
    [[NSNotificationCenter defaultCenter] addObserver:sharedManager
                                             selector:@selector(onCompFetchStationDetailData:)
                                                 name:@"ApiConnector.onCompFetchStationDetailData"
                                               object:nil];
}

/**
 *  api通信が完了
 *
 *  @param notification
 */
-(void)onCompFetchStationDetailData:(NSNotification *)notification{
    
    NSDictionary *info = [notification userInfo];
        
    if(info[@"apiData"]){
        
        [sharedManager trimApiResultData:info[@"apiData"]];
    }
            
    [[NSNotificationCenter defaultCenter] removeObserver:sharedManager name:@"ApiConnector.onCompFetchStationDetailData" object:nil];
}

/**
 *  API返却データを整形
 *
 *  @param apiData
 */
-(void)trimApiResultData:(id)apiData{
    
    NSArray *resultData = apiData;
    NSDictionary *data;
    
    NSString *checkStationId = [NSString stringWithFormat:@"odpt.StationFacility:TokyoMetro.%@",stationId];
    
    for(int j = 0; j<resultData.count; j++){
        
        if( [checkStationId isEqual:resultData[j][@"owl:sameAs"]]){
            
            data = resultData[j];
            break;
        }
    }
    
    NSString *railwayId = [[MetroRailwayMasterManager sharedManager] getAssingData:pageId stationId:stationId][@"ID"];
    NSString *directionUp = [[MetroRailwayMasterManager sharedManager] getAssingData:pageId stationId:stationId][@"Direction"][0][@"ID"];
    NSString *directionDown = [[MetroRailwayMasterManager sharedManager] getAssingData:pageId stationId:stationId][@"Direction"][1][@"ID"];
    
    NSArray *platformInfoList = data[@"odpt:platformInformation"];
    upDirectionList = [NSMutableArray array];
    downDirectionList = [NSMutableArray array];
    
    for(int i = 0; i < platformInfoList.count; i++){
        
        //路線が一緒なら
        if([platformInfoList[i][@"odpt:railway"] isEqual:railwayId]){
            
            if( [ platformInfoList[i][@"odpt:railDirection"] isEqual:directionUp ] ){
                
                [ upDirectionList addObject : platformInfoList[i] ];
            }
            
            else if([platformInfoList[i][@"odpt:railDirection"] isEqual:directionDown]){
                
                //千代田線綾瀬駅ハードコード
                if( [stationId isEqual: @"Ayase"] && [platformInfoList[i][@"odpt:carComposition"] intValue] == 3 ){
                    continue;
                }
                
                [ downDirectionList addObject : platformInfoList[i]];
            }
            
        } else {
            
            continue;
        }
    }
    
}



#pragma mark - interface method
-(int)getPageId{
    
    return pageId;
}

-(NSString *)getStationId{
    
    return stationId;
}

-(NSString *)getStationName{
    
    return stationName;
}

-(NSMutableArray *)getUpDirectionList{
    return upDirectionList;
}

-(NSMutableArray *)getDownDirectionList{
    return downDirectionList;
}

@end
