//
//  MyRecordManager.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/26.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMapPOI;

@interface MyRecordManager : UIView

+ (instancetype)sharedInstance;

@property (nonatomic, strong) AMapPOI *home;
@property (nonatomic, strong) AMapPOI *company;
@property (nonatomic, readonly) NSArray<AMapPOI *> *historyArray;

- (void)addHistoryRecord:(AMapPOI *)poi;
- (void)clearHistory;
@end
