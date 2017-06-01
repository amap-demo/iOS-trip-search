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

#import "MyCityManager.h"
#import "MyRecordManager.h"

#import "MyCityListView.h"
#import "MySearchResultView.h"
#import "MySearchBarView.h"
#import "MyLocationView.h"

#import "AddressSettingViewController.h"

#define kTableViewMargin    8
#define kNaviBarHeight      60
#define kLocationButtonHeight      48

typedef NS_ENUM(NSInteger, CurrentGetLocationType)
{
    CurrentGetLocationTypeStart = 0,
    CurrentGetLocationTypeEnd = 1,
};

typedef NS_ENUM(NSInteger, CurrentAddressSettingType)
{
    CurrentAddressSettingTypeNone = 0,
    CurrentAddressSettingTypeHome = 1,
    CurrentAddressSettingTypeCompany = 2,
};

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate, AddressSettingViewControllerDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UIView *listContainerView;

@property (nonatomic, strong) MyCityListView *cityListView;
@property (nonatomic, strong) MySearchResultView *searchResultView;

@property (nonatomic, strong) MySearchBarView *searchBar;
@property (nonatomic, strong) MyLocationView *locationView;

@property (nonatomic, assign) CurrentGetLocationType currentLocationType;
@property (nonatomic, assign) CurrentAddressSettingType currentAddressSettingType;

@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *currentRequest;

@property (nonatomic, assign) BOOL locationRegeoRequested; //初次定位逆地理是否请求过
@property (nonatomic, assign) BOOL regeoSearchNeeded; //地图每次移动后是否需要进行逆地理请求

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *endAnnotation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self initMapView];
    
    [self initTitleButton];
    [self initSearchBarView];
    
    [self initLocationView];
    [self initListContainerView];
    
    [self initControlButtons];
    
    self.regeoSearchNeeded = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initialization

- (void)initMapView
{
    
    [AMapServices sharedServices].apiKey = @"2979543ece3f8e50843cf4eeff6bd670";
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.rotateCameraEnabled = NO;
    
    self.mapView.runLoopMode = NSDefaultRunLoopMode;
    [self.mapView setShowsUserLocation:YES];
    
    [self.view addSubview:self.mapView];
    
    
    //search
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;

}

