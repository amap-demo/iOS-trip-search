//
//  MyCityListView.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MyCityListView.h"
#import "MyCityManager.h"

@interface MyCityListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSArray *allCitiesInitialKeys;
@property (nonatomic, strong) NSArray *hotCities;
@property (nonatomic, strong) NSArray *allCities;

@property (nonatomic, strong) NSArray *searchCities;
@end

@implementation MyCityListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.allCitiesInitialKeys = [[MyCityManager sharedInstance].citiesByInitial allKeys];
        self.allCitiesInitialKeys = [self.allCitiesInitialKeys sortedArrayUsingSelector:@selector(compare:)];
        self.allCities = [MyCityManager sharedInstance].allCities;

        //
        self.hotCities = [MyCityManager sharedInstance].hotCities;
        
        [self initTableView];
        
        [self setupPredicate];
    }
    return self;
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
    
    [self addSubview:self.tableView];
    
    //searchTableView
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    
    self.searchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.hidden = YES;
    
    self.searchTableView.tableFooterView = [UIView new];
    
    [self addSubview:self.searchTableView];
}

- (void)setupPredicate
{
    self.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] $KEY OR pinyin CONTAINS[cd] $KEY"];
}

#pragma mark - Interfaces

- (void)reset
{
    [self setFilterKeywords:@""];
    
    self.tableView.contentOffset = CGPointMake(0, 0);
}

- (void)setFilterKeywords:(NSString *)filterKeywords
{
    _filterKeywords = [filterKeywords copy];
    self.searchCities = [self citiesFilterWithKey:_filterKeywords];
    
    [self.searchTableView reloadData];
    self.searchTableView.hidden = self.searchCities.count == 0;
}

- (void)setLocationCity:(MyCity *)locationCity
{
    _locationCity = locationCity;
    
    [self.tableView reloadData];
}

#pragma mark - Handler

- (MyCity *)cityForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    MyCity *selectedCity = nil;
    if (tableView == self.searchTableView) {
        selectedCity = self.searchCities[indexPath.row];
    }
    else {
        if (indexPath.section == 0) {
            selectedCity = self.locationCity;
        }
        else if (indexPath.section == 1)
        {
            selectedCity = self.hotCities[indexPath.row];
        }
        else
        {
            NSString *key = self.allCitiesInitialKeys[indexPath.section - 2];
            NSArray *oneArray = [[MyCityManager sharedInstance].citiesByInitial objectForKey:key];
            selectedCity = oneArray[indexPath.row];
        }
        
    }
    
    return selectedCity;
}

- (NSArray *)citiesFilterWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return nil;
    }
    
    NSPredicate *keyPredicate = [self.predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:key forKey:@"KEY"]];
    
    return [self.allCities filteredArrayUsingPredicate:keyPredicate];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchTableView) {
        return self.searchCities.count;
    }
    else {
        if (section == 0) {
            return 1;
        }
        if (section == 1) {
            return self.hotCities.count;
        }
        else {
            
            NSString *key = self.allCitiesInitialKeys[section - 2];
            NSArray *oneArray = [[MyCityManager sharedInstance].citiesByInitial objectForKey:key];
            
            return oneArray.count;
        }

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchTableView) {
        return 1;
    }
    else {
        return self.allCitiesInitialKeys.count + 2;
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchTableView) {
        return nil;
    }
    else {
        if (section == 0) {
            return nil;
        }
        if (section == 1) {
            return @"★热门城市";
        }
        else {
            return self.allCitiesInitialKeys[section - 2];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    MyCity *selectedCity = [self cityForTableView:tableView atIndexPath:indexPath];
    
    if (tableView == self.tableView && indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"当前定位城市：%@", selectedCity.name];
    }
    else {
        cell.textLabel.text = selectedCity.name;
    }
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == self.searchTableView) {
        return nil;
    }
    else {
        NSMutableArray *indexTitles = [NSMutableArray array];
        [indexTitles addObject:@""];
        [indexTitles addObject:@"★"];
        [indexTitles addObjectsFromArray:self.allCitiesInitialKeys];
        return indexTitles;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MyCity *selectedCity = [self cityForTableView:tableView atIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(cityListView:didCitySelected:)])
    {
        [self.delegate cityListView:self didCitySelected:selectedCity];
    }
}

#pragma mark - 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(didCityListViewwScroll:)])
    {
        [self.delegate didCityListViewwScroll:self];
    }
}

@end
