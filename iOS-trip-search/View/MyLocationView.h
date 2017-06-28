//
//  MyLocationView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyLocation;

@interface MyLocationView : UIView
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;


@property (nonatomic, strong) MyLocation *startLocation;
@property (nonatomic, strong) MyLocation *endLocation;

@end
