//
//  MapViewController.m
//  MetroSurround
//
//  Created by as on 2015/06/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <MapKit/MKAnnotationView.h>
#import "MapViewModel.h"
#import "CustomPointAnnotation.h"
#import "MetroRailwayMasterManager.h"
#import "CarCompositModel.h"
#import "CarCompositViewController.h"
#import "MapStationDetailViewController.h"
#import "NearStationListViewController.h"
#import "UserDefalutManager.h"
#import "Util.h"


@interface MapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MapViewModel *mapViewModel;

@property (weak, nonatomic) NSTimer *gpsSearchTimer;

@property(assign,nonatomic)BOOL isStartCoordinate;
@property(assign,nonatomic)BOOL isGpsSearchPinView;
@property(assign,nonatomic)NSInteger userTrackingMode;

@property (weak, nonatomic) IBOutlet UIView *nearBox;
@property (weak, nonatomic) IBOutlet UIButton *toNearListButton;
@property (weak, nonatomic) IBOutlet UILabel *nearLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearEnLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *nearBoxButton;

- (IBAction)onSearchGps:(UIButton *)sender;
- (IBAction)onSearchMapCenter:(UIButton *)sender;
- (IBAction)onToNearStationListButton:(UIButton *)sender;
- (IBAction)onTapNearBoxButton:(UIButton *)sender;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapViewModel = [MapViewModel sharedManager];
    [self.mapViewModel initMap:self.map];
    
    
    self.isStartCoordinate = NO;
    [self.mapViewModel setGpsSearch:NO];
    
    self.map.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
        
    // iOS8以降
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        // 位置情報測位の許可を求めるメッセージを表示する
        [self.locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
    } else { // iOS7以前
        // 位置測位スタート
        [self.locationManager startUpdatingLocation];
    }
    
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;

    UIImage *highlightedColor = [Util createImageFromUIColor:[UIColor blackColor]];
    [self.nearBoxButton setBackgroundImage:highlightedColor forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.alpha = 0;
    
    if(!self.isGpsSearchPinView){
        [self controlViewNearInfo:NO];
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if(self.isStartCoordinate){
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        if([self.mapViewModel getGpsSearch] && self.userTrackingMode == MKUserTrackingModeFollow){
        
            [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        }
    }
    
    //精度要求
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //最小移動間隔
    self.locationManager.distanceFilter = 10.0;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if(self.isStartCoordinate){
        
        self.map.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
        
        
        self.locationManager.delegate = nil;
        self.locationManager = nil;
    }

}


#pragma mark - CLLocationManagerDelegate
//認証確認の可否
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // 位置測位スタート
        [self.locationManager startUpdatingLocation];
        self.map.showsUserLocation = YES;
    }
    
    // ユーザが位置情報の使用を許可していない
    else if (status == kCLAuthorizationStatusDenied ) {
        
        if(![[UserDefalutManager sharedManager] getGpsAttention]){
            
            [[UserDefalutManager sharedManager] setGpsAttention:YES];
            [self alertGpsMode];
        }
        
        [self defaultMapPosition];
    }
    
}


#pragma mark - mapViewDelegate
/**
 *  ユーザの位置が特定されてた際に呼ばれるデリゲードメソッド
 *  @param mapView
 *  @param userLocation
 */
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    
    //ピンを配置済みなら
    if(self.isGpsSearchPinView){
        
        //GPSで検索した場合自動更新が走る
        if([self.mapViewModel getGpsSearch]){
            
            //現在地と以前のGPS検索地点の差が1000m超えていれば再検索させる。
            if([self.mapViewModel isUserPointToGpsSerachPointOut]){
                
                [self setPin:YES isReSearch:YES];
                CLLocationCoordinate2D center = self.map.userLocation.coordinate;
                [self controlMapZoom:center isAnimate:YES isReSearch:YES];
                
            } else {
                
                //データだけ更新（現在地と対象駅との距離を更新）
                [self.mapViewModel updateViewdedAnnotationInfo];
                [self setNearInfoBox];
            }
        }
        
    } else {//ピン初期表示
        
        [self setPin:YES isReSearch:NO];
        self.isGpsSearchPinView = YES;
        
        [self createGpsSearchAddTracking];
    }
    
    //初期表示
    if (!self.isStartCoordinate) {
        self.isStartCoordinate = YES;
    }
}

