//
//  MapViewModel.h
//  MetroSurround
//
//  Created by as on 2015/06/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewModel : NSObject

+(MapViewModel *)sharedManager;

- (void)initMap:(MKMapView *)map;
-(NSMutableArray *)makeInRangeList:(BOOL)isGps;
-(NSArray *)sortList:(NSArray *)dataArray;
-(NSMutableArray *)makeAnnotation:(NSArray *)list;
-(BOOL)isUserPointToGpsSerachPointOut;
-(void)updateViewdedAnnotationInfo;
-(NSMutableArray *)getAnntationList;
-(NSMutableArray *)getNearStationList;
-(NSArray *)getSameNearStationList:(NSString *)sameStation;

-(NSDictionary *)getUserSearchConditionData;

-(double)getSearchRangeMeter;

-(BOOL)getGpsSearch;
-(void)setGpsSearch:(BOOL)isGpsSearch;
@end