- (void)initTitleButton
{
    UIButton *titleButton = [[UIButton alloc] init];
    
    [titleButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    UIImage *image = [UIImage imageNamed:@"down_arrow"];
    [titleButton setImage:image forState:UIControlStateNormal];
    [titleButton sizeToFit];
    
    [titleButton addTarget:self action:@selector(titleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleButton = titleButton;
    self.navigationItem.titleView = titleButton;
    
    [self updateTitleWithString:@"定位中..."];
    
    //
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [self.leftButton sizeToFit];
    
    [self.leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    self.navigationItem.leftBarButtonItem = item1;
    
    self.leftButton.hidden = YES;
}

- (void)initSearchBarView
{
    self.searchBar = [[MySearchBarView alloc] initWithFrame:CGRectMake(0, -kNaviBarHeight, self.view.bounds.size.width, kNaviBarHeight)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.searchBar.delegate = self;
    
    [self.view addSubview:self.searchBar];
}

- (void)initLocationView
{
    self.locationView = [[NSBundle mainBundle] loadNibNamed:@"MyLocationView" owner:nil options:nil].lastObject;
    self.locationView.frame = CGRectMake(0, 0, self.view.bounds.size.width - kTableViewMargin * 2, kLocationButtonHeight * 2);
    
    self.locationView.center = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.bounds) - kLocationButtonHeight - kTableViewMargin);
    
    self.locationView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.locationView];
    
    //
    [self.locationView.startButton addTarget:self action:@selector(startLocationTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.locationView.endButton addTarget:self action:@selector(endLocationTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    //
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setBackgroundColor:[UIColor colorWithRed:0.29 green:0.30 blue:0.35 alpha:1.00]];
    
    [self.confirmButton setTitle:@"确认呼叫" forState:UIControlStateNormal];
    [self.confirmButton setFrame:CGRectMake(0, 0, self.view.bounds.size.width - kTableViewMargin * 2, kLocationButtonHeight)];
    self.confirmButton.center = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.bounds) - kLocationButtonHeight / 2.0 - kTableViewMargin);
    
    [self.confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    
    self.confirmButton.hidden = YES;

}

- (void)initListContainerView
{
    self.listContainerView = [[UIView alloc] initWithFrame:CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.view.bounds.size.width - kTableViewMargin * 2, self.view.bounds.size.height - kTableViewMargin - kNaviBarHeight)];
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
    
    [_searchResultView updateAddressSetting];
    
    [self.listContainerView addSubview:_searchResultView];

}

- (void)initControlButtons
{
    UIButton *buttonSetting = [[UIButton alloc] init];
    [buttonSetting setImage:[UIImage imageNamed:@"icon_setting"] forState:UIControlStateNormal];
    
    [buttonSetting sizeToFit];
    buttonSetting.center = CGPointMake(10 + buttonSetting.bounds.size.width / 2.0, CGRectGetHeight(self.view.bounds) - 120 - buttonSetting.bounds.size.height / 2.0);
    [self.mapView addSubview:buttonSetting];
    
    [buttonSetting addTarget:self action:@selector(onSettingAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //location
    UIButton *buttonLocation = [[UIButton alloc] init];
    [buttonLocation setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [buttonLocation sizeToFit];
    buttonLocation.center = CGPointMake(10 + buttonLocation.bounds.size.width / 2.0, CGRectGetMinY(buttonSetting.frame) - 10 - buttonLocation.bounds.size.height / 2.0);
    [self.mapView addSubview:buttonLocation];
    
    [buttonLocation addTarget:self action:@selector(onLocationAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (MAPointAnnotation *)startAnnotation
{
    if (_startAnnotation == nil) {
        _startAnnotation = [[MAPointAnnotation alloc] init];
        _startAnnotation.title = @"start";
    }
    
    return _startAnnotation;
}

- (MAPointAnnotation *)endAnnotation
{
    if (_endAnnotation == nil) {
        _endAnnotation = [[MAPointAnnotation alloc] init];
        _endAnnotation.title = @"end";
    }
    
    return _endAnnotation;
}

#pragma mark - handler

- (void)prepareForCall
{
    NSLog(@"prepareForCall");
    
    self.startAnnotation.lockedToScreen = NO;
    self.regeoSearchNeeded = NO;
    
    self.leftButton.hidden = NO;
    self.navigationItem.titleView = nil;
    self.title = @"确认呼叫";
    self.confirmButton.hidden = NO;
    self.locationView.hidden = YES;
}

- (void)resetForLocationChooes
{
    NSLog(@"resetForLocationChooes");
    
    self.regeoSearchNeeded = YES;
    self.locationView.endPOI = nil;
    [self addPositionAnnotation:self.endAnnotation forPOI:nil];
    
    self.leftButton.hidden = YES;
    self.navigationItem.titleView = self.titleButton;
    self.confirmButton.hidden = YES;
    self.locationView.hidden = NO;
}

- (void)updateCurrentCity:(MyCity *)currentCity
{
    [MyCityManager sharedInstance].currentCity = currentCity;
    self.searchBar.seachCity = currentCity;
    
    [self updateTitleWithString:currentCity.name];
}

- (void)locatingCurrentCity
{
    if ([MyCityManager sharedInstance].locationCity) {
        return;
    }
    
    if (self.locationRegeoRequested) {
        return;
    }
    
    self.locationRegeoRequested = YES;
    
    [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]];
}

- (void)updateTitleWithString:(NSString *)title
{
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    [self.titleButton sizeToFit];
    
    [self.titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleButton.frame.size.width - self.titleButton.currentImage.size.width, 0, 0)];
    [self.titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.titleButton.currentImage.size.width, 0, self.titleButton.currentImage.size.width)];
    
    NSLog(@"title: %@", title);
}

// 显示搜索&城市列表
- (void)showCityListViewOnlyCity:(BOOL)onlyCity
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.cityListView reset];
    self.searchResultView.poiArray = nil;
    
    self.searchBar.doubleSearchModeEnable = !onlyCity;
    self.searchBar.seachCity = [MyCityManager sharedInstance].currentCity;
    
    self.searchResultView.hidden = onlyCity;
    if (!onlyCity) {
        [self updateSearchResultForCurrentCity];
    }
    
    [self.searchBar reset];
    [self.searchBar becomeFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listContainerView.frame = CGRectMake(kTableViewMargin, kTableViewMargin + kNaviBarHeight, self.listContainerView.frame.size.width, self.listContainerView.frame.size.height);
        
        self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, kNaviBarHeight);
    }];
}

// 隐藏搜索&城市列表
- (void)hideCityListView
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.currentSearchKeywords = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.listContainerView.frame = CGRectMake(kTableViewMargin, CGRectGetMaxY(self.view.bounds), self.listContainerView.frame.size.width, self.listContainerView.frame.size.height);
        
        self.searchBar.frame = CGRectMake(0, -kNaviBarHeight, self.view.bounds.size.width, kNaviBarHeight);
    }];
}

