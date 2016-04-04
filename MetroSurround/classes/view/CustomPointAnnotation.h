//
//  CustomPointAnnotation.h
//  MetroSurround
//
//  Created by as on 2015/06/29.
//  Copyright (c) 2015年 tongari. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomPointAnnotation : MKPointAnnotation

@property(weak,nonatomic)NSString *stationId;
@property(weak,nonatomic)NSString *stationName;
@property(assign,nonatomic)int railwayId;
@property(assign,nonatomic)int distance;
@property(assign,nonatomic)BOOL isSameStation;

@end
