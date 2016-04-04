//
//  UserDefalutManager.m
//  MetroSurround
//
//  Created by as on 2015/05/13.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "UserDefalutManager.h"

static UserDefalutManager *sharedManager;
static NSUserDefaults *ud;


@implementation UserDefalutManager

+ (UserDefalutManager *)sharedManager{
    
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        [[self alloc] init];
        
        [sharedManager initDefaultData];
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

-(void)initDefaultData{
    
    // NSUserDefaultsに初期値を登録する
    ud = [NSUserDefaults standardUserDefaults];  // 取得
//    //初期値Dictonary
//    NSMutableDictionary *element = [@{
//                                      @"hour":@"07",@"minute":@"00"
//                                    }mutableCopy];
//    //登録Dictonary
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[kAlarmTimeKey] = element;
//    
//    //既に同じキーが存在する場合は初期値をセットせず、キーが存在しない場合だけ値をセット。
//    [ud registerDefaults:dict];
}




/**
 * アテンションを確認してるか否かを返却
 *
 *  @return bool
 */
-(BOOL)getTutorialAttention{
    return [ud boolForKey:kIsTutorialAttention];
}


/**
 * アテンションを確認を保存
 *
 *  @param isAlarm
 */
-(void)setTutorialAttention:(BOOL)isView{
    
    [ud setBool:isView forKey:kIsTutorialAttention];
    
    // NSUserDefaultsに即時反映させる
    [ud synchronize];
}

/**
 * GPSアテンションを確認してるか否かを返却
 *
 *  @return bool
 */
-(BOOL)getGpsAttention{
    return [ud boolForKey:kIsGpsAttention];
}


/**
 * GPSアテンションを確認を保存
 *
 *  @param isAlarm
 */
-(void)setGpsAttention:(BOOL)isView{
    
    [ud setBool:isView forKey:kIsGpsAttention];
    
    // NSUserDefaultsに即時反映させる
    [ud synchronize];
}


@end