- (void)updateSearchResultForCurrentCity
{
    self.searchResultView.historyArray = [[MyRecordManager sharedInstance] historyArrayFilteredByCityName:self.searchBar.seachCity.name];
    self.searchResultView.poiArray = nil;
    
    [self searchPoiByKeyword:self.searchBar.currentSearchKeywords city:self.searchBar.seachCity];
}

- (void)addPositionAnnotation:(MAPointAnnotation *)annotation forPOI:(AMapPOI *)poi
{
    NSLog(@"add poi :%@", poi.name);
    
    if (poi == nil) {
        [self.mapView removeAnnotation:annotation];
    }
    else {
        AMapGeoPoint *location = poi.location;
        
        // add
        if (annotation == self.startAnnotation && poi.exitLocation != nil) {
            location = poi.exitLocation;
        }
        
        if (annotation == self.endAnnotation && poi.enterLocation != nil) {
            location = poi.enterLocation;
        }
        
        annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        
        [self.mapView addAnnotation:annotation];
    }
    
    if (self.locationView.startPOI && self.locationView.endPOI) {
        [self.mapView showAnnotations:@[self.startAnnotation, self.endAnnotation] edgePadding:UIEdgeInsetsMake(120, 80, 140, 80) animated:YES];
        
        //已经有了起点和终点
        [self prepareForCall];
    }
    else if (self.locationView.startPOI){ // startAnnotation 应该保证一直存在
        [self.mapView showAnnotations:@[self.startAnnotation] animated:NO];
        [self.mapView setZoomLevel:16 animated:YES];
        
        self.startAnnotation.lockedScreenPoint = CGPointMake(CGRectGetMidX(self.mapView.bounds), CGRectGetMidY(self.mapView.bounds));
        self.startAnnotation.lockedToScreen = YES;
    }
}

- (void)setLocationPOI:(AMapPOI *)poi forType:(CurrentGetLocationType)type
{
    if (type == CurrentGetLocationTypeStart) {
        self.locationView.startPOI = poi;
        [self addPositionAnnotation:self.startAnnotation forPOI:poi];
    }
    else {
        self.locationView.endPOI = poi;
        [self addPositionAnnotation:self.endAnnotation forPOI:poi];
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

- (void)searchReGeocodeWithLocation:(AMapGeoPoint *)location
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = location;
    regeo.requireExtension = YES;
    [self.search AMapReGoecodeSearch:regeo];
}

- (void)searchGeocodeWithName:(NSString *)cityName
{
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = cityName;
    geo.city = cityName;
    [self.search AMapGeocodeSearch:geo];
}

#pragma mark - actions

- (void)confirmAction:(UIButton *)sender
{
    NSLog(@"confirm!!!!!");
}

- (void)backAction:(UIButton *)sender
{
    [self resetForLocationChooes];
}

- (void)onLocationAction:(UIButton *)sender
{
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    if (self.regeoSearchNeeded) {
        [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]];
    }
}

