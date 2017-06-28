//
//  MyLocationView.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyLocationView.h"
#import "MyLocation.h"

@implementation MyLocationView


- (void)setStartLocation:(MyLocation *)startLocation
{
    _startLocation = startLocation;
    
    if (_startLocation) {
        [self.startButton setTitle:_startLocation.name forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [self.startButton setTitle:@"正在获取上车点..." forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}


- (void)setEndLocation:(MyLocation *)endLocation
{
    _endLocation = endLocation;
    
    if (_endLocation) {
        [self.endButton setTitle:_endLocation.name forState:UIControlStateNormal];
        [self.endButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [self.endButton setTitle:@"您要去哪" forState:UIControlStateNormal];
        [self.endButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

@end