-(void)createGpsSearchAddTracking{
    
    if(self.gpsSearchTimer){
        [self.gpsSearchTimer invalidate];
        self.gpsSearchTimer = nil;
    }
    
    [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    self.gpsSearchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
}

-(void)onTimer:(NSTimer *)timer{
    
    CLLocationCoordinate2D center = self.map.userLocation.coordinate;
    [self controlMapZoom:center isAnimate:NO isReSearch:NO];
}


#pragma mark - MKMapViewDelegate


/**
 *  アノテーションが表示された際のデリゲートメソッド
 *
 *  @param theMapView
 *  @param annotation
 *
 *  @return
 */
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation{

    // 現在地表示なら nil を返す
    if (annotation == self.map.userLocation) {
        return nil;
    }
    
    
    if ( [annotation isKindOfClass:[CustomPointAnnotation class]] ){
        
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation
                                              reuseIdentifier:@"MyCustomAnnotation"];
        
        CustomPointAnnotation *ann = annotation;
        
        
        if([ann.stationId isEqualToString:@"searchMapCenter"]){
            
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = NO;
            customPinView.canShowCallout = YES;
            
        } else{
            
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            customPinView.rightCalloutAccessoryView = rightButton;
            
            if(!ann.isSameStation){
                
                UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage
                                                                                 imageNamed:@"numberingMark"]];
                myCustomImage.image = [myCustomImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                myCustomImage.tintColor = [ [MetroRailwayMasterManager sharedManager] getColorCode:ann.railwayId alphaValue:1];
                
                myCustomImage.bounds = CGRectMake(0, 0, 26, 26);
                
                customPinView.leftCalloutAccessoryView = myCustomImage;
            }
            
            
        }
        
        return customPinView;
    } else {
        return nil;
    }
    
}

/**
 *  アノテーション吹きだしがタップされた際のデリゲートメソッド
 *
 *  @param mapView
 *  @param view
 *  @param control 
 */
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([view.annotation isKindOfClass:[CustomPointAnnotation class]]){
        CustomPointAnnotation *ann = view.annotation;
        
        //同じ駅が複数ある場合
        if(ann.isSameStation){
            
            
            UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
            NearStationListViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"NearStationListViewController"];
            
            vc.nearList = [[self.mapViewModel getSameNearStationList:ann.stationId] mutableCopy];
            vc.isSameStation = YES;
            vc.stationName = ann.stationName;
            
            [self.navigationController pushViewController:vc animated:YES];
            
            return;
        }
        
        
        UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
        MapStationDetailViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"MapStationDetailViewController"];
        
        vc.stationId = ann.stationId;
        vc.stationName = ann.stationName;
        vc.railwayId = ann.railwayId;
        vc.latitude = ann.coordinate.latitude;
        vc.longitude = ann.coordinate.longitude;
        vc.distance = ann.distance;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    
    self.userTrackingMode = mode;
}


#pragma mark - private Method

/**
 *  デフォルトの位置（ユーザがGPSを拒否したならば、初期表示は東京駅になる）
 */
-(void)defaultMapPosition{
    
    CLLocationDegrees latitude = 35.681382;
    CLLocationDegrees logitude = 139.766084;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, logitude);
    [self controlMapZoom:center isAnimate:YES isReSearch:NO];
}

/**
 *  ピンを配置
 */
-(void)setPin:(BOOL)isGps isReSearch:(BOOL) isReSearch{
    
    [self.mapViewModel setGpsSearch:isGps];
    
    [self.map removeAnnotations:self.map.annotations];
    
    NSMutableArray *inRangeList = [self.mapViewModel makeInRangeList:isGps];
    NSArray *sortList = [self.mapViewModel sortList:[inRangeList copy]];
    NSMutableArray *annotations = [self.mapViewModel makeAnnotation:sortList];
    
    [self.map addAnnotations:annotations];
    
    if(!isGps){
        
        /**
         *  センターピンをセット（blocks）
         */
        CustomPointAnnotation* (^setCenterPin)(void) = ^(void){
            CustomPointAnnotation *ann = [[CustomPointAnnotation alloc]init];
            ann.coordinate = CLLocationCoordinate2DMake(self.map.centerCoordinate.latitude,self.map.centerCoordinate.longitude);
            ann.stationId = @"searchMapCenter";
            ann.title = @"検索地点";
            
            return ann;
        };
        
        [self.map addAnnotation:setCenterPin()];
    }

    
    [self setNearInfoBox];
    [self setNoHitSearchAlert:isReSearch];
}

/**
 *  最寄り駅ボックスの情報をセット
 */
-(void)setNearInfoBox{
    
    NSMutableArray *baseAnnotationList = [self.mapViewModel getNearStationList];
    NSArray *sortList = [self.mapViewModel sortList:[baseAnnotationList copy]];
    
    //ピンが配置されている場合
    if(sortList.count > 0){
        
        //最寄り駅を表示
        self.nearLabel.text = sortList[0][@"stationName"];
        self.nearEnLabel.text = sortList[0][@"stationId"];
        
        //最寄り駅までの距離を表示
        self.distanceLabel.text = [ NSString stringWithFormat:@"%@m",sortList[0][@"distance"] ];
        
        
        [self controlViewNearInfo:YES];
        
    } else {
        
        [self controlViewNearInfo:NO];
    }
    
}

/**
 *  検索0件表示
 *
 *  @param isReSearch
 */
