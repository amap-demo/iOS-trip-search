//
//  MyLocation.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/6/22.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyLocation.h"
#import <AMapSearchKit/AMapSearchKit.h>

@implementation MyLocation

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        if (aDecoder == nil)
        {
            return self;
        }
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        
        double latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        double longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.address forKey:@"address"];
    
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
}


+ (MyLocation *)locationWithPOI:(AMapPOI *)poi
{
    MyLocation *location = [[MyLocation alloc] init];
    location.name = poi.name;
    location.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    
    location.uid = poi.uid;
    location.city = poi.city;
    location.address = poi.address;
    
    return location;
}

+ (MyLocation *)locationWithTip:(AMapTip *)tip city:(NSString *)city
{
    if (tip.uid.length == 0 || tip.location == nil || tip.address.length == 0) {
        return nil;
    }
    
    MyLocation *location = [[MyLocation alloc] init];
    location.name = tip.name;
    location.coordinate = CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude);
    
    location.uid = tip.uid;
    location.city = city;
    location.address = tip.address;
    
    return location;
}

@end
