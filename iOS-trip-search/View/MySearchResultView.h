//
//  MySearchResultView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMapPOI;
@class MySearchResultView;

@protocol MySearchResultViewDelegate <NSObject>
@optional

- (void)resultListView:(MySearchResultView *)listView didPOISelected:(AMapPOI *)poi;
- (void)resultListView:(MySearchResultView *)listView didHomeSelected:(AMapPOI *)home;
- (void)resultListView:(MySearchResultView *)listView didCompanySelected:(AMapPOI *)company;

- (void)didResultListViewScroll:(MySearchResultView *)listView;
@end

@interface MySearchResultView : UIView
@property (nonatomic, weak) id<MySearchResultViewDelegate> delegate;

@property (nonatomic, strong) NSArray<AMapPOI *> *poiArray;
@property (nonatomic, strong) NSArray<AMapPOI *> *historyArray;

@property (nonatomic, assign) BOOL showsAddressSettingCell; // 默认YES

@property (nonatomic, readonly) AMapPOI *home;
@property (nonatomic, readonly) AMapPOI *company;

- (void)updateAddressSetting;

@end
