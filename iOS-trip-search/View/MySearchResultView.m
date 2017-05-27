//
//  MySearchResultView.m
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/5/24.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MySearchResultView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MyLocationHeaderCell.h"
#import "MyRecordManager.h"

@interface MySearchResultView ()<UITableViewDelegate, UITableViewDataSource, MyLocationHeaderCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AMapPOI *home;
@property (nonatomic, strong) AMapPOI *company;

@end

static NSString *kCellIdentifier = @"cellIdentifier";
static NSString *kLocationCellIdentifier = @"locationCellIdentifier";

@implementation MySearchResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _showsAddressSettingCell = YES;
        [self initTableView];
        
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MyLocationHeaderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kLocationCellIdentifier];
    
    [self addSubview:self.tableView];
    
}

#pragma mark - Interfaces

- (void)setShowsAddressSettingCell:(BOOL)showsAddressSettingCell
{
    _showsAddressSettingCell = showsAddressSettingCell;
    
    [self.tableView reloadData];
}

- (void)setPoiArray:(NSArray<AMapPOI *> *)poiArray
{
    _poiArray = poiArray;
    
    [self.tableView reloadData];
}

- (void)setHistoryArray:(NSArray<AMapPOI *> *)historyArray
{
    _historyArray = historyArray;
    
    [self.tableView reloadData];
}

- (void)updateAddressSetting
{
    _home = [MyRecordManager sharedInstance].home;
    _company = [MyRecordManager sharedInstance].company;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = self.poiArray.count;
    if (result == 1) {
        result += self.historyArray.count;
    }
    
    if (_showsAddressSettingCell) {
        result += 1;
    }
    
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentIdentifier = kCellIdentifier;
    
    if (_showsAddressSettingCell && indexPath.row == 0) {
        currentIdentifier = kLocationCellIdentifier;
        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:currentIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:currentIdentifier];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    if (_showsAddressSettingCell && indexPath.row == 0)
    {
        MyLocationHeaderCell *locationCell = (MyLocationHeaderCell *)cell;
        locationCell.delegate = self;
        locationCell.homeLabel.text = self.home.name ?: @"设置家的地址";
        locationCell.companyLabel.text = self.company.name ?: @"设置公司地址";
    }
    else
    {
        NSInteger poiIndex = indexPath.row;
        if (_showsAddressSettingCell) {
            poiIndex -= 1;
        }
        
        AMapPOI *poi = nil;
        if (self.historyArray.count == 0)
        {
            poi = self.poiArray[poiIndex];
        }
        else
        {
            poi = self.historyArray[poiIndex];
        }
        
        cell.textLabel.text = poi.name;
        cell.detailTextLabel.text = poi.address;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_showsAddressSettingCell && indexPath.row == 0)
    {
        
    }
    else
    {
        NSInteger poiIndex = indexPath.row;
        if (_showsAddressSettingCell) {
            poiIndex -= 1;
        }
        
        AMapPOI *poi = nil;
        if (self.historyArray.count == 0)
        {
            poi = self.poiArray[poiIndex];
        }
        else
        {
            poi = self.historyArray[poiIndex];
        }
        
        if ([self.delegate respondsToSelector:@selector(resultListView:didPOISelected:)])
        {
            [self.delegate resultListView:self didPOISelected:poi];
        }
    }

}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(didResultListViewScroll:)]) {
        [self.delegate didResultListViewScroll:self];
    }
}

#pragma mark - MyLocationHeaderCellDelegate

- (void)didLocationCellHomeButtonTapped:(MyLocationHeaderCell *)listView
{
    if ([self.delegate respondsToSelector:@selector(resultListView:didHomeSelected:)]) {
        [self.delegate resultListView:self didHomeSelected:self.home];
    }
}

- (void)didLocationCellCompanyButtonTapped:(MyLocationHeaderCell *)listView
{
    if ([self.delegate respondsToSelector:@selector(resultListView:didCompanySelected:)]) {
        [self.delegate resultListView:self didCompanySelected:self.company];
    }
}

@end
