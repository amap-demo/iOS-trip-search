//
//  MyLocationView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMapPOI;

@interface MyLocationView : UIView
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;


@property (nonatomic, strong) AMapPOI *startPOI;
@property (nonatomic, strong) AMapPOI *endPOI;

@end
