//
//  MySearchBarView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MySearchBarView;

@protocol MySearchBarViewDelegate <NSObject>
@optional

- (void)searchBarView:(MySearchBarView *)searchBarView didSearchTextChanged:(NSString *)text;
- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextChanged:(NSString *)text;
- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextShown:(BOOL)shown;

- (void)didCancelButtonTapped:(MySearchBarView *)searchBarView;


@end

@interface MySearchBarView : UIView

@property (nonatomic, weak) id<MySearchBarViewDelegate> delegate;

@property (nonatomic, copy) NSString *currentCityName;
@property (nonatomic, copy) NSString *currentSearchKeywords;

@property (nonatomic, copy) NSString *searchTextPlaceholder;

@property (nonatomic, assign) BOOL doubleSearchModeEnable;// 同时有city和关键字搜索，默认为NO。

- (void)reset;

- (void)resignFirstResponder;
- (void)becomeFirstResponder;

@end