- (void)onSettingAction:(UIButton *)sender
{
    NSLog(@"clear the address setting for home & company");
    [MyRecordManager sharedInstance].home = nil;
    [MyRecordManager sharedInstance].company = nil;
    [[MyRecordManager sharedInstance] clearHistory];
    
    [self.searchResultView updateAddressSetting];
}

- (void)startLocationTapped:(UIButton *)sender
{
    self.currentLocationType = CurrentGetLocationTypeStart;
    self.searchBar.searchTextPlaceholder = @"您现在在哪儿";
    
    [self showCityListViewOnlyCity:NO];
}

- (void)endLocationTapped:(UIButton *)sender
{
    self.currentLocationType = CurrentGetLocationTypeEnd;
    self.searchBar.searchTextPlaceholder = @"您要去哪儿";
    
    [self showCityListViewOnlyCity:NO];
}

- (void)titleButtonTapped:(UIButton *)sender
{
    self.searchBar.searchTextPlaceholder = @"请输入出发城市";
    [self showCityListViewOnlyCity:YES];
}

#pragma mark - MySearchBarViewDelegate

- (void)searchBarView:(MySearchBarView *)searchBarView didSearchTextChanged:(NSString *)text
{
    if (!self.searchBar.doubleSearchModeEnable) {
        self.cityListView.filterKeywords = text;
    }
    else {
        [self searchPoiByKeyword:text city:[MyCityManager sharedInstance].currentCity];
        
        //搜索的时候不显示历史记录
        self.searchResultView.historyArray = nil;
        self.searchResultView.poiArray = nil;
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
    [self hideCityListView];
}

- (void)searchBarView:(MySearchBarView *)searchBarView didCityTextShown:(BOOL)shown
{
    self.searchResultView.hidden = shown;
}

#pragma mark - MyCityListViewDelegate

- (void)cityListView:(MyCityListView *)listView didCitySelected:(MyCity *)city
{
    MyCity *oldCity = [MyCityManager sharedInstance].currentCity;
    
    //单独改变当前城市
    if (!self.searchBar.doubleSearchModeEnable) {
        
        //单独改变城市时修改当前城市
        [self updateCurrentCity:city];
        
        [self hideCityListView];
        
        // 城市改变后清空
        if (![oldCity.name isEqualToString:city.name]) {
            self.locationView.endPOI = nil;
            self.locationView.startPOI = nil;
            // remove
            [self.mapView removeAnnotation:self.startAnnotation];
            [self.mapView removeAnnotation:self.endAnnotation];
            
        }
        
        //如果当前城市是定位城市直接进行当前定位的逆地理，否则进行地理编码获取城市位置。
        if ([city.name isEqualToString:[MyCityManager sharedInstance].locationCity.name]) {
            
            [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
            
            [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude]];
        }
        else {
            [self searchGeocodeWithName:city.name];
        }
    }
    else {
        
        if (![oldCity.name isEqualToString:city.name]) {
            self.searchBar.seachCity = city; // 只修改搜索city
            [self updateSearchResultForCurrentCity];
        }
    }
}

- (void)didCityListViewwScroll:(MyCityListView *)listView
{
    [self.searchBar resignFirstResponder];
}


#pragma mark - MySearchResultViewDelegate

- (void)resultListView:(MySearchResultView *)listView didPOISelected:(AMapPOI *)poi
{
    [self setLocationPOI:poi forType:self.currentLocationType];
    [[MyRecordManager sharedInstance] addHistoryRecord:poi];
    
    [self hideCityListView];
}

- (void)resultListView:(MySearchResultView *)listView didHomeSelected:(AMapPOI *)home
{
    if (home) {
        [self setLocationPOI:home forType:self.currentLocationType];
        [self hideCityListView];
    }
    else {
        // set home
        self.currentAddressSettingType = CurrentAddressSettingTypeHome;
        AddressSettingViewController *vc = [[AddressSettingViewController alloc] init];
        vc.delegate = self;
        vc.currentCity = [MyCityManager sharedInstance].locationCity;
        vc.searchTextPlaceholder = @"输入家的地址";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)resultListView:(MySearchResultView *)listView didCompanySelected:(AMapPOI *)company
{
    if (company) {
        [self setLocationPOI:company forType:self.currentLocationType];
        [self hideCityListView];
    }
    else {
        // set company
        self.currentAddressSettingType = CurrentAddressSettingTypeCompany;
        AddressSettingViewController *vc = [[AddressSettingViewController alloc] init];
        vc.delegate = self;
        vc.currentCity = [MyCityManager sharedInstance].locationCity;
        vc.searchTextPlaceholder = @"输入公司地址";
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didResultListViewScroll:(MySearchResultView *)listView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation) {
        return;
    }
    
    [self locatingCurrentCity];
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction
{
    if (!wasUserAction) {
        return;
    }
    if (self.regeoSearchNeeded) {
        self.locationView.startPOI = nil;
    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    if (!wasUserAction) {
        return;
    }
    //移动结束后更新上车点
    if (self.regeoSearchNeeded) {
        [self searchReGeocodeWithLocation:[AMapGeoPoint locationWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
            
            annotationView.canShowCallout = NO;
        }
        
        annotationView.image = (annotation == self.startAnnotation) ? [UIImage imageNamed:@"default_navi_route_startpoint"] : [UIImage imageNamed:@"default_navi_route_endpoint"];

        
        return annotationView;
    }
    
    return nil;

}

#pragma mark - AddressSettingViewControllerDelegate

- (void)addressSettingViewController:(AddressSettingViewController *)viewController didPOISelected:(AMapPOI *)poi
{
    if (self.currentAddressSettingType == CurrentAddressSettingTypeHome) {
        
        [MyRecordManager sharedInstance].home = poi;
    }
    else if (self.currentAddressSettingType == CurrentAddressSettingTypeCompany) {
        [MyRecordManager sharedInstance].company = poi;
    }
    
    [self.searchResultView updateAddressSetting];
    [self.navigationController popViewControllerAnimated:YES];
    self.currentAddressSettingType = CurrentAddressSettingTypeNone;
}

- (void)didCancelButtonTappedForAddressSettingViewController:(AddressSettingViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    self.currentAddressSettingType = CurrentAddressSettingTypeNone;
}


#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"search error :%@", error);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (self.currentRequest == request) {
        self.searchResultView.poiArray = response.pois;
    }
    else {
//        self.searchResultView.poiArray = nil;
    }
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode == nil) {
        return;
    }
    
    if ([MyCityManager sharedInstance].locationCity == nil) {
        [MyCityManager sharedInstance].locationCity = [[MyCity alloc] init];
        
        
        NSString *city = response.regeocode.addressComponent.city;
        
        //TODO: 为了和本地数据源保持一直，去掉“市”。
        if ([city hasSuffix:@"市"]) {
            city = [city substringToIndex:city.length - 1];
        }
        [MyCityManager sharedInstance].locationCity.name = city;
        
        self.cityListView.locationCity = [MyCityManager sharedInstance].locationCity;
        
        if ([MyCityManager sharedInstance].currentCity == nil) {
            [self updateCurrentCity:[MyCityManager sharedInstance].locationCity];
        }

    }
    
    // just regeo for poi
    self.locationView.startPOI = response.regeocode.pois.firstObject;
    [self addPositionAnnotation:self.startAnnotation forPOI:self.locationView.startPOI];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count == 0)
    {
        return;
    }
    AMapGeocode *geocode = response.geocodes.firstObject;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude) animated:YES];
    
    [self searchReGeocodeWithLocation:geocode.location];
    NSLog(@"move to %@ %@", geocode.city, geocode.location.formattedDescription);
    
}

@end
