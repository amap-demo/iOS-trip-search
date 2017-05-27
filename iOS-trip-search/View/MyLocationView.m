//
//  MyLocationView.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyLocationView.h"
#import <AMapSearchKit/AMapSearchKit.h>

@implementation MyLocationView


- (void)setStartPOI:(AMapPOI *)startPOI
{
    _startPOI = startPOI;
    
    if (_startPOI) {
        [self.startButton setTitle:_startPOI.name forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [self.startButton setTitle:@"您在哪里" forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}


- (void)setEndPOI:(AMapPOI *)endPOI
{
    _endPOI = endPOI;
    
    if (_endPOI) {
        [self.endButton setTitle:_endPOI.name forState:UIControlStateNormal];
        [self.endButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [self.endButton setTitle:@"您要去哪" forState:UIControlStateNormal];
        [self.endButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

@end
