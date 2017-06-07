//
//  ViewController.swift
//  iOS-trip-search-swift
//
//  Created by hanxiaoming on 2017/6/5.
//  Copyright © 2017年 Amap. All rights reserved.
//

import UIKit

fileprivate let kTableViewMargin: CGFloat = 8
fileprivate let kNaviBarHeight: CGFloat = 60
fileprivate let kLocationButtonHeight: CGFloat = 48

enum CurrentGetLocationType {
    case start
    case end
}

enum CurrentAddressSettingType {
    case none
    case home
    case company
}

class ViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate, AddressSettingViewControllerDelegate {

    var mapView: MAMapView!
    var search: AMapSearchAPI!
    var titleButton: UIButton!
    var leftButton: UIButton!
    var confirmButton: UIButton!
    
    var listContainerView: UIView!
    var cityListView: MyCityListView!
    var searchBar: MySearchBarView!
    var searchResultView: MySearchResultView!
    var locationView: MyLocationView!
    
    var currentLocationType: CurrentGetLocationType = .start
    var currentAddressSettingType: CurrentAddressSettingType = .none
    
    var locationRegeoRequested: Bool = false
    var regeoSearchNeeded: Bool = true
    
    lazy var startAnnotation: MAPointAnnotation = {
        let startAnno = MAPointAnnotation()
        startAnno.title = "start"
        
        return startAnno
    }()
    
    lazy var endAnnotation: MAPointAnnotation = {
        let anno = MAPointAnnotation()
        anno.title = "end"
        
        return anno
    }()

    
    var currentRequest: AMapPOIKeywordsSearchRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        initMapView()
        initTitleButton()
        initSearchBarView()
        initLocationView()
        initListContainerView()
        initControlButtons()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - init
    
    func initMapView() {
        
        AMapServices.shared().apiKey = "2979543ece3f8e50843cf4eeff6bd670"
        
        self.mapView = MAMapView(frame: self.view.bounds)
        
        self.mapView.delegate = self
        self.mapView.showsScale = false
        self.mapView.showsCompass = false
        self.mapView.isRotateEnabled = false
        self.mapView.isRotateCameraEnabled = false
        
        self.mapView.runLoopMode = RunLoopMode.defaultRunLoopMode
        self.mapView.showsUserLocation = true
        
        self.view.addSubview(self.mapView)

        //
        self.search = AMapSearchAPI()
        self.search.delegate = self
    }