-(void)setNoHitSearchAlert:(BOOL)isReSearch{
    
    if(isReSearch) return;
    
    NSMutableArray *annotationList = [self.mapViewModel getNearStationList];
    
    //ピンが配置されていない場合検索0件アラート
    if(annotationList.count == 0){
        
        NSString *title = @"検索結果";
        NSString *message = @"検索地点周辺には\n東京メトロの駅がありませんでした。";
        
        if([self.mapViewModel getGpsSearch]){
            message = @"現在地周辺には\n東京メトロの駅がありませんでした。";
        }
        
        
        
        //IOS8以上なら
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
            
            // コントローラを生成
            UIAlertController * ac = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            // 閉じる用のアクションを生成
            UIAlertAction * closeAction = [UIAlertAction actionWithTitle:@"閉じる"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                 }];
            // コントローラにアクションを追加
            [ac addAction:closeAction];
            
            // アラート表示処理
            [self presentViewController:ac animated:YES completion:nil];
            
        } else {
            
            UIAlertView *uv = [ [UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"閉じる", nil];
            
            [uv show];
            
        }
    }
    
}


/**
 *  最寄り駅の情報の表示を制御
 *
 *  @param isView
 */
-(void)controlViewNearInfo:(BOOL)isView{
    
    self.nearBox.hidden          = !isView;
    self.toNearListButton.hidden = !isView;
}


-(void)alertGpsMode{
    
    //IOS8以上なら
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
        
        // コントローラを生成
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"現在地の取得"
                                                                     message:@"現在地が取得できませんでした。設定 > プライバシー > 位置情報サービス > アプリ名より位置情報の利用を許可してください。"
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        // 閉じる用のアクションを生成
        UIAlertAction * closeAction = [UIAlertAction actionWithTitle:@"閉じる"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        // コントローラにアクションを追加
        [ac addAction:closeAction];
        
        // アラート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    } else {
        
        UIAlertView *uv = [ [UIAlertView alloc] initWithTitle:@"現在地の取得"
                                                      message:@"現在地が取得できませんでした。設定 > プライバシー > 位置情報 > アプリ名より位置情報の利用を許可してください。"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"閉じる", nil];
        
        [uv show];
        
    }
    
}


-(void)gotoNearStationDetail{
    
    NSMutableArray *baseList = [self.mapViewModel getNearStationList];
    NSArray *sortList = [self.mapViewModel sortList:[baseList copy]];
    
    NSMutableDictionary *info = sortList[0];
    
    BOOL isSameStation = [info[@"isSameStation"] boolValue];
    
    //同じ駅が複数ある場合
    if(isSameStation){
        
        UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
        NearStationListViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"NearStationListViewController"];
        
        vc.nearList = [[self.mapViewModel getSameNearStationList:info[@"stationId"]] mutableCopy];
        vc.isSameStation = YES;
        vc.stationName = info[@"stationName"];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    MapStationDetailViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"MapStationDetailViewController"];
    
    vc.stationId = info[@"stationId"];
    vc.stationName = info[@"stationName"];
    vc.railwayId = [info[@"railwayId"] intValue];
    vc.latitude = [info[@"latitude"] floatValue];
    vc.longitude = [info[@"longitude"] floatValue];
    vc.distance = [info[@"distance"] intValue];
    
    [self.navigationController pushViewController:vc animated:YES];        
}


/**
 *  地図のズームをコントロールする
 *
 *  @param center
 */
-(void)controlMapZoom:(CLLocationCoordinate2D)center isAnimate:(BOOL)isAnimate isReSearch:(BOOL)isReSearch{
    
    if(isReSearch){
        return;
    }
    
    MKCoordinateRegion region;
    double rangeDistance = [self.mapViewModel getSearchRangeMeter];
    if(rangeDistance > 0){
        
        region = MKCoordinateRegionMakeWithDistance(center, rangeDistance, rangeDistance);
        
    } else{
        
        region = MKCoordinateRegionMakeWithDistance(center, 50000, 50000);
    }
    [self.map setRegion:region animated:isAnimate];
}


#pragma mark - Event Handler method


/**
 *  gps検索ボタンがタップされた際のイベントハンドラ
 *
 *  @param sender
 */
- (IBAction)onSearchGps:(UIButton *)sender {
    
    // ユーザが位置情報の使用を許可していない
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        [self alertGpsMode];
        
    } else {
        
        [self setPin:YES isReSearch:NO];
        [self createGpsSearchAddTracking];
    }
    
}

/**
 *  中心点で検索ボタンがタップされた際のイベントハンドラ
 *
 *  @param sender
 */
- (IBAction)onSearchMapCenter:(UIButton *)sender {

    [self setPin:NO isReSearch:NO];

    CLLocationCoordinate2D center = self.map.centerCoordinate;
    [self controlMapZoom:center isAnimate:YES isReSearch:NO];
}

/**
 *  最寄り駅一覧へのボタンが押された際のイベントハンドラ
 *
 *  @param sender
 */
- (IBAction)onToNearStationListButton:(UIButton *)sender {
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    NearStationListViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"NearStationListViewController"];
    
    NSMutableArray *baseStationList = [self.mapViewModel getNearStationList];
    NSArray *sortList = [self.mapViewModel sortList:[baseStationList copy]];
    
    vc.nearList = sortList;
//    
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  最寄り駅へのボタンタップ時のイベントハンドラ
 *
 *  @param sender
 */
- (IBAction)onTapNearBoxButton:(UIButton *)sender {
    [self gotoNearStationDetail];
}
@end
