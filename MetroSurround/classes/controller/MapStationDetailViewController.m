//
//  MapStationDetailViewController.m
//  MetroSurround
//
//  Created by as on 2015/07/01.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapStationDetailViewController.h"
#import <MapKit/MKMapView.h>
#import "MetroRailwayMasterManager.h"
#import <MapKit/MapKit.h>
#import "MapRailwayViewController.h"
#import "MapCarCompositViewController.h"
#import "MapCarCompositModel.h"
#import "MapViewModel.h"
#import <CoreLocation/CoreLocation.h>
#import "Util.h"

@interface MapStationDetailViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) MapCarCompositModel *carCompositModel;

@property (weak, nonatomic) IBOutlet UIButton *stationButton;

@property (weak, nonatomic) IBOutlet UIButton *railwayButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;


- (IBAction)onTapRailwayButton:(UIButton *)sender;
- (IBAction)onTapStationButton:(UIButton *)sender;
- (IBAction)onTapMapButton:(UIButton *)sender;

@end

@implementation MapStationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.carCompositModel = [MapCarCompositModel sharedManager];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    
    self.map.scrollEnabled = NO;
    self.map.zoomEnabled = NO;
    self.map.rotateEnabled = NO;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    MKCoordinateRegion theRegion = MKCoordinateRegionMakeWithDistance(center, 100, 100);
    
    [self.map setRegion:theRegion animated:YES];
    
    MKPointAnnotation *ann = [[MKPointAnnotation alloc]init];
    ann.coordinate = CLLocationCoordinate2DMake(self.latitude,self.longitude);
    
    [self.map addAnnotation:ann];
    
   
    [self.stationButton addTarget:self action:@selector(onTapButtonHighlite:) forControlEvents:UIControlEventTouchDown];
    [self.stationButton addTarget:self action:@selector(onTapButtonReset:) forControlEvents:UIControlEventTouchDragExit];
    [self.railwayButton addTarget:self action:@selector(onTapButtonHighlite:) forControlEvents:UIControlEventTouchDown];
    [self.railwayButton addTarget:self action:@selector(onTapButtonReset:) forControlEvents:UIControlEventTouchDragExit];
    [self.mapButton addTarget:self action:@selector(onTapButtonHighlite:) forControlEvents:UIControlEventTouchDown];
    [self.mapButton addTarget:self action:@selector(onTapButtonReset:) forControlEvents:UIControlEventTouchDragExit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self removeCustomEventNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.alpha = 1;
    self.navigationController.navigationBar.barTintColor = [[MetroRailwayMasterManager sharedManager] getColorCode:self.railwayId                                                                                                           alphaValue:1];
    
    self.navigationItem.title = self.stationName;
    

    NSString *distanceText = [NSString stringWithFormat:@"検索地点からおよそ%dm",self.distance];
    
    self.distanceLabel.text = distanceText;
    
    [self initButtonState];
    
    [self setCustomEventNotification];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeCustomEventNotification];
}


-(void)initButtonState{
    self.stationButton.backgroundColor = [UIColor clearColor];
    self.stationButton.alpha = 1;
    self.railwayButton.backgroundColor = [UIColor clearColor];
    self.railwayButton.alpha = 1;
    self.mapButton.backgroundColor = [UIColor clearColor];
    self.mapButton.alpha = 1;
}


/**
 *  カスタムイベント通知の設定
 */
-(void)setCustomEventNotification{
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onApplicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void)removeCustomEventNotification{

    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

#pragma mark - EventHandler Methdo


-(void)onApplicationDidBecomeActive{
    [self initButtonState];
}

-(void)onTapButtonHighlite:(UIButton *)sender{
    sender.backgroundColor = [UIColor blackColor];
    sender.alpha = 0.2;
}

-(void)onTapButtonReset:(UIButton *)sender{
    sender.backgroundColor = [UIColor clearColor];
    sender.alpha = 1;
}


- (IBAction)onTapRailwayButton:(UIButton *)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    MapRailwayViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MapRailwayViewController"];
    
    vc.pageId = self.railwayId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onTapStationButton:(UIButton *)sender {
    
    NSDictionary *info = @{@"stationId":self.stationId,
                           @"stationName":self.stationName,
                           @"pageId":[NSString stringWithFormat:@"%d",self.railwayId]
                           };
    
    [self.carCompositModel fetchStationDetailData:info];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCompFetchStationDetailData:)
                                                 name:@"ApiConnector.onCompFetchStationDetailData"
                                               object:nil];
}

- (IBAction)onTapMapButton:(UIButton *)sender {
    [self transferMapApp];
}


