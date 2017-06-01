//
//  AddressSettingViewController.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/27.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "AddressSettingViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

#import "MyCityListView.h"
#import "MySearchResultView.h"
#import "MySearchBarView.h"

#import "MyCityManager.h"

#define kTableViewMargin    8
#define kNaviBarHeight      60

@interface AddressSettingViewController ()<AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate>

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) UIButton *titleButton;

@property (nonatomic, strong) UIView *listContainerView;

@property (nonatomic, strong) MyCityListView *cityListView;
@property (nonatomic, strong) MySearchResultView *searchResultView;

@property (nonatomic, strong) MySearchBarView *searchBar;

@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *currentRequest;

@end

@implementation AddressSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    if (_searchTextPlaceholder == nil) {
        _searchTextPlaceholder = @"出入搜索关键字";
    }
    [self initSearch];
    [self initSearchBarView];
    [self initListContainerView];
    
    //update
    [self updateCurrentCity:self.currentCity force:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initialization

- (void)initSearch
{
    //search
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

- (void)initSearchBarView
{
    self.searchBar = [[MySearchBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kNaviBarHeight)];
    self.searchBar.doubleSearchModeEnable = YES;
    self.searchBar.delegate = self;
    self.searchBar.searchTextPlaceholder = _searchTextPlaceholder;
    
    [self.view addSubview:self.searchBar];
}

- (void)initListContainerView
{
    self.listContainerView = [[UIView alloc] initWithFrame:CGRectMake(kTableViewMargin, kTableViewMargin + kNaviBarHeight, self.view.bounds.size.width - kTableViewMargin * 2, self.view.bounds.size.height - kTableViewMargin - kNaviBarHeight)];
    self.listContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.listContainerView.layer.shadowOpacity = 0.3;
    self.listContainerView.layer.shadowOffset = CGSizeMake(0, 0.5);
    [self.view addSubview:self.listContainerView];
    
    
    //
    _cityListView = [[MyCityListView alloc] initWithFrame:self.listContainerView.bounds];
    _cityListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _cityListView.delegate = self;
    
    [self.listContainerView addSubview:_cityListView];
    
    _searchResultView = [[MySearchResultView alloc] initWithFrame:self.listContainerView.bounds];
    _searchResultView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchResultView.delegate = self;
    
    //not show the address setting cell
    _searchResultView.showsAddressSettingCell = NO;
    
    [self.listContainerView addSubview:_searchResultView];
}

#pragma mark - handler

- (void)updateCurrentCity:(MyCity *)currentCity force:(BOOL)force
{
    MyCity *oldCity = self.currentCity;
    
    _currentCity = currentCity;
    
    if (self.search) {
        self.searchBar.seachCity = currentCity;
        
        // 城市改变后，或者需要强制搜索
        if (force || ![oldCity.name isEqualToString:_currentCity.name]) {
            [self searchPoiByKeyword:self.searchBar.currentSearchKeywords city:self.currentCity];
        }
    }
}

- (void)searchPoiByKeyword:(NSString *)keyword city:(MyCity *)city
{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    request.cityLimit = YES;
    
    request.city = city.name;
    
    //TODO: 需要设置location和sortrule
    
    [self.search AMapPOIKeywordsSearch:request];
    
    self.currentRequest = request;
}

#pragma mark - MySearchBarViewDelegate

- (void)searchBarView:(MySearchBarView *)searchBarView didSearchTextChanged:(NSString *)text
{
    if (!self.searchBar.doubleSearchModeEnable) {
        self.cityListView.filterKeywords = text;
    }
    else {
        [self searchPoiByKeyword:text city:self.currentCity];
    }
}

- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextChanged:(NSString *)text
{
    if (self.searchBar.doubleSearchModeEnable) {
        self.cityListView.filterKeywords = text;
    }
}

- (void)didCancelButtonTapped:(MySearchBarView *)searchBarView
{
    if ([self.delegate respondsToSelector:@selector(didCancelButtonTappedForAddressSettingViewController:)]) {
        [self.delegate didCancelButtonTappedForAddressSettingViewController:self];
    }
}

- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextShown:(BOOL)shown
{
    self.searchResultView.hidden = shown;
}

#pragma mark - MyCityListViewDelegate

- (void)cityListView:(MyCityListView *)listView didCitySelected:(MyCity *)city
{
    [self updateCurrentCity:city force:NO];
}

- (void)didCityListViewwScroll:(MyCityListView *)listView
{
    [self.searchBar resignFirstResponder];
}


#pragma mark - MySearchResultViewDelegate

- (void)resultListView:(MySearchResultView *)listView didPOISelected:(AMapPOI *)poi
{
    if ([self.delegate respondsToSelector:@selector(addressSettingViewController:didPOISelected:)]) {
        [self.delegate addressSettingViewController:self didPOISelected:poi];
    }
}

- (void)didResultListViewScroll:(MySearchResultView *)listView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - AMapSearch

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"search error :%@", error);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (self.currentRequest == request) {
        self.searchResultView.poiArray = response.pois;
    }
}

//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    if (response.regeocode == nil) {
//        return;
//    }
//    
//    if ([MyCityManager sharedInstance].locationCity == nil) {
//        [MyCityManager sharedInstance].locationCity = [[MyCity alloc] init];
//        [MyCityManager sharedInstance].locationCity.name = response.regeocode.addressComponent.city;
//        
//        self.cityListView.locationCity = [MyCityManager sharedInstance].locationCity;
//        
//        if ([MyCityManager sharedInstance].currentCity == nil) {
//            [self updateCurrentCity:[MyCityManager sharedInstance].locationCity];
//        }
//        
//    }
//    
//    // just regeo for poi
//    self.locationView.startPOI = response.regeocode.pois.firstObject;
//    [self addPositionAnnotation:self.startAnnotation forPOI:self.locationView.startPOI];
//}

//- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
//{
//    if (response.geocodes.count == 0)
//    {
//        return;
//    }
//    AMapGeocode *geocode = response.geocodes.firstObject;
//    [self searchReGeocodeWithLocation:geocode.location];
//    
//    NSLog(@"move to %@ %@", geocode.city, geocode.location.formattedDescription);
//}

@end
