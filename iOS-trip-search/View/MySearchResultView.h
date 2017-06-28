//
//  MySearchResultView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyLocation;
@class MySearchResultView;

@protocol MySearchResultViewDelegate <NSObject>
@optional

- (void)resultListView:(MySearchResultView *)listView didPOISelected:(MyLocation *)poi;
- (void)resultListView:(MySearchResultView *)listView didHomeSelected:(MyLocation *)home;
- (void)resultListView:(MySearchResultView *)listView didCompanySelected:(MyLocation *)company;

- (void)didResultListViewScroll:(MySearchResultView *)listView;
@end

@interface MySearchResultView : UIView
@property (nonatomic, weak) id<MySearchResultViewDelegate> delegate;

@property (nonatomic, strong) NSArray<MyLocation *> *poiArray;
@property (nonatomic, strong) NSArray<MyLocation *> *historyArray;

@property (nonatomic, assign) BOOL showsAddressSettingCell; // 默认YES

@property (nonatomic, readonly) MyLocation *home;
@property (nonatomic, readonly) MyLocation *company;

- (void)updateAddressSetting;

@end
