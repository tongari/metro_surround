//
//  DirectionMasterManager.m
//  MetroSurround
//
//  Created by as on 2015/06/02.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "DirectionMasterManager.h"

static DirectionMasterManager *sharedManager;
static NSDictionary *plistData;



@implementation DirectionMasterManager

+ (DirectionMasterManager *)sharedManager{
    
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
    NSString *path = [bundle pathForResource:@"direction" ofType:@"plist"];
    //プロパティリストの中身データを取得
    plistData = [NSDictionary dictionaryWithContentsOfFile:path];
}

-(NSString *)getDirectionName:(NSString *) directionId{
    return plistData[directionId];
}


@end
