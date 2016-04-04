//
//  RailwayMasterManager.m
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "RailwayMasterManager.h"

static RailwayMasterManager *sharedManager;
static NSDictionary *plistData;



@implementation RailwayMasterManager

+ (RailwayMasterManager *)sharedManager{
    
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
    NSString *path = [bundle pathForResource:@"railway" ofType:@"plist"];
    //プロパティリストの中身データを取得
    plistData = [NSDictionary dictionaryWithContentsOfFile:path];
}

-(NSDictionary *)getRailwayName:(NSString *) railwayId{
    return plistData[railwayId];
}

-(UIColor *)getColorCode:(NSString *) railwayId alphaValue:(float) alphaValue{
        
    float r = [plistData[railwayId][@"Color"][@"r"] floatValue] / 255.0f;
    float g = [plistData[railwayId][@"Color"][@"g"] floatValue] / 255.0f;
    float b = [plistData[railwayId][@"Color"][@"b"] floatValue] / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:alphaValue];
}


@end
