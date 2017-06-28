//
//  MyLocation.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/6/22.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class AMapPOI;
@class AMapTip;

@interface MyLocation : NSObject<NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *uid;

+ (MyLocation *)locationWithPOI:(AMapPOI *)poi;
+ (MyLocation *)locationWithTip:(AMapTip *)tip city:(NSString *)city;

@end
