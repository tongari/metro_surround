//
//  MapViewModel.m
//  MetroSurround
//
//  Created by as on 2015/06/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import "MapViewModel.h"
#import <MapKit/MKAnnotationView.h>
#import "StationListMasterManager.h"
#import "CustomPointAnnotation.h"

@interface MapViewModel()

@property(weak,nonatomic)MKMapView* map;
//gpsで検索したポイント
@property(assign,nonatomic)CLLocationCoordinate2D gpsSearchPoint;
//中心点で検索したポイント
@property(assign,nonatomic)CLLocationCoordinate2D centerSearchPoint;
@property(strong,nonatomic)NSMutableArray *annotationList;
@property(assign,nonatomic)BOOL isGpsSearch;

@end

static MapViewModel *sharedManager;

@implementation MapViewModel

+ (MapViewModel *)sharedManager{
    
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


#pragma mark - public method


- (void)initMap:(MKMapView *)map
{
    if(!self.map){
        self.map = map;
        self.isGpsSearch = NO;
    }
}


-(BOOL)getGpsSearch{
    
    return self.isGpsSearch;
}

-(void)setGpsSearch:(BOOL)isGpsSearch{
    self.isGpsSearch = isGpsSearch;
}


/**
 *  範囲内のリストを返却
 *
 *  @param geoList 緯度経度のリスト
 *  @param isGps   GPSからの検索か否か
 *
 *  @return
 */
-(NSMutableArray *)makeInRangeList:(BOOL)isGps{
    
    //東京メトロ全駅を取得
    NSMutableArray *geoList = [[StationListMasterManager sharedManager] getAllData];
    
    //中心の座標
    CLLocationCoordinate2D userCoordinate;
    if(isGps){
        userCoordinate = self.map.userLocation.coordinate;
        
        [self setGpsSearchPoint];
        
    } else {

        userCoordinate = CLLocationCoordinate2DMake(self.map.centerCoordinate.latitude, self.map.centerCoordinate.longitude);
        
        [self setCenterSearchPoint];
        
    }
    MKMapPoint userLocationMapPoint = MKMapPointForCoordinate(userCoordinate);
    
    
    NSMutableArray *inRangeList = [NSMutableArray array];
    
    //座標を走査
    for(int i = 0; i < geoList.count; i++){
        
        NSArray *childGeoList = geoList[i];
        
        for(int j = 0; j< childGeoList.count; j++){
            
            //緯度経度が範囲内かチェック
            if( [self checkInRangePoint:childGeoList[j] isGps:isGps limitMetor:5000.0f] ){
                
                NSMutableDictionary *elment = [NSMutableDictionary dictionary];
                elment[@"lat"] = childGeoList[j][@"Lat"];
                elment[@"long"] = childGeoList[j][@"Long"];
                elment[@"railwayId"] = [NSString stringWithFormat:@"%d",i];
                elment[@"Name"] = childGeoList[j][@"Name"];
                elment[@"ID"] = childGeoList[j][@"ID"];
                
                //チェックする座標
                CLLocationCoordinate2D checkCoordinate = CLLocationCoordinate2DMake(
                                                                                    [childGeoList[j][@"Lat"] floatValue],
                                                                                    [childGeoList[j][@"Long"] floatValue]);
                MKMapPoint checkPoint = MKMapPointForCoordinate(checkCoordinate);
                
                //２点間の距離
                CLLocationDistance distance = MKMetersBetweenMapPoints(checkPoint, userLocationMapPoint);
                
                NSNumber *convertDistance = [NSNumber numberWithFloat:distance];
                elment[@"distance"] = convertDistance;
                [ inRangeList addObject:elment ];
            }
        
        }
    }
    
    return inRangeList;
    
}


/**
 *  中心点より近い順に整列
 *
 *  @param dataArray NSArray
 *
 *  @return NSArray
 */
-(NSArray *)sortList:(NSArray *)dataArray{
    
    //ソート対象となるキーを指定した、NSSortDescriptorの生成
    NSSortDescriptor *sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    
    // NSSortDescriptorは配列に入れてNSArrayに渡す
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
    
    // ソートの実行
    NSArray *sortArray = [dataArray sortedArrayUsingDescriptors:sortDescArray];
    
    return sortArray;
}


/**
 *  アノテーションを作成
 *
 *  @param list
 *
 *  @return
 */
-(NSMutableArray *)makeAnnotation:(NSArray *)list{
    
    NSUInteger originalLen = list.count;    
    NSUInteger len = MIN(list.count,20);
    
    NSMutableArray *result = [NSMutableArray array];
    
    self.annotationList = nil;
    self.annotationList = [NSMutableArray array];
    
    CustomPointAnnotation *annotation;
    
    for(int i = 0; i<len; i++){
        
        annotation = [[CustomPointAnnotation alloc]init];
        //ピンをたてる位置を指定
        annotation.coordinate = CLLocationCoordinate2DMake([list[i][@"lat"] floatValue], [list[i][@"long"] floatValue]);
        
        annotation.stationId = list[i][@"ID"];
        annotation.stationName = list[i][@"Name"];
        annotation.railwayId = [list[i][@"railwayId"] intValue];
        annotation.distance = [list[i][@"distance"] intValue];
        
        NSString *dist = [NSString stringWithFormat:@"およそ%dm先",annotation.distance];
        annotation.subtitle = dist;
        
        NSString *tit = [NSString stringWithFormat:@"%@駅",list[i][@"Name"]];
        annotation.title = tit;
        
        
        if(originalLen > 20){
        
            //配列最初の要素
            if(i == 0){
                
                //後の状態を確認
                if( [ list[i][@"ID"] isEqual:list[i+1][@"ID"] ] ){
                    annotation.isSameStation = YES;
                }
            }
            
            //配列最後の要素
            else if( i == len-1 ){
                
                //前の状態を確認
                if( [ list[i][@"ID"] isEqual:list[i-1][@"ID"] ] ){
                    annotation.isSameStation = YES;
                }
                
                //もし次の要素があれば（20件リミットカットしてるので要素が存在する可能性がある）
                if( i < originalLen-1 ){
                    
                    //後の状態を確認
                    if( [ list[i][@"ID"] isEqual:list[i+1][@"ID"] ] ){
                        annotation.isSameStation = YES;
                        len += 1;
                    }
                }
                
            } else {
                
                //前の状態を確認
                if( [ list[i][@"ID"] isEqual:list[i-1][@"ID"] ] ){
                    annotation.isSameStation = YES;
                }
                //後の状態を確認
                else if( [ list[i][@"ID"] isEqual:list[i+1][@"ID"] ] ){
                    annotation.isSameStation = YES;
                }
                
            }
            
        }
        
        [result addObject:annotation];
    }
    
    
    self.annotationList = result;
    
    return result;
}

/**
 *  ユーザの現在地がGPSでの検索地点より超えたら（以前の検索地点より1000m超えたかどうかを判断）
 */
-(BOOL)isUserPointToGpsSerachPointOut{
    
    if(self.gpsSearchPoint.latitude){
        
        NSDictionary *point = @{
                                @"Lat":[NSNumber numberWithFloat:self.gpsSearchPoint.latitude],
                                @"Long":[NSNumber numberWithFloat:self.gpsSearchPoint.longitude]
                                };
        
        return ![self checkInRangePoint:point isGps:YES limitMetor:1000.0f];
    }
    
    
    return NO;
    
}


/**
 *  表示済みのアノテーションの情報を更新
 */
-(void)updateViewdedAnnotationInfo{
    
    //ユーザ現在地の座標
    CLLocationCoordinate2D userCoordinate = self.map.userLocation.coordinate;
//    CLLocationCoordinate2D userCoordinate = self.map.centerCoordinate;//test用コード
    MKMapPoint userLocationMapPoint = MKMapPointForCoordinate(userCoordinate);
    
    
    //チェックする座標
    CLLocationCoordinate2D checkCoordinate;
    
    CustomPointAnnotation *annotation;
    
    for(int i = 0; i<self.annotationList.count; i++){
        
        annotation = self.annotationList[i];
        
        checkCoordinate = CLLocationCoordinate2DMake(annotation.coordinate.latitude,annotation.coordinate.longitude);
        MKMapPoint checkPoint = MKMapPointForCoordinate(checkCoordinate);
        
        //２点間の距離
        CLLocationDistance distance = MKMetersBetweenMapPoints(checkPoint, userLocationMapPoint);
        
        NSNumber *convertDistance = [NSNumber numberWithFloat:distance];
        annotation.distance = [convertDistance intValue];        
        NSString *dist = [NSString stringWithFormat:@"およそ%dm先",annotation.distance];
        annotation.subtitle = dist;
    }
}

/**
 *  アノテーションリストを返却
 *
 *  @return <#return value description#>
 */
-(NSMutableArray *)getAnntationList{

    
    return self.annotationList;
}


/**
 *  最寄り駅のリストを返却
 *
 *  @return
 */
-(NSMutableArray *)getNearStationList{
    
    NSMutableArray *result = [NSMutableArray array];
    
    CustomPointAnnotation *annotation;
    NSMutableDictionary *element;
    
    for(int i = 0; i<self.annotationList.count; i++){
        
        annotation = self.annotationList[i];
        element = [NSMutableDictionary dictionary];
        
        element[@"stationId"] = annotation.stationId;
        element[@"stationName"] = annotation.stationName;
        element[@"distance"] = [NSNumber numberWithInt:annotation.distance];
        element[@"railwayId"] = [NSNumber numberWithInt:annotation.railwayId];
        element[@"latitude"] = [NSNumber numberWithFloat:annotation.coordinate.latitude];
        element[@"longitude"] = [NSNumber numberWithFloat:annotation.coordinate.longitude];
        element[@"isSameStation"] = [NSNumber numberWithBool:annotation.isSameStation];
        
        [result addObject:element];
    }
    
    return result;
}

-(NSMutableArray *)getSameNearStationList:(NSString *)sameStation{
    
    //同じ駅を抽出
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"stationId", sameStation];
    NSArray *filterList = [self.annotationList filteredArrayUsingPredicate:predicate];
    
    //データを作成して返却
    NSMutableArray *result = [NSMutableArray array];
    CustomPointAnnotation *annotation;
    NSMutableDictionary *element;
    
    for(int i = 0; i < filterList.count; i++){
        
        annotation = filterList[i];
        
        element = [NSMutableDictionary dictionary];
        
        element[@"stationId"] = annotation.stationId;
        element[@"stationName"] = annotation.stationName;
        element[@"distance"] = [NSNumber numberWithInt:annotation.distance];
        element[@"railwayId"] = [NSNumber numberWithInt:annotation.railwayId];
        element[@"latitude"] = [NSNumber numberWithFloat:annotation.coordinate.latitude];
        element[@"longitude"] = [NSNumber numberWithFloat:annotation.coordinate.longitude];
        
        [result addObject:element];
    }
    
    return result;
}

