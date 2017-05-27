//
//  MyCityListView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MyCity;
@class MyCityListView;

@protocol MyCityListViewDelegate <NSObject>
@optional

- (void)cityListView:(MyCityListView *)listView didCitySelected:(MyCity *)city;
- (void)didCityListViewwScroll:(MyCityListView *)listView;

@end

@interface MyCityListView : UIView
@property (nonatomic, weak) id<MyCityListViewDelegate> delegate;

@property (nonatomic, strong) MyCity *locationCity;
@property (nonatomic, copy) NSString *filterKeywords;

- (void)reset;

@end
