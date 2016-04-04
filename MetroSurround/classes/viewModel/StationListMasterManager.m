//
//  StationListMasterManager.m
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "StationListMasterManager.h"
#import "MetroRailwayMasterManager.h"

static StationListMasterManager *sharedManager;
static NSMutableArray *plistData;



@implementation StationListMasterManager

+ (StationListMasterManager *)sharedManager{
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        [[self alloc] init];
        
        [sharedManager loadData];
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

#pragma mark - functional

-(void)loadData{
    
    
    NSArray *metroRailwayData = [[MetroRailwayMasterManager sharedManager] getAllData];
    
    plistData = [NSMutableArray array];
    
    for(int i = 0; i<metroRailwayData.count; i++){
        
        //プロジェクト内のファイルにアクセスできるオブジェクトを宣言
        NSBundle *bundle = [NSBundle mainBundle];
        
        //読み込むプロパティリストのファイルパスを指定
        NSArray *fileArray = [metroRailwayData[i][@"ID"] componentsSeparatedByString:@"."];
        NSString *fileName = [NSString stringWithFormat:@"%@",fileArray[fileArray.count-1]];
        NSString *path = [bundle pathForResource:fileName ofType:@"plist"];
        
        //プロパティリストの中身データを取得
        [plistData addObject:[NSArray arrayWithContentsOfFile:path]];
    }

}

-(NSMutableArray *)getData:(int) pageId{
    return plistData[pageId];
}

-(NSMutableArray *)getAllData{
    return plistData;
}


@end
