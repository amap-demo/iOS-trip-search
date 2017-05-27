//
//  MyLocationHeaderCell.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/26.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyLocationHeaderCell;

@protocol MyLocationHeaderCellDelegate <NSObject>
@optional

- (void)didLocationCellHomeButtonTapped:(MyLocationHeaderCell *)listView;
- (void)didLocationCellCompanyButtonTapped:(MyLocationHeaderCell *)listView;

@end

@interface MyLocationHeaderCell : UITableViewCell

@property (weak, nonatomic) id<MyLocationHeaderCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;

@end