/**
 *  api通信が完了
 *
 *  @param notification
 */
-(void)onCompFetchStationDetailData:(NSNotification *)notification{
    
    NSDictionary *info = [notification userInfo];
    
    if(info[@"apiData"]){
        
        [self transitionCarCompositVC];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ApiConnector.onCompFetchStationDetailData" object:nil];
}


/**
 *  詳細に遷移
 *
 *  @param info
 */
-(void)transitionCarCompositVC {
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"Detail" bundle:[NSBundle mainBundle]];
    MapCarCompositViewController *vc = [detailStoryBoard instantiateViewControllerWithIdentifier:@"MapCarCompositViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  地図アプリに遷移
 */
-(void)transferMapApp{
    

    MapViewModel *mapViewModel = [MapViewModel sharedManager];
    
    NSDictionary *searhData = [mapViewModel getUserSearchConditionData];
    float lat = [searhData[@"lat"] floatValue];
    float lon = [searhData[@"long"] floatValue];
    
    CLLocation *fromeLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    CLLocation *toLocation = [[CLLocation alloc]initWithLatitude:self.latitude longitude:self.longitude];
    
    CLGeocoder *fromGeocoder = [[CLGeocoder alloc] init];
    CLGeocoder *toGeocoder = [[CLGeocoder alloc] init];
    
    
    __block NSDictionary *fromeAddressOption;
    __block NSDictionary *toAddressOption;
    
    __block int loadCunter = 0;
    
    /**
     *  地図アプリを起動するか判断（blocks）
     *
     *  @return
     */
    void (^judgeInvokeMapApp)(void) = ^(void){
        
        loadCunter++;
        
        if(loadCunter >= 2){
            [self invokeMapApp:fromeAddressOption toAddressOption:toAddressOption];
        }
    };
    
    //現在地（検索地点）の情報を格納
    [fromGeocoder reverseGeocodeLocation:fromeLocation completionHandler:
     ^(NSArray *placemarks, NSError *error){
         
         CLPlacemark *placemark = placemarks.firstObject;
         fromeAddressOption = placemark.addressDictionary;
         
         judgeInvokeMapApp();
     }];
    
    //目的地の情報を格納
    [toGeocoder reverseGeocodeLocation:toLocation completionHandler:
     ^(NSArray *placemarks, NSError *error){
         
         CLPlacemark *placemark = placemarks.firstObject;
         toAddressOption = placemark.addressDictionary;
         
         judgeInvokeMapApp();
     }];
    
    
}

/**
 *  地図アプリ起動
 *
 *  @param fromeAddressOption
 *  @param toAddressOption
 */
-(void)invokeMapApp:(NSDictionary *)fromeAddressOption toAddressOption:(NSDictionary *)toAddressOption {
    
    NSDictionary *searhData = [[MapViewModel sharedManager] getUserSearchConditionData];
    float lat = [searhData[@"lat"] floatValue];
    float lon = [searhData[@"long"] floatValue];
    
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(lat, lon);
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(self.latitude,self.longitude);
    
    // 出発地のPlacemark作成
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc]initWithCoordinate:fromCoordinate addressDictionary:fromeAddressOption];
    // 目的地のPlacemark作成
    MKPlacemark *toPlacemark = [[MKPlacemark alloc]initWithCoordinate:toCoordinate addressDictionary:toAddressOption];
    
    // PlacemarkからMKMapItemを作成
    MKMapItem *fromMapItem = [[MKMapItem alloc]initWithPlacemark:fromPlacemark];
    MKMapItem *toMapItem = [[MKMapItem alloc]initWithPlacemark:toPlacemark];
    
    
    if([[MapViewModel sharedManager] getGpsSearch] ){
        fromMapItem.name = @"現在地";
    } else {
        fromMapItem.name = @"検索地点";
    }
    
    toMapItem.name = [NSString stringWithFormat:@"%@駅", self.stationName];
    
    
    
    // 作成したMKMapItemをNSArrayに格納
    // こうしないとマップアプリに二地点の情報を渡せません
    NSArray     *aryMapItems = [[NSArray alloc]initWithObjects:fromMapItem, toMapItem, nil];
    
    // オプションの指定
    // 今回は徒歩で標準マップを指定します
    NSDictionary    *mapOptionDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                            MKLaunchOptionsDirectionsModeWalking, MKLaunchOptionsDirectionsModeKey,
                                            MKMapTypeStandard,MKLaunchOptionsMapTypeKey
                                            , nil];
    
    // この行が実行されるとマップアプリに値を渡して起動します．
    [MKMapItem openMapsWithItems:aryMapItems launchOptions:mapOptionDictionary];
}


@end
