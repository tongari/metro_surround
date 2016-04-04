//
//  ApiConnectorManager.m
//  MetroSurround
//
//  Created by as on 2015/06/04.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "ApiConnectorManager.h"
#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <unistd.h>
#import "MetroRailwayMasterManager.h"
#import "AppDelegate.h"

@interface ApiConnectorManager()<MBProgressHUDDelegate>

@end

static MBProgressHUD *HUD;
static ApiConnectorManager *sharedManager;

@implementation ApiConnectorManager


+ (ApiConnectorManager *)sharedManager{
    
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
 *  駅施設詳細の情報を取得
 *
 *  @param info
 */
-(void)fetchStationDetailData:(NSDictionary *)info{
    
    [sharedManager loaderShow:[info[@"pageId"] intValue]];
    
    // AFHTTPSessionManagerを利用して、JSONデータを取得する
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // タイムアウト時間を設定します。
    manager.requestSerializer.timeoutInterval = 30;
    
    NSString *stationName = [NSString stringWithFormat:@"odpt.StationFacility:TokyoMetro.%@",info[@"stationId"]];
    
    NSString *apiPath = @"https://api.tokyometroapp.jp/api/v2/datapoints";
    NSDictionary * parameters = @{ @"rdf:type": @"odpt:StationFacility",
                                   @"owl:sameAs": stationName,
                                   @"acl:consumerKey": AppDelegate.TOKYO_METRO_API_KEY
                                   };
    
    [manager GET:apiPath
      parameters:parameters
         success:^(NSURLSessionDataTask *task, id responseObject) {
             
             // 通信に成功した場合の処理
             //NSArray *arr = responseObject;
             NSDictionary *parameters = @{ @"apiData" :responseObject };
             
             [[NSNotificationCenter defaultCenter]
              postNotification:[NSNotification notificationWithName:@"ApiConnector.onCompFetchStationDetailData"
                                                             object:nil
                                                           userInfo:parameters
                                ]];
             
             [sharedManager loaderEnd];
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             
             
             [sharedManager loaderEnd];
             
             [sharedManager onErrorMessage];
             
             NSDictionary *parameters = @{ @"error" :@"fail" };
             
             [[NSNotificationCenter defaultCenter]
              postNotification:[NSNotification notificationWithName:@"ApiConnector.onCompFetchStationDetailData"
                                                             object:nil
                                                           userInfo:parameters
                                ]];
             
             
         }];
    
}


-(void)onErrorMessage{
    
    //IOS8以上なら
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
        
        // コントローラを生成
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"サーバーエラー"
                                                                     message:@"データを取得できませんでした。お手数ですが、しばらく経ってからご利用ください。"
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        // OK用のアクションを生成
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"閉じる"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              // ボタンタップ時の処理
                                                              //NSLog(@"OK button tapped.");
                                                          }];
        // コントローラにアクションを追加
        [ac addAction:okAction];
        
        // アラート表示処理
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *root = window.rootViewController;
        
        [root presentViewController:ac animated:YES completion:nil];
        
    } else {
        
        UIAlertView *uv = [ [UIAlertView alloc] initWithTitle:@"サーバーエラー" message:@"データを取得できませんでした。お手数ですが、しばらく経ってからご利用ください。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"閉じる", nil];
        
        [uv show];
        
    }

}



-(void)loaderShow:(int) curPageId{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *root = window.rootViewController;
    
    //ローダーを表示
    HUD = [[MBProgressHUD alloc] initWithView:root.view];
    [root.view addSubview:HUD];
    
    UIImage *loader = [UIImage imageNamed:@"loader"];
    HUD.customView = [[UIImageView alloc]initWithImage:loader];
    
    //アニメーション
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI / 180) * 360];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.repeatCount = MAXFLOAT;
    [HUD.customView.layer addAnimation:rotationAnimation forKey:@"loaderAnimation"];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = sharedManager;
    HUD.color = [[MetroRailwayMasterManager sharedManager] getColorCode:curPageId alphaValue:1];
    
    [HUD show:YES];
}


-(void)loaderEnd{
//    usleep(200);
    [HUD hide:YES afterDelay:0.2];
}



@end
