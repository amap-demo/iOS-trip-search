//
//  MySearchBarView.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MySearchBarView.h"

#define kControlMargin 10
#define kControlBottomMargin 6

#define kTextFieldHeight 24

@interface MySearchBarView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIFont *searchFieldFont;
@property (nonatomic, strong) UIFont *buttonTitleFont;

@property (nonatomic, strong) UITextField *citySearchView;
@property (nonatomic, strong) UITextField *searchTextView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cityButton;

@end


@implementation MySearchBarView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowOffset = CGSizeMake(0, 0.5);
        _doubleSearchModeEnable = YES;
        
        self.searchFieldFont = [UIFont systemFontOfSize:12];
        self.buttonTitleFont = [UIFont systemFontOfSize:12];
        
        
        self.cancelButton = [[UIButton alloc] init];
        [self.cancelButton.titleLabel setFont:self.buttonTitleFont];
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.cancelButton sizeToFit];
        self.cancelButton.center = CGPointMake(CGRectGetWidth(frame) - kControlMargin - CGRectGetWidth(self.cancelButton.bounds) / 2.0, CGRectGetHeight(frame) - kControlBottomMargin - CGRectGetHeight(self.cancelButton.bounds) / 2.0);
        [self addSubview:self.cancelButton];
        
        [self.cancelButton addTarget:self action:@selector(searchBarCancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.cityButton = [[UIButton alloc] init];
        [self.cityButton.titleLabel setFont:self.buttonTitleFont];
        [self.cityButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.cityButton setImage:[UIImage imageNamed:@"triangle_down"] forState:UIControlStateNormal];
        
        [self updateCityButtonWithTitle:@"定位中"];
        
        self.cityButton.center = CGPointMake(kControlMargin + CGRectGetWidth(self.cityButton.bounds) / 2.0, self.cancelButton.center.y);
        [self addSubview:self.cityButton];
        
        [self.cityButton addTarget:self action:@selector(searchBarCityAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //
        self.citySearchView = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), kTextFieldHeight)];
        [self addSubview:self.citySearchView];
        self.citySearchView.font = self.searchFieldFont;
        self.citySearchView.placeholder = @"城市中文名或拼音";
//        self.citySearchView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        self.citySearchView.delegate = self;
        //
        self.searchTextView = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), kTextFieldHeight)];
        [self addSubview:self.searchTextView];
        self.searchTextView.font = self.searchFieldFont;
        self.searchTextView.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.searchTextView.placeholder = @"您现在在哪";
//        self.searchTextView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        self.searchTextView.delegate = self;
        
        //
        [self setDoubleSearchModeEnable:_doubleSearchModeEnable];
        
        
        [self.cancelButton addTarget:self action:@selector(searchBarCancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.citySearchView.delegate = self;
        
        [self.citySearchView addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.searchTextView addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return self;
}

- (void)setDoubleSearchModeEnable:(BOOL)doubleSearchModeEnable
{
    _doubleSearchModeEnable = doubleSearchModeEnable;
    [self resignFirstResponder];
    
    self.cityButton.hidden = !_doubleSearchModeEnable;
    
    self.citySearchView.hidden = YES;
    
    if (!_doubleSearchModeEnable) {
        self.searchTextView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds) - CGRectGetWidth(self.cancelButton.frame) - kControlMargin * 3, kTextFieldHeight);
        
        self.searchTextView.center = CGPointMake(kControlMargin + CGRectGetWidth(self.searchTextView.bounds) / 2.0, self.cancelButton.center.y);
    }
    else {
        
        [self updateLayoutWithCitySearchShown:!self.citySearchView.hidden animated:NO];
    }
}

- (void)reset
{
    self.citySearchView.text = @"";
    self.searchTextView.text = @"";
    
    [self setDoubleSearchModeEnable:_doubleSearchModeEnable];
}

- (void)resignFirstResponder
{
    [self.searchTextView resignFirstResponder];
    [self.citySearchView resignFirstResponder];
}

- (void)becomeFirstResponder
{
    [self.searchTextView becomeFirstResponder];
}

