//
//  MyCityManager.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyCity.h"

@interface MyCityManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) MyCity *currentCity; // 当前城市
@property (nonatomic, strong) MyCity *locationCity; // 定位城市

@property (nonatomic, readonly) NSArray<MyCity *> *hotCities;
@property (nonatomic, readonly) NSArray<MyCity *> *allCities;

@property (nonatomic, readonly) NSDictionary<NSString*, NSArray<MyCity *> *> *citiesByInitial;

@end