    func initSearchBarView() {
        searchBar = MySearchBarView(frame: CGRect(x: 0, y: -kNaviBarHeight, width: view.bounds.size.width, height: kNaviBarHeight))
        searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    
    func initListContainerView() {
        listContainerView = UIView(frame: CGRect(x: kTableViewMargin, y: view.bounds.maxY, width: view.bounds.size.width - kTableViewMargin * 2, height: view.bounds.size.height - kTableViewMargin - kNaviBarHeight))
        listContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listContainerView.layer.shadowOpacity = 0.3
        listContainerView.layer.shadowOffset = CGSize(width: CGFloat(0), height: CGFloat(0.5))
        view.addSubview(listContainerView)
        
        
        //
        cityListView = MyCityListView(frame: listContainerView.bounds)
        cityListView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        cityListView.delegate = self
        
        listContainerView.addSubview(cityListView)
        
        //
        searchResultView = MySearchResultView(frame: listContainerView.bounds)
        searchResultView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        searchResultView.delegate = self
        
        listContainerView.addSubview(searchResultView)
        
        searchResultView.updateAddressSetting()
        
    }
    
    func initLocationView() {
        
        locationView = Bundle.main.loadNibNamed("MyLocationView", owner: nil, options: nil)!.last as! MyLocationView
        locationView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(view.bounds.size.width - kTableViewMargin * 2), height: CGFloat(kLocationButtonHeight * 2))
        locationView.center = CGPoint(x: CGFloat(view.center.x), y: CGFloat(view.bounds.height - kLocationButtonHeight - kTableViewMargin))
        locationView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(locationView)
        //
        locationView.startButton.addTarget(self, action: #selector(self.startLocationTapped), for: .touchUpInside)
        locationView.endButton.addTarget(self, action: #selector(self.endLocationTapped), for: .touchUpInside)

        //
        confirmButton = UIButton(type: .custom)
        confirmButton.backgroundColor = UIColor(red: CGFloat(0.29), green: CGFloat(0.30), blue: CGFloat(0.35), alpha: CGFloat(1.00))
        confirmButton.setTitle("确认呼叫", for: .normal)
        confirmButton.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(view.bounds.size.width - kTableViewMargin * 2), height: CGFloat(kLocationButtonHeight))
        confirmButton.center = CGPoint(x: CGFloat(view.center.x), y: CGFloat(view.bounds.height - kLocationButtonHeight / 2.0 - kTableViewMargin))
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.isHidden = true
    }
    
    func initTitleButton() {
        let titleButton = UIButton()
        titleButton.setTitleColor(UIColor.darkGray, for: .normal)
        let image = UIImage(named: "down_arrow")
        titleButton.setImage(image, for: .normal)
        titleButton.sizeToFit()
        titleButton.addTarget(self, action: #selector(self.titleButtonTapped), for: .touchUpInside)
        self.titleButton = titleButton
        navigationItem.titleView = titleButton
        updateTitleWithString("定位中...")
        //
        leftButton = UIButton(type: .custom)
        leftButton.setImage(UIImage(named: "icon_back"), for: .normal)
        leftButton.sizeToFit()
        leftButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: leftButton)
        navigationItem.leftBarButtonItem = item1
        leftButton.isHidden = true
    }
    
    func initControlButtons() {
        let buttonSetting = UIButton()
        buttonSetting.setImage(UIImage(named: "icon_setting"), for: .normal)
        buttonSetting.sizeToFit()
        buttonSetting.center = CGPoint(x: CGFloat(10 + buttonSetting.bounds.size.width / 2.0), y: CGFloat(view.bounds.height - 120 - buttonSetting.bounds.size.height / 2.0))
        mapView.addSubview(buttonSetting)
        buttonSetting.addTarget(self, action: #selector(self.onSettingAction), for: .touchUpInside)
        //location
        let buttonLocation = UIButton()
        buttonLocation.setImage(UIImage(named: "icon_location"), for: .normal)
        buttonLocation.sizeToFit()
        buttonLocation.center = CGPoint(x: CGFloat(10 + buttonLocation.bounds.size.width / 2.0), y: CGFloat(buttonSetting.frame.minY - 10 - buttonLocation.bounds.size.height / 2.0))
        mapView.addSubview(buttonLocation)
        buttonLocation.addTarget(self, action: #selector(self.onLocationAction), for: .touchUpInside)
    }
    
    //MARK: - Handler
    
    func prepareForCall() {
        startAnnotation.isLockedToScreen = false
        regeoSearchNeeded = false
        leftButton.isHidden = false
        navigationItem.titleView = nil
        title = "确认呼叫"
        confirmButton.isHidden = false
        locationView.isHidden = true
    }
    
    func resetForLocationChoose() {
        regeoSearchNeeded = true
        locationView.endPOI = nil
        addPositionAnnotation(endAnnotation, forPOI: nil)
        leftButton.isHidden = true
        navigationItem.titleView = titleButton
        confirmButton.isHidden = true
        locationView.isHidden = false
    }

    func locatingCurrentCity() {
        if (MyCityManager.sharedInstance().locationCity != nil) {
            return
        }
        if locationRegeoRequested {
            return
        }
        locationRegeoRequested = true
        searchReGeocode(withLocation: AMapGeoPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude)))
    }

    func updateTitleWithString(_ titleString: String?) {
        titleButton.setTitle(titleString, for: .normal)
        titleButton.sizeToFit()
        titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, titleButton.frame.size.width - titleButton.currentImage!.size.width, 0, 0)
        titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -titleButton.currentImage!.size.width, 0, titleButton.currentImage!.size.width)

    }

    func updateCurrentCity(_ currentCity: MyCity?) {
        MyCityManager.sharedInstance().currentCity = currentCity
        searchBar.seachCity = currentCity
        updateTitleWithString(currentCity?.name)
    }

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

    func updateSearchResultForCurrentCity() {
        searchResultView.historyArray = MyRecordManager.sharedInstance().historyArrayFiltered(byCityName: searchBar.seachCity.name)
        searchResultView.poiArray = nil
        searchPoi(byKeyword: searchBar.currentSearchKeywords, city: searchBar.seachCity)

    }
    
    func addPositionAnnotation(_ annotation: MAPointAnnotation!, forPOI poi:AMapPOI?) {
        if poi == nil {
            mapView.removeAnnotation(annotation)
        }
        else {
            var location: AMapGeoPoint? = poi!.location
            // add
            if annotation == startAnnotation && poi!.exitLocation != nil {
                location = poi!.exitLocation
            }
            if annotation == endAnnotation && poi!.enterLocation != nil {
                location = poi!.enterLocation
            }
            annotation.coordinate = CLLocationCoordinate2DMake(Double(location!.latitude), Double(location!.longitude))
            mapView.addAnnotation(annotation)
        }
        
        if (locationView.startPOI != nil) && (locationView.endPOI != nil) {
            mapView.showAnnotations([startAnnotation, endAnnotation], edgePadding: UIEdgeInsetsMake(120, 80, 140, 80), animated: true)
            //已经有了起点和终点
            prepareForCall()
        }
        else if (locationView.startPOI != nil) {
            // startAnnotation 应该保证一直存在
            mapView.showAnnotations([startAnnotation], animated: false)
            mapView.setZoomLevel(16, animated: true)
            startAnnotation.lockedScreenPoint = CGPoint(x: CGFloat(mapView.bounds.midX), y: CGFloat(mapView.bounds.midY))
            startAnnotation.isLockedToScreen = true
        }

    }
    
    func setLocationPOI(_ poi: AMapPOI?, forType type:CurrentGetLocationType) {
        if type == .start {
            self.locationView.startPOI = poi
            addPositionAnnotation(startAnnotation, forPOI: poi)
        }
        else {
            locationView.endPOI = poi
            addPositionAnnotation(endAnnotation, forPOI: poi)
        }
        
        if (locationView.startPOI != nil) && (locationView.endPOI != nil) {
            mapView.showAnnotations([startAnnotation, endAnnotation], edgePadding: UIEdgeInsetsMake(120, 80, 140, 80), animated: true)
            //已经有了起点和终点
            prepareForCall()
        }
        else if (locationView.startPOI != nil) {
            // startAnnotation 应该保证一直存在
            mapView.showAnnotations([startAnnotation], animated: false)
            mapView.setZoomLevel(16, animated: true)
            startAnnotation.lockedScreenPoint = CGPoint(x: CGFloat(mapView.bounds.midX), y: CGFloat(mapView.bounds.midY))
            startAnnotation.isLockedToScreen = true
        }
    }

    func searchPoi(byKeyword keyword: String?, city: MyCity!) {
        let request = MyRecordManager.poiSearchRequest(withKeyword: keyword, in: city)
        search.aMapPOIKeywordsSearch(request)
        currentRequest = request
    }
    
    func searchReGeocode(withLocation location: AMapGeoPoint!) {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = location
        regeo.requireExtension = true
        search.aMapReGoecodeSearch(regeo)
    }
    
    func searchGeocode(withName cityName: String!) {
        let geo = AMapGeocodeSearchRequest()
        geo.address = cityName
        geo.city = cityName
        search.aMapGeocodeSearch(geo)
    }

    //MARK: - Actions
    func titleButtonTapped(_ sender: UIButton!) {
        self.searchBar.searchTextPlaceholder = "请输入出发城市"
        self.showCityListViewOnlyCity(true)
    }
    
    func confirmAction(_ sender: UIButton!) {
        print("confirmAction");
    }
    
    func backAction(_ sender: UIButton!) {
        self.resetForLocationChoose()
    }
    
    func onLocationAction(_ sender: UIButton!) {
        
        self.mapView.userTrackingMode = MAUserTrackingMode.follow
        if self.regeoSearchNeeded {
            searchReGeocode(withLocation: AMapGeoPoint.location(withLatitude: CGFloat(mapView.userLocation.location.coordinate.latitude), longitude: CGFloat(mapView.userLocation.location.coordinate.longitude)))
        }
    }
    
    func onSettingAction(_ sender: UIButton!) {
        print("clear the address setting for home & company")
        MyRecordManager.sharedInstance().home = nil
        MyRecordManager.sharedInstance().company = nil
        MyRecordManager.sharedInstance().clearHistory()
        searchResultView.updateAddressSetting()
    }
    
    func startLocationTapped(_ sender: UIButton!) {
        currentLocationType = .start
        searchBar.searchTextPlaceholder = "您现在在哪儿"
        showCityListViewOnlyCity(false)
    }
    
    func endLocationTapped(_ sender: UIButton!) {
        currentLocationType = .end
        searchBar.searchTextPlaceholder = "您要去哪儿"
        showCityListViewOnlyCity(false)
    }

    //MARK: - MyCityListViewDelegate
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
    
    func didCityListViewwScroll(_ listView: MyCityListView!) {
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: - MySearchResultViewDelegate
    
    func resultListView(_ listView: MySearchResultView!, didPOISelected poi: AMapPOI!) {
        setLocationPOI(poi, forType: currentLocationType)
        MyRecordManager.sharedInstance().addHistoryRecord(poi)
        hideCityListView()
    }
    
    func resultListView(_ listView: MySearchResultView!, didHomeSelected home: AMapPOI!) {
        if (home != nil) {
            setLocationPOI(home, forType: currentLocationType)
            hideCityListView()
        }
        else {
            // set home
            currentAddressSettingType = .home
            let vc = AddressSettingViewController()
            vc.delegate = self
            vc.currentCity = MyCityManager.sharedInstance().locationCity
            vc.searchTextPlaceholder = "输入家的地址"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func resultListView(_ listView: MySearchResultView!, didCompanySelected company: AMapPOI!) {
        if (company != nil) {
            setLocationPOI(company, forType: currentLocationType)
            hideCityListView()
        }
        else {
            // set company
            currentAddressSettingType = .company
            let vc = AddressSettingViewController()
            vc.delegate = self
            vc.currentCity = MyCityManager.sharedInstance().locationCity
            vc.searchTextPlaceholder = "输入公司地址"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didResultListViewScroll(_ listView: MySearchResultView!) {
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: - MySearchBarViewDelegate
    func searchBarView(_ searchBarView: MySearchBarView!, didSearchTextChanged text: String!) {
        if !searchBar.doubleSearchModeEnable {
            cityListView.filterKeywords = text
        }
        else {
            searchPoi(byKeyword: text, city: MyCityManager.sharedInstance().currentCity)
            //搜索的时候不显示历史记录
            searchResultView.historyArray = nil
            searchResultView.poiArray = nil
        }
    }
    
    func searchBarView(_ searchBarView: MySearchBarView!, didCityTextChanged text: String!) {
        if self.searchBar.doubleSearchModeEnable {
            self.cityListView.filterKeywords = text
        }
    }
    
    func searchBarView(_ searchBarView: MySearchBarView!, didCityTextShown shown: Bool) {
        self.searchResultView.isHidden = shown
    }
    
    func didCancelButtonTapped(_ searchBarView: MySearchBarView!) {
        self.hideCityListView()
    }

    //MARK: - AddressSettingViewControllerDelegate
    func addressSettingViewController(_ viewController: AddressSettingViewController, didPOISelected poi: AMapPOI!) {
        if currentAddressSettingType == .home {
            MyRecordManager.sharedInstance().home = poi
        }
        else if currentAddressSettingType == .company {
            MyRecordManager.sharedInstance().company = poi
        }
        
        searchResultView.updateAddressSetting()
        navigationController?.popViewController(animated: true)
        currentAddressSettingType = .none
    }
    
    func didCancelButtonTappedForAddressSettingViewController(_ viewController: AddressSettingViewController) {
        navigationController?.popViewController(animated: true)
        currentAddressSettingType = .none
    }
    
    //MARK: - AMapSearch
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("search error :\(error)")
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if self.currentRequest != nil && self.currentRequest! == request {
            self.searchResultView.poiArray = response.pois
        }
    }

    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode == nil {
            return
        }
        if MyCityManager.sharedInstance().locationCity == nil {
            MyCityManager.sharedInstance().locationCity = MyCity()
            let originCity: String = response.regeocode.addressComponent.city
            var city = originCity
            //为了和本地数据源保持一直，去掉“市”。
            if originCity.hasSuffix("市") {
                city = originCity.substring(to: originCity.index(before: originCity.endIndex))
            }
            MyCityManager.sharedInstance().locationCity.name = city
            cityListView.locationCity = MyCityManager.sharedInstance().locationCity
            if MyCityManager.sharedInstance().currentCity == nil {
                updateCurrentCity(MyCityManager.sharedInstance().locationCity)
            }
        }
        // just regeo for poi
        locationView.startPOI = response.regeocode.pois.first
        addPositionAnnotation(startAnnotation, forPOI: locationView.startPOI)
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        if response.geocodes.count == 0 {
            return
        }
        let geocode: AMapGeocode! = response.geocodes.first
        mapView.centerCoordinate = CLLocationCoordinate2DMake(Double(geocode.location!.latitude), Double(geocode.location!.longitude))
        
        searchReGeocode(withLocation: geocode?.location)
        print("move to \(String(describing: geocode?.city)) \(String(describing: geocode?.location?.formattedDescription))")
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if !updatingLocation {
            return
        }
        
        self.locatingCurrentCity()
    }
    
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        if self.regeoSearchNeeded {
            self.locationView.startPOI = nil
        }
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        //移动结束后更新上车点
        if regeoSearchNeeded {
            searchReGeocode(withLocation: AMapGeoPoint.location(withLatitude: CGFloat(mapView.centerCoordinate.latitude), longitude: CGFloat(mapView.centerCoordinate.longitude)))
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation is MAUserLocation) {
            return nil
        }
        if (annotation is MAPointAnnotation) {
            let pointReuseIndetifier: String = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier))
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView?.canShowCallout = false
            }
            annotationView?.image = annotation.isEqual(startAnnotation) ? UIImage(named: "default_navi_route_startpoint") : UIImage(named: "default_navi_route_endpoint")
            return annotationView
        }
        return nil
    }
    
}