/**
 *  ユーザが検索した条件データを返却
 *
 *  @return
 */
-(NSDictionary *)getUserSearchConditionData{
    
    float lat;
    float lon;
    
    if(self.isGpsSearch){
        
        lat = self.map.userLocation.coordinate.latitude;
        lon = self.map.userLocation.coordinate.longitude;
        
    } else {
        
        lat = self.centerSearchPoint.latitude;
        lon = self.centerSearchPoint.longitude;
        
    }
    
    NSDictionary *result = @{
                             
                             @"lat":[NSNumber numberWithFloat:lat],
                             @"long":[NSNumber numberWithFloat:lon]
                             
                             };
    
    return result;
}

-(double)getSearchRangeMeter{
    
    NSMutableArray *list = [sharedManager getNearStationList];
    double result = 0;
    
    if(list.count >0){
        int nearStationDistance = [list[0][@"distance"] intValue]*2;
        
        result = (double)MAX(nearStationDistance,1500);
    }
    
    
    return result;
}


#pragma mark - private method

/**
 *  範囲内の位置か否かを返す
 *
 *  @param geo
 *
 *  @return
 */
-(BOOL)checkInRangePoint:(NSDictionary *)geo isGps:(BOOL)isGps limitMetor:(float)limitMetor{
    
    //検索対象の座標
    CLLocationCoordinate2D searchPoint = CLLocationCoordinate2DMake([geo[@"Lat"] floatValue], [geo[@"Long"] floatValue]);
    CLLocationDistance searchRadius = limitMetor; // 半径m単位
    MKCircle *searchArea = [MKCircle circleWithCenterCoordinate:searchPoint radius:searchRadius];
    
    //中心の座標
    CLLocationCoordinate2D userCoordinate;
    if(isGps){
        userCoordinate = self.map.userLocation.coordinate;
    } else {
        userCoordinate = CLLocationCoordinate2DMake(self.map.centerCoordinate.latitude, self.map.centerCoordinate.longitude);
    }
    
    //CLLocationCoordinate2D userCoordinate = self.map.userLocation.coordinate;
    MKMapPoint userLocationMapPoint = MKMapPointForCoordinate(userCoordinate);
    
    // パスをオフスクリーン描画
    MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle: searchArea];
    [renderer createPath];
    // ユーザーの座標を CGPoint に変換
    CGPoint userLocationPoint = [renderer pointForMapPoint:userLocationMapPoint];
    
    // ユーザーの座標がパスに含まれるかを判定
    if (CGPathContainsPoint(renderer.path, NULL, userLocationPoint, NO)) {
        
        return YES;
    } else {
        return NO;
    }
}

/**
 *  gpsで検索したポイントを保存する
 */
-(void)setGpsSearchPoint{
    self.gpsSearchPoint = self.map.userLocation.coordinate;
}

/**
 *  中心点で検索したポイントを保存する
 */
-(void)setCenterSearchPoint{
    self.centerSearchPoint = self.map.centerCoordinate;
}




@end