- (void)setCurrentCityName:(NSString *)currentCityName
{
    _currentCityName = [currentCityName copy];
    [self updateCityButtonWithTitle:_currentCityName];
    
    [self resignFirstResponder];
    
    if (_doubleSearchModeEnable) {
        self.cityButton.hidden = NO;
        self.citySearchView.hidden = YES;
        
        [self updateLayoutWithCitySearchShown:!self.citySearchView.hidden animated:YES];
    }    
}

- (void)updateCityButtonWithTitle:(NSString *)title
{
    [self.cityButton setTitle:title forState:UIControlStateNormal];
    [self.cityButton sizeToFit];
    
    [self.cityButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.cityButton.frame.size.width - self.cityButton.currentImage.size.width, 0, 0)];
    [self.cityButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.cityButton.currentImage.size.width, 0, self.cityButton.currentImage.size.width)];
}

- (NSString *)searchTextPlaceholder
{
    return self.searchTextView.placeholder;
}

- (void)setSearchTextPlaceholder:(NSString *)searchTextPlaceholder
{
    self.searchTextView.placeholder = searchTextPlaceholder;
}

#pragma mark - actions

- (void)updateLayoutWithCitySearchShown:(BOOL)citySearchShown animated:(BOOL)animated
{
    CGFloat width = 0.0;
    CGFloat searchTextLeft = 0.0;
    
    if (citySearchShown) {
        width = (CGRectGetWidth(self.bounds) - CGRectGetWidth(self.cancelButton.frame) - kControlMargin * 4) / 2.0;
        
        self.citySearchView.frame = CGRectMake(0, 0, width, kTextFieldHeight);
        
        self.citySearchView.center = CGPointMake(kControlMargin + CGRectGetWidth(self.citySearchView.bounds) / 2.0, self.cancelButton.center.y);
        
        
        searchTextLeft = CGRectGetMaxX(self.citySearchView.frame);
    }
    else {
        
        width = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.cancelButton.frame) - kControlMargin * 3 - CGRectGetWidth(self.cityButton.frame);
        
        searchTextLeft = CGRectGetMaxX(self.cityButton.frame);
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.searchTextView.frame = CGRectMake(0, 0, width, kTextFieldHeight);
            self.searchTextView.center = CGPointMake(searchTextLeft + kControlMargin + CGRectGetWidth(self.searchTextView.bounds) / 2.0, self.cancelButton.center.y);
        }];
        
    }
    else {
        self.searchTextView.frame = CGRectMake(0, 0, width, kTextFieldHeight);
        self.searchTextView.center = CGPointMake(searchTextLeft + kControlMargin + CGRectGetWidth(self.searchTextView.bounds) / 2.0, self.cancelButton.center.y);
    }
    
    if ([self.delegate respondsToSelector:@selector(searchBarView:didCityTextShown:)]) {
        [self.delegate searchBarView:self didCityTextShown:citySearchShown];
    };
}

- (void)searchBarCancelAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didCancelButtonTapped:)]) {
        [self.delegate didCancelButtonTapped:self];
    };
}

- (void)searchBarCityAction:(UIButton *)sender
{
    self.cityButton.hidden = YES;
    self.citySearchView.hidden = NO;
    
    [self updateLayoutWithCitySearchShown:!self.citySearchView.hidden animated:YES];
    
    [self.citySearchView becomeFirstResponder];
}

- (void)textFieldValueChanged:(UITextField *)textView
{
    if (textView == self.citySearchView) {
        if ([self.delegate respondsToSelector:@selector(searchBarView:didCityTextChanged:)]) {
            [self.delegate searchBarView:self didCityTextChanged:textView.text];
        };
    }
    else if (textView == self.searchTextView) {
        
        self.currentSearchKeywords = textView.text;
        if ([self.delegate respondsToSelector:@selector(searchBarView:didSearchTextChanged:)]) {
            [self.delegate searchBarView:self didSearchTextChanged:textView.text];
        };
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.searchTextView) {
        
        if (_doubleSearchModeEnable) {
            self.cityButton.hidden = NO;
            self.citySearchView.hidden = YES;
            
            [self updateLayoutWithCitySearchShown:!self.citySearchView.hidden animated:YES];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

@end
