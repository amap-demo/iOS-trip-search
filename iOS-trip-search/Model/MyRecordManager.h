//
//  MyRecordManager.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/26.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyLocation;
@class MyCity;
@class AMapPOIKeywordsSearchRequest;

@interface MyRecordManager : UIView

+ (instancetype)sharedInstance;

@property (nonatomic, strong) MyLocation *home;
@property (nonatomic, strong) MyLocation *company;
@property (nonatomic, readonly) NSArray<MyLocation *> *historyArray;

- (void)addHistoryRecord:(MyLocation *)location;

- (NSArray<MyLocation *> *)historyArrayFilteredByCityName:(NSString *)city;

- (void)clearHistory;

+ (AMapPOIKeywordsSearchRequest *)POISearchRequestWithKeyword:(NSString *)keyword inCity:(MyCity *)city;

@end
