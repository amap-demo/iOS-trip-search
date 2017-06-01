iOS-trip-search
========================

类似滴滴主界面的搜索功能

### 前述

- 工程基于iOS 地图和搜索SDK实现
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[开发指南](http://lbs.amap.com/api/ios-sdk/summary/).
- 运行demo请先执行pod install --repo-update 安装依赖库，完成后打开.xcworkspace 文件

### 核心类/接口
| 类    | 接口  | 说明   | 版本  |
| -----|:-----:|:-----:|:-----:|
| MyCityManager |  | 城市管理类 |  |
| MyRecordManager | | 记录管理类 |  |
| MySearchBarView | | 自定义搜索控件 |  |
| MyLocationView | | 自定义位置选择控件 |  |


### 核心难点
`Objective-C`
```
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
// poi搜索
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


```

`Swift`
```
暂无
```

