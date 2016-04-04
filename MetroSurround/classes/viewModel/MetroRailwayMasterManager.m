//
//  MetroRailwayMasterManager.m
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MetroRailwayMasterManager.h"

static MetroRailwayMasterManager *sharedManager;
static NSArray *plistData;



@implementation MetroRailwayMasterManager

+ (MetroRailwayMasterManager *)sharedManager{
    
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
    
    //プロジェクト内のファイルにアクセスできるオブジェクトを宣言
    NSBundle *bundle = [NSBundle mainBundle];
    //読み込むプロパティリストのファイルパスを指定
    NSString *path = [bundle pathForResource:@"metro_railway" ofType:@"plist"];
    //プロパティリストの中身データを取得
    plistData = [NSArray arrayWithContentsOfFile:path];

}

-(NSDictionary *)getAssingData:(int) pageId stationId:(NSString *)stationId{
    
    //千代田線：北綾瀬駅が選択されたら
    if( pageId == 4 && [stationId isEqual:@"KitaAyase"] ){
        
        return [sharedManager getKitaAyase:pageId];
    }
    
    //丸ノ内線分岐の駅が選択されたら
    else if( pageId == 1 &&( [stationId isEqual:@"Honancho"] || [stationId isEqual:@"NakanoFujimicho"] || [stationId isEqual:@"NakanoShimbashi"] ) ){
        
        return [sharedManager getMarunouchiBrunch:pageId];
    }
    
    
    return plistData[pageId];
}


/**
 *  北綾瀬駅ハードコード処理
 *
 *  @param pageId
 *
 *  @return
 */
-(NSDictionary *) getKitaAyase:(int) pageId{
    
    NSDictionary *up = plistData[pageId][@"Direction"][1];
    NSDictionary *down = plistData[pageId][@"Direction"][2];
    
    
    NSDictionary *result = @{ @"Direction":@[up,down],
                              @"ID":plistData[pageId][@"ID"],
                              @"Color":plistData[pageId][@"Color"]
                              };
    
    return result;
}


/**
 *  丸ノ内線分岐ハードコード処理
 *
 *  @param pageId
 *
 *  @return
 */
-(NSDictionary *) getMarunouchiBrunch:(int) pageId{
    
    NSDictionary *up = plistData[pageId][@"Direction"][2];
    NSDictionary *down = plistData[pageId][@"Direction"][3];
    
    
    NSDictionary *result = @{ @"Direction":@[up,down],
                              @"ID":plistData[pageId][@"ID"],
                              @"Color":plistData[pageId][@"Color"]
                              };
    
    return result;
}



-(NSArray *)getAllData{
    return plistData;
}

-(UIColor *)getColorCode:(int) metroId alphaValue:(float) alphaValue{
            
    float r = [plistData[metroId][@"Color"][@"r"] floatValue] / 255.0f;
    float g = [plistData[metroId][@"Color"][@"g"] floatValue] / 255.0f;
    float b = [plistData[metroId][@"Color"][@"b"] floatValue] / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alphaValue];
}


@end
