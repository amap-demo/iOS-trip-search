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

//选择城市
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



```

`Swift`
```
func showCityListViewOnlyCity(_ onlyCity: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        cityListView.reset()
        searchResultView.poiArray = nil
        searchBar.doubleSearchModeEnable = !onlyCity
        searchBar.seachCity = MyCityManager.sharedInstance().currentCity
        searchResultView.isHidden = onlyCity
        if !onlyCity {
            updateSearchResultForCurrentCity()
        }
        searchBar.reset()
        searchBar.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.listContainerView.frame = CGRect(x: CGFloat(kTableViewMargin), y: CGFloat(kTableViewMargin + kNaviBarHeight), width: CGFloat(self.listContainerView.frame.size.width), height: CGFloat(self.listContainerView.frame.size.height))
            self.searchBar.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.view.bounds.size.width), height: CGFloat(kNaviBarHeight))
        })
    }

    func hideCityListView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.currentSearchKeywords = nil
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.listContainerView.frame = CGRect(x: CGFloat(kTableViewMargin), y: CGFloat(self.view.bounds.maxY), width: CGFloat(self.listContainerView.frame.size.width), height: CGFloat(self.listContainerView.frame.size.height))
            self.searchBar.frame = CGRect(x: CGFloat(0), y: CGFloat(-kNaviBarHeight), width: CGFloat(self.view.bounds.size.width), height: CGFloat(kNaviBarHeight))
        })

    }

    func cityListView(_ listView: MyCityListView!, didCitySelected city: MyCity!) {
        let oldCity: MyCity? = MyCityManager.sharedInstance().currentCity
        //单独改变当前城市
        if !searchBar.doubleSearchModeEnable {
            //单独改变城市时修改当前城市
            updateCurrentCity(city)
            hideCityListView()
            // 城市改变后清空
            if !(oldCity?.name == city.name) {
                locationView.endPOI = nil
                locationView.startPOI = nil
                // remove
                mapView.removeAnnotation(startAnnotation)
                mapView.removeAnnotation(endAnnotation)
            }
            //如果当前城市是定位城市直接进行当前定位的逆地理，否则进行地理编码获取城市位置。
            if (city.name == MyCityManager.sharedInstance().locationCity.name) {
                mapView.setCenter(mapView.userLocation.location.coordinate, animated: true)
                
                searchReGeocode(withLocation: AMapGeoPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude)))
            }
            
            if (city.name == MyCityManager.sharedInstance().locationCity.name) {
                mapView.setCenter(mapView.userLocation.location.coordinate, animated: true)
                searchReGeocode(withLocation: AMapGeoPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude)))
            }
            else {
                searchGeocode(withName: city.name)
            }
        }
        else {
            if !(oldCity?.name == city.name) {
                searchBar.seachCity = city
                // 只修改搜索city
                updateSearchResultForCurrentCity()
            }
        }
    }


```

