//
//  ViewController.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

#import "MyCityListView.h"
#import "MySearchResultView.h"
#import "MySearchBarView.h"
#import "MyCityManager.h"
#import "MySearchBarView.h"

#define kTableViewMargin    10
#define kNaviBarHeight      60

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate, MyCityListViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) UIButton *titleButton;

@property (nonatomic, strong) MyCityListView *cityListView;
@property (nonatomic, strong) MySearchResultView *searchResultView;

@property (nonatomic, strong) MySearchBarView *searchBar;

@property (nonatomic, strong) MyCity *currentCity;
@property (nonatomic, strong) MyCity *locationCity;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self initMapView];
    
    // init the city list
    [MyCityManager sharedInstance];
    
    [self initTitleButton];
    
    [self locatingCurrentCity];
    
    [self initSearchBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initialization

- (void)initMapView
{
    
    [AMapServices sharedServices].apiKey = @"";
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    
    [self.mapView setShowsUserLocation:YES];
    
    [self.view addSubview:self.mapView];
    
    
    //search
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;

}

- (void)initTitleButton
{
    UIButton *titleButton = [[UIButton alloc] init];
//    titleButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    
    [titleButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    UIImage *image = [UIImage imageNamed:@"down_arrow"];
    [titleButton setImage:image forState:UIControlStateNormal];
    [titleButton sizeToFit];
    
    [titleButton addTarget:self action:@selector(titleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleButton = titleButton;
    self.navigationItem.titleView = titleButton;
    
    [self updateTitleWithString:@"定位中..."];
}

- (void)initSearchBarView
{
    self.searchBar = [[[NSBundle mainBundle] loadNibNamed:@"MySearchBarView" owner:nil options:nil] lastObject];
    
    self.searchBar.frame = CGRectMake(0, -kNaviBarHeight, self.view.bounds.size.width, kNaviBarHeight);
    
    [self.view addSubview:self.searchBar];
    
    [self.searchBar.cancelButton addTarget:self action:@selector(searchBarCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBar.searchTextView addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (MyCityListView *)cityListView
{
    if (_cityListView == nil) {
        _cityListView = [[MyCityListView alloc] initWithFrame:CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.view.bounds.size.width - kTableViewMargin * 2, self.view.bounds.size.height - kTableViewMargin - kNaviBarHeight)];
        
        _cityListView.delegate = self;
        
        [self.view addSubview:_cityListView];
    }
    
    _cityListView.locationCity = self.locationCity;
    return _cityListView;
}

#pragma mark - handler

- (void)locatingCurrentCity
{
    self.locationCity = [[MyCity alloc] init];
    self.locationCity.name = @"北京";
    self.locationCity.pinyin = @"Beijing";
    
    [self updateTitleWithString:self.locationCity.name];
}


- (void)updateTitleWithString:(NSString *)title
{
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    [self.titleButton sizeToFit];
    
    [self.titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleButton.frame.size.width - self.titleButton.currentImage.size.width, 0, 0)];
    [self.titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.titleButton.currentImage.size.width, 0, self.titleButton.currentImage.size.width)];
    
    NSLog(@"title: %@", title);
}

- (void)showCityListView
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.cityListView resetListView];
    self.searchBar.searchTextView.text = @"";
    
    [UIView animateWithDuration:0.3 animations:^{
        self.cityListView.frame = CGRectMake(kTableViewMargin, kTableViewMargin + kNaviBarHeight, self.cityListView.frame.size.width, self.cityListView.frame.size.height);
        
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kNaviBarHeight);
    }];
}

- (void)hideCityListView
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.searchBar.searchTextView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.cityListView.frame = CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.cityListView.frame.size.width, self.cityListView.frame.size.height);
        
        self.searchBar.frame = CGRectMake(0, -kNaviBarHeight, self.view.bounds.size.width, kNaviBarHeight);
    }];
}

#pragma mark - actions

- (void)searchBarCancelAction:(UIButton *)sender
{
    [self hideCityListView];
}

- (void)titleButtonTapped:(UIButton *)sender
{
    [self showCityListView];
}

- (void)textFieldValueChanged:(UITextField *)textView
{
    if (textView == self.searchBar.searchTextView) {
        self.cityListView.filterKeywords = textView.text;
    }
}

#pragma mark - MyCityListViewDelegate

- (void)cityListView:(MyCityListView *)listView didCitySelected:(MyCity *)city
{
    self.currentCity = city;
    [self updateTitleWithString:city.name];
    [self hideCityListView];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation) {
        return;
    }
}

@end
