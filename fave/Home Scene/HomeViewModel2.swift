////
////  HomeViewModel.swift
////  FAVE
////
////  Created by Nazih Shoura on 04/07/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//
//
//enum HomeItemKind {
//    case Search
//    case Filter
//    case Listings
//    case Outlets
//    case ListingsCollections
//    
//    var cellHeight : CGFloat {
//        switch self {
//        case .Search:
//            let deviceHeight =  UIScreen.mainHeight
//            return (0.625 * deviceHeight)
//            
//        case .Filter: return 120
//        case .Listings: return 280
//        case .Outlets: return 325
//        case .ListingsCollections: return 330
//            
//        }
//    }
//}
//
//class HomeItem {
//    let itemType: HomeItemKind
//    let item: AnyObject
//    
//    init(itemType: HomeItemKind, item: AnyObject){
//        self.item = item
//        self.itemType = itemType
//    }
//}
//
///**
// *  @author Nazih Shoura
// *
// *  HomeViewModel State
// */
//struct HomeViewModelState {
//    let page: Int
//    let loadedEverything: Bool
//    
//    init (page: Int, loadedEverything: Bool) {
//        self.loadedEverything = loadedEverything
//        self.page = page
//    }
//}
//
///**
// *  @author Nazih Shoura
// *
// *  HomeViewModel
// */
//class HomeViewModel: ViewModel {
//    
//    // MARK:- Dependency
//    private let wireframeService: WireframeService
//    private let listingsAPI: ListingsAPI
//    private let listingsCollectionsAPI: ListingsCollectionsAPI
//    private let outletsSearchAPI: OutletsSearchAPI
//    private let locationService: LocationService
//    private let filterProvider: FilterProvider
//    private let userProvider: UserProvider
//    private let cityProvider: CityProvider
//    let unReviewsAPI: UnReviewsAPI
//    
//    // MARK:- State
//    let state: Variable<HomeViewModelState>
//    
//    // MARK:- Intermediate
//    private let outlets = Variable([Outlet]())
//    private let listings = Variable([Listing]())
//    private let listingsCollections = Variable([ListingsCollection]())
//    private let filters = Variable([FaveFilter]())
//    
//    
//    
//    // MARK:- Constants
//    let listingsPerPage = 30
//    
//    // MARK- Output
//    let homeItems: Driver<[HomeItem]>
//    var unReviews: [Reservation] = [Reservation]()
//    let writeReviewVC = Variable<WriteReviewViewController?>(nil)
//    
//    var needsRefresh = false
//    
//    init(
//        wireframeService: WireframeService = wireframeServiceDefault
//        , listingsAPI: ListingsAPI = ListingsAPIDefault()
//        , listingsCollectionsAPI: ListingsCollectionsAPI = ListingsCollectionsAPIDefault()
//        , outletsSearchAPI: OutletsSearchAPI = OutletsSearchAPIDefault()
//        , state: Variable<HomeViewModelState> = Variable(HomeViewModelState(page: 1, loadedEverything: false))
//        , locationService: LocationService = locationServiceDefault
//        , filterProvider: FilterProvider = FilterProviderDefault()
//        , userProvider: UserProvider = userProviderDefault
//        , cityProvider: CityProvider = cityProviderDefault
//        , unReviewsAPI: UnReviewsAPI = UnReviewsAPIDefault()
//        ){
//        self.listingsAPI = listingsAPI
//        self.wireframeService = wireframeService
//        self.listingsCollectionsAPI = listingsCollectionsAPI
//        self.outletsSearchAPI = outletsSearchAPI
//        self.state = state
//        self.locationService = locationService
//        self.filterProvider = filterProvider
//        self.userProvider = userProvider
//        self.cityProvider = cityProvider
//        self.unReviewsAPI = unReviewsAPI
//        
//        homeItems = Observable
//            .combineLatest(
//                listingsCollections.asObservable()
//                , outlets.asObservable()
//                , listings.asObservable()
//                , filters.asObservable()
//                , resultSelector: {
//                    (listingsCollections, outlets, listings, filters) -> [HomeItem] in
//                    var homeItems = [HomeItem]()
//                    
//                    let searchItem = HomeItem(itemType: .Search, item: "")
//                    homeItems.append(searchItem)
//                    
//                    let filterItem = HomeItem(itemType: .Filter, item: filters)
//                    homeItems.append(filterItem)
//                    
//                    let listingsCollectionsHomeItem = HomeItem(itemType: .ListingsCollections, item:  listingsCollections)
//                    homeItems.append(listingsCollectionsHomeItem)
//                    
//                    let outletsHomeItem = HomeItem(itemType: .Outlets, item: outlets)
//                    homeItems.append(outletsHomeItem)
//                    
//                    let listingsHomeItem = listings.map{ return HomeItem(itemType: .Listings, item:  $0)}
//                    homeItems.appendContentsOf(listingsHomeItem)
//                    
//                    return homeItems
//            }).asDriver(onErrorJustReturn: [HomeItem]())
//        
//        super.init()
//        
//        requestUnReviews()
//        
//        userProvider
//            .currentUser
//            .asObservable()
//            .skip(1)
//            .distinctUntilChanged()
//            .subscribeNext { [weak self] _ in
//                self?.needsRefresh = true
//            }.addDisposableTo(disposeBag)
//        
//        cityProvider
//            .currentCity
//            .asObservable()
//            .filterNil()
//            .skip(1)
//            .distinctUntilChanged()
//            .subscribeNext { [weak self] _ in
//                self?.needsRefresh = true
//            }.addDisposableTo(disposeBag)
//    }
//    
//    /**
//     Load the next page of results of the previously performed search
//     */
//    func loadNextPage() {
//        
//        // Don't hit the API if we have loaded everything
//        if state.value.loadedEverything {
//            return
//        }
//        
//        // Update view model state
//        updateViewModelState(withPage: state.value.page + 1, loadedEverything: state.value.loadedEverything)
//        
//        requestListings()
//    }
//    
//    func requestListings() {
//        let listingsAPIRequestPayload = ListingsAPIRequestPayload(page: state.value.page, limit: listingsPerPage
//            , location: locationService.currentLocation.value
//        )
//        _ = listingsAPI
//            .listings(withRequestPayload: listingsAPIRequestPayload)
//            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
//            .subscribe(
//                onNext: { [weak self] in
//                    guard let strongSelf = self else { return }
//                    strongSelf.listings.value.appendContentsOf($0.listings)
//                    strongSelf.updateViewModelState(withPage: strongSelf.state.value.page, loadedEverything: $0.listings.isEmpty)
//                }, onError: { [weak self] (error) in
//                    self?.wireframeService.alertFor(error, actions: nil)
//                }
//        )
//    }
//
//    func requestListingsCollections() {
//        let listingCollectionRequestPayload = ListingsCollectionsAPIRequestPayload()
//        _ = listingsCollectionsAPI
//            .listingsCollections(withRequestPayload: listingCollectionRequestPayload)
//            .trackActivity(app.activityIndicator)
//            .subscribe(
//                onNext: { [weak self]  in
//                    if let listingsCollectionsAPIResponsePayload = $0.value {
//                        self?.listingsCollections.value = listingsCollectionsAPIResponsePayload.listingsCollections
//                    }
//                    
//                }
//        )
//    }
//
//    func requestOutlets() {
//        let outletSearchAPIRequestPayload = constructOutletsSearchRequestPayload()
//        
//        _ = outletsSearchAPI
//            .searchOutlets(requestPayload: outletSearchAPIRequestPayload)
//            .trackActivity(app.activityIndicator)
//            .subscribe(
//                onNext: { [weak self] in
//                    self?.outlets.value = $0.outlets.shuffle()
//                }
//        )
//    }
//    
//    func requestUnReviews() {
//        let requestPayload = UnReviewsAPIRequestPayload()
//        _ = unReviewsAPI
//            .getUnReview(withRequestPayload: requestPayload)
//            .trackActivity(app.activityIndicator)
//            .subscribeNext(
//                { [weak self] respond in
//                    if let unReviews = respond.value?.unReviews {
//                        self?.unReviews = unReviews
//                        self?.popWriteReviewVC()
//                    }
//                }
//            )
//    }
//
//    func popWriteReviewVC() {
//        if unReviews.count > 0 {
//            let reservation = unReviews.removeFirst()
//            let vm = WriteReviewViewControllerViewModel(reservation: reservation)
//            let vc = WriteReviewViewController.build(vm)
//            writeReviewVC.value = vc
//        }
//    }
//
//    func requestFilter() {
//        _ = filterProvider
//            .currentFilter
//            .asObservable()
//            .filter({ (result) -> Bool in
//                guard let result = result else {return false}
//                return result.count > 0
//            }).subscribeNext(
//                { [weak self] (result) in
//                    if let result = result {
//                        self?.filters.value = result
//                    }
//                }
//            )
//    }
//
//    private func updateViewModelState(withPage page: Int, loadedEverything: Bool) {
//        state.value = HomeViewModelState(page: page, loadedEverything: loadedEverything)
//    }
//    
//    // MARK:- Helper functions
//    /**
//     Construct an OutletsRequestPayload using the current view model state
//     
//     - returns: The constructed OutletRequestPayload
//     */
//    private func constructOutletsSearchRequestPayload() -> OutletsSearchRequestPayload {
//        
//        var latitudeString: String? = nil
//        var longitudeString: String? = nil
//        
//        if let location = locationService.currentLocation.value {
//            latitudeString = String(location.coordinate.latitude)
//            longitudeString = String(location.coordinate.longitude)
//        }
//        let outletsSearchRequestPayload = OutletsSearchRequestPayload(
//            query: ""
//            , orderBy: OutletsOrder.ByFavorited.APIString
//            , latitude: latitudeString
//            , longitude: longitudeString
//            , page: 1
//            , outletsPerPage: 10
//            , radius: nil
//            , excludeFavorited: true
//        )
//        return outletsSearchRequestPayload
//    }
//}
//
//// MARK:- Refreshable
//extension HomeViewModel: Refreshable {
//    func refresh() {
//        
//        state.value = HomeViewModelState(page: 1, loadedEverything: false)
//        
//        listings.value = [Listing]()
//        requestListings()
//        
//        outlets.value = [Outlet]()
//        requestOutlets()
//        
//        listingsCollections.value = [ListingsCollection]()
//        requestListingsCollections()
//        
//        requestFilter()
//    }
//}
//
//// MARK:- Statful
//extension HomeViewModel: Statful {}
