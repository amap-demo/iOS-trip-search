//
//  MySearchBarView.h
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySearchBarView : UIView

//@property (nonatomic, strong) UITextView *searchTextView;
//@property (nonatomic, strong) UITextView *cityTextView;
//@property (nonatomic, strong) UITextView *cityButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
