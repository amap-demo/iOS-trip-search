//
//  MyLocationHeaderCell.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/26.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyLocationHeaderCell.h"

@interface MyLocationHeaderCell ()

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *companyButton;

@end

@implementation MyLocationHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onHomeButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didLocationCellHomeButtonTapped:)]) {
        [self.delegate didLocationCellHomeButtonTapped:self];
    }
    
}

- (IBAction)onCompanyButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didLocationCellCompanyButtonTapped:)]) {
        [self.delegate didLocationCellCompanyButtonTapped:self];
    }
}

@end
