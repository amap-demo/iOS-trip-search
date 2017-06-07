//
//  AddressSettingViewController.swift
//  iOS-trip-search
//
//  Created by hanxiaoming on 2017/6/5.
//  Copyright © 2017年 Amap. All rights reserved.
//

import UIKit

fileprivate let kTableViewMargin: CGFloat = 8.0
fileprivate let kNaviBarHeight: CGFloat = 60.0

protocol AddressSettingViewControllerDelegate: NSObjectProtocol {
    
    func addressSettingViewController(_ viewController: AddressSettingViewController, didPOISelected poi: AMapPOI!)

    func didCancelButtonTappedForAddressSettingViewController(_ viewController: AddressSettingViewController)
}

class AddressSettingViewController: UIViewController, AMapSearchDelegate, MyCityListViewDelegate, MySearchBarViewDelegate, MySearchResultViewDelegate {

    private var search: AMapSearchAPI!
    private var titleButton: UIButton!
    
    private var listContainerView: UIView!
    private var cityListView: MyCityListView!
    private var searchBar: MySearchBarView!
    private var searchResultView: MySearchResultView!
    
    private var currentRequest: AMapPOIKeywordsSearchRequest?
    
    
    public weak var delegate: AddressSettingViewControllerDelegate?
    public var currentCity: MyCity?
    public var searchTextPlaceholder: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.view.backgroundColor = UIColor.lightGray
        
        if (searchTextPlaceholder == nil) {
            searchTextPlaceholder = "请输入搜索关键字"
        }
        initSearch()
        initSearchBarView()
        initListContainerView()
        
        //update
        updateCurrentCity(self.currentCity, forceSearchPOI: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }

    //MARK: - init
    func initSearch() {
        self.search = AMapSearchAPI()
        self.search.delegate = self
    }
    
    func initSearchBarView() {
        self.searchBar = MySearchBarView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: kNaviBarHeight))
        self.searchBar.doubleSearchModeEnable = true
        self.searchBar.delegate = self
        self.searchBar.searchTextPlaceholder = self.searchTextPlaceholder
        self.view.addSubview(self.searchBar)
    }
    
    func initListContainerView() {
        self.listContainerView = UIView(frame: CGRect(x: kTableViewMargin, y: kTableViewMargin + kNaviBarHeight, width: self.view.bounds.width - kTableViewMargin * 2, height: self.view.bounds.height - kTableViewMargin - kNaviBarHeight))
        
        
        self.listContainerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        
        self.listContainerView.layer.shadowOpacity = 0.3
        self.listContainerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.view.addSubview(self.listContainerView)
        
        //
        self.cityListView = MyCityListView(frame: self.listContainerView.bounds)
        self.cityListView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.cityListView.delegate = self
        
        self.listContainerView.addSubview(self.cityListView)
        
        //
        self.searchResultView = MySearchResultView(frame: self.listContainerView.bounds)
        self.searchResultView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.searchResultView.delegate = self
        self.searchResultView.showsAddressSettingCell = false
        self.listContainerView.addSubview(self.searchResultView)
    }

    //MARK: - handler
    func updateCurrentCity(_ currentCity: MyCity!, forceSearchPOI force: Bool) {
        let oldCity = self.currentCity
        
        self.currentCity = currentCity
        self.searchBar.seachCity = currentCity
        
        // 城市改变后，或者需要强制搜索
        if force || !(oldCity?.name == self.currentCity?.name) {
            self.searchPoiByKeyword(self.searchBar.currentSearchKeywords, inCity: self.currentCity)
        }
        
    }
    
    func searchPoiByKeyword(_ keyword: String?, inCity city: MyCity?) {
        
        let request = MyRecordManager.poiSearchRequest(withKeyword: keyword, in: city)
        search.aMapPOIKeywordsSearch(request)
        currentRequest = request
    }
    
    //MARK: - MySearchBarViewDelegate
    func searchBarView(_ searchBarView: MySearchBarView!, didSearchTextChanged text: String!) {
        if !self.searchBar.doubleSearchModeEnable {
            self.cityListView.filterKeywords = text
        }
        else {
            self.searchPoiByKeyword(text, inCity: self.currentCity)
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
        if delegate != nil {
            delegate?.didCancelButtonTappedForAddressSettingViewController(self)
        }
    }
    
    //MARK: - MyCityListViewDelegate
    
    func cityListView(_ listView: MyCityListView!, didCitySelected city: MyCity!) {
        self.updateCurrentCity(city, forceSearchPOI: false)
    }
    
    func didCityListViewwScroll(_ listView: MyCityListView!) {
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: - MySearchResultViewDelegate
    
    func resultListView(_ listView: MySearchResultView!, didPOISelected poi: AMapPOI!) {
        if delegate != nil {
            delegate?.addressSettingViewController(self, didPOISelected: poi)
        }
    }
    
    func didResultListViewScroll(_ listView: MySearchResultView!) {
        self.searchBar.resignFirstResponder()
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
    
}
