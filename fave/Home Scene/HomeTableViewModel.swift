//
//  HomeTableViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/**
 *  @author Thanh KFit
 *
 *  HomeTableViewModel
 */
final class HomeTableViewModel: ViewModel {

    // MARK:- Dependency
    private let homeSectionsAPI: HomeSectionsAPI
    private let listingsAPI: ListingsAPI
    private let userProvider: UserProvider

    // MARK:- Intermediate
    private let homeSections = Variable([HomeSection]())
    private let featuredListings = Variable([ListingType]())
    private let viewModels = Variable([HomeHeaderTableViewCellViewModel(), HomeFiltersTableViewCellViewModel()]) // Put the header and the filters first

    // MARK- Output
    let sectionsModels: Driver<[HomeTableViewModelSectionModel]>
    let dataSource = RxTableViewSectionedAnimatedDataSource<HomeTableViewModelSectionModel>()

    init(
        homeSectionsAPI: HomeSectionsAPI = HomeSectionsAPIDefault()
        , listingsAPI: ListingsAPI = ListingsAPIDefault()
        , userProvider: UserProvider = userProviderDefault
        ) {
        self.homeSectionsAPI = homeSectionsAPI
        self.listingsAPI = listingsAPI
        self.userProvider = userProvider

        self.sectionsModels = viewModels
            .asDriver()
            .map { (viewModels: [ViewModel]) -> [HomeTableViewModelSectionModel] in

                var items = [HomeTableViewCellItem]()

                for viewModel in viewModels {
                    if let homeFeaturedOfferTableViewCellViewModel = viewModel as? HomeFeaturedOfferTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomeFeaturedOffer(viewModel: homeFeaturedOfferTableViewCellViewModel))
                    }
                    if let homeHeaderTableViewCellViewModel = viewModel as? HomeHeaderTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomeHeader(viewModel: homeHeaderTableViewCellViewModel))
                    }
                    if let homeFiltersTableViewCellViewModel = viewModel as? HomeFiltersTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomeFilter(viewModel: homeFiltersTableViewCellViewModel))
                    }
                    if let homeCollectionsCarouselTableViewCellViewModel = viewModel as? HomeCollectionsCarouselTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomeCollectionsCarousel(viewModel: homeCollectionsCarouselTableViewCellViewModel))
                    }
                    if let homePartnersCarouselTableViewCellViewModel = viewModel as? HomePartnersCarouselTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomePartnersCarousel(viewModel: homePartnersCarouselTableViewCellViewModel))
                    }
                    if let homeOffersCarouselTableViewCellViewModel = viewModel as? HomeOffersCarouselTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomeOffersCarousel(viewModel: homeOffersCarouselTableViewCellViewModel))
                    }
                    if let homeInviteFriendTableViewCellViewModel = viewModel as? HomeInviteFriendTableViewCellViewModel {
                        items.append(HomeTableViewCellItem.HomeInviteFriend(viewModel: homeInviteFriendTableViewCellViewModel))
                    }
                }

                #if DEBUG
                    let informationViewModel = HomeFaveInformationTableViewCellViewModel()
                    let itemViewModel = HomeTableViewCellItem.HomeFaveInformation(viewModel: informationViewModel)
                    items.append(itemViewModel)
                #endif

                return [HomeTableViewModelSectionModel.HomeCarouselSection(items: items)]
            }

        super.init()

        skinTableViewDataSource(dataSource)
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .None,
                                                                   reloadAnimation: .None,
                                                                   deleteAnimation: .None)

    }

    var token: dispatch_once_t = 0
    func hackPreloadPartnersCarousel(tableView: UITableView, partnetsCarouselViewModel: HomePartnersCarouselTableViewCellViewModel) {
        dispatch_once(&token) {
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.HomePartnersCarouselTableViewCell) as! HomePartnersCarouselTableViewCell
            cell.viewModel = partnetsCarouselViewModel
            cell.layoutIfNeeded()
        }
    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<HomeTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in

            // hack preload partners carousel cell
            let partnetsCarouselViewModel = self.viewModels.value.filter({ (cellViewModel: ViewModel) -> Bool in
                return cellViewModel is HomePartnersCarouselTableViewCellViewModel
            }).first
            if let partnetsCarouselViewModel = partnetsCarouselViewModel as? HomePartnersCarouselTableViewCellViewModel {
                self.hackPreloadPartnersCarousel(tableView, partnetsCarouselViewModel: partnetsCarouselViewModel)
            }

            switch item {
            case let .HomeHeader(viewModel):
                let cell: HomeHeaderTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomeFilter(viewModel):
                let cell: HomeFiltersTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomeOffersCarousel(viewModel):
                let cell: HomeOffersCarouselTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomePartnersCarousel(viewModel):
                let cell: HomePartnersCarouselTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomeCollectionsCarousel(viewModel):
                let cell: HomeCollectionsCarouselTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomeFeaturedOffer(viewModel):
                let cell: HomeFeaturedOfferTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomeInviteFriend(viewModel):
                let cell: HomeInviteFriendTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell

            case let .HomeFaveInformation(viewModel):
                let cell: HomeFaveInformationTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell
            }
        }
    }

}

// MARK:- Refreshable
extension HomeTableViewModel {
    func refresh() {
        let numberOfViewModelsExeculdingHeaderAndFilter = viewModels.value.count - 2
        viewModels.value.removeLast(numberOfViewModelsExeculdingHeaderAndFilter)
        for viewModel in viewModels.value {
            if let refreshable = viewModel as? Refreshable {
                refreshable.refresh()
            }
        }
        requestData()
    }

    func requestData() {
        requestHomeSections()
            .flatMap { (homeSectionsAPIResponsePayload: HomeSectionsAPIResponsePayload) -> Observable<(Int, HomeSection)> in
                return homeSectionsAPIResponsePayload.homeSections.enumerate().toObservable()
            }
            .map { (index: Int, homeSection: HomeSection) -> Observable<ViewModel> in
                switch homeSection.type {
                case .Offers:
                    let homeOffersCarouselTableViewCellViewModel = HomeOffersCarouselTableViewCellViewModel(sectionModel: homeSection)
                    // Return the view model when it's done loading it's data
                    let viewModelsObservable = homeOffersCarouselTableViewCellViewModel
                        .requestData()
                        .map { (response: ResponsePayload) -> [ListingType] in
                            guard let listingsResponse = response as? ListingsAPIResponsePayload else {return [ListingType]()}
                            return listingsResponse.listings
                        }
                        .filterEmpty()
                        .map { _ -> ViewModel in return homeOffersCarouselTableViewCellViewModel }
                        .trackActivity(self.activityIndicator)
                    return viewModelsObservable

                case .Partners:
                    let homePartnersCarouselTableViewCellViewModel = HomePartnersCarouselTableViewCellViewModel(sectionModel: homeSection)
                    // Return the view model when it's done loading it's data
                    let viewModelsObservable =  homePartnersCarouselTableViewCellViewModel
                        .requestData()
                        .map { _ -> ViewModel in return homePartnersCarouselTableViewCellViewModel }
                        .trackActivity(self.activityIndicator)

                    return viewModelsObservable

                case .Collections:
                    let homeCollectionsCarouselTableViewCellViewModel = HomeCollectionsCarouselTableViewCellViewModel(sectionModel: homeSection)
                    // Return the view model when it's done loading it's data
                    let viewModelsObservable =  homeCollectionsCarouselTableViewCellViewModel
                        .requestData()
                        .map { _ -> ViewModel in return homeCollectionsCarouselTableViewCellViewModel }
                        .trackActivity(self.activityIndicator)

                    return viewModelsObservable

                case .Featured:
                    // Return the view model when it's done loading it's data
                    let viewModelsObservable = self
                        .requestListings(withRequestPayload: homeSection.parameters)
                        .map { (HomeFeaturedOfferTableViewCellViewModel) -> ViewModel in
                            return HomeFeaturedOfferTableViewCellViewModel
                        }
                        .trackActivity(self.activityIndicator)

                    return viewModelsObservable
                }
            }
            .concat()
            .doOnCompleted { [weak self] in // Add the Invite Friend
                guard let strongSelf = self else { return }
                if !strongSelf.userProvider.currentUser.value.isGuest {
                    var viewModels = strongSelf.viewModels.value
                    viewModels.append(HomeInviteFriendTableViewCellViewModel())
                    strongSelf.viewModels.value = viewModels
                }
            }
            .subscribeNext { [weak self] (viewModel: ViewModel) in
                guard let strongSelf = self else { return }
                var viewModels = strongSelf.viewModels.value
                viewModels.append(viewModel)
                strongSelf.viewModels.value = viewModels
            }
            .addDisposableTo(disposeBag)
    }

    func requestHomeSections() -> Observable<HomeSectionsAPIResponsePayload> {
        let response = homeSectionsAPI
            .homeSections(withRequestPayload: HomeSectionsAPIRequestPayload())
            .trackActivity(app.activityIndicator) // Tracking the loading of the featured offers as it's one of first thing the user will see
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                }
        }

        return response
    }

    // TAG: Thanh
    // TODO: Pass request payloadobject instead of a dictionary
    func requestListings(withRequestPayload requestPayload: [String: AnyObject]) -> Observable<HomeFeaturedOfferTableViewCellViewModel> {
        let response = listingsAPI
            .getListingsFromDict(parameters: requestPayload)

        let result = response
            .trackActivity(app.activityIndicator) // Tracking the loading of the featured offers as it's one of first thing the user will see
            .trackActivity(activityIndicator)
            .map { (listingsAPIResponsePayload: ListingsAPIResponsePayload) -> [ListingType] in
                return listingsAPIResponsePayload.listings
            }
            .flatMap { (listings: [ListingType]) -> Observable<HomeFeaturedOfferTableViewCellViewModel> in
                listings.toObservable().map { (listing: ListingType) -> HomeFeaturedOfferTableViewCellViewModel in
                    return HomeFeaturedOfferTableViewCellViewModel(featuredListing: listing)
                }
        }

        return result
    }
}

extension HomeTableViewModel: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {
        case .HomeHeader(viewModel: _): return 258
        case let .HomeFilter(viewModel): return self.heightForFilterSection(numberOfCategories: viewModel.filters.value.count)
        case .HomeOffersCarousel(viewModel: _): return 320
        case .HomeCollectionsCarousel(viewModel: _): return 326
        case .HomePartnersCarousel(viewModel: _): return 315
        case .HomeFeaturedOffer(viewModel: _): return 170
        case .HomeInviteFriend: return 290
        case .HomeFaveInformation(viewModel: _): return 80
        }
    }

    func heightForFilterSection(numberOfCategories count: Int) -> CGFloat {
        return HomeFiltersTableViewCellViewModel.heightForFilterSection(numberOfCategories: count)
    }
}

enum HomeTableViewModelSectionModel {
    case HomeCarouselSection(items: [HomeTableViewCellItem])
}

extension HomeTableViewModelSectionModel: AnimatableSectionModelType {
    typealias Item = HomeTableViewCellItem

    var items: [HomeTableViewCellItem] {
        switch  self {
        case .HomeCarouselSection(items: let items):
            return items
        }
    }

    init(original: HomeTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .HomeCarouselSection(items: _):
            self = .HomeCarouselSection(items: items)
        }
    }
    var identity: String {
        switch self {
        case .HomeCarouselSection: return literal.HomeCarouselSection
        }
    }
}

func ==(lhs: HomeTableViewModelSectionModel, rhs: HomeTableViewModelSectionModel) -> Bool {
    let result = lhs.identity == rhs.identity
    return result
}

enum HomeTableViewCellItem: IdentifiableType, Equatable {
    case HomeHeader(viewModel: HomeHeaderTableViewCellViewModel)
    case HomeFilter(viewModel: HomeFiltersTableViewCellViewModel)
    case HomePartnersCarousel(viewModel: HomePartnersCarouselTableViewCellViewModel)
    case HomeCollectionsCarousel(viewModel: HomeCollectionsCarouselTableViewCellViewModel)
    case HomeOffersCarousel(viewModel: HomeOffersCarouselTableViewCellViewModel)
    case HomeFeaturedOffer(viewModel: HomeFeaturedOfferTableViewCellViewModel)
    case HomeInviteFriend(viewModel: HomeInviteFriendTableViewCellViewModel)
    case HomeFaveInformation(viewModel: HomeFaveInformationTableViewCellViewModel)

    var identity: String {
        switch self {
        case let .HomeHeader(viewModel): return viewModel.UUID
        case let .HomeFilter(viewModel): return viewModel.UUID
        case let .HomePartnersCarousel(viewModel): return viewModel.UUID
        case let .HomeCollectionsCarousel(viewModel): return viewModel.UUID
        case let .HomeOffersCarousel(viewModel): return viewModel.UUID
        case let .HomeFeaturedOffer(viewModel): return viewModel.UUID
        case let .HomeInviteFriend(viewModel): return viewModel.UUID
        case let .HomeFaveInformation(viewModel): return viewModel.UUID
        }
    }
}

func ==(lhs: HomeTableViewCellItem, rhs: HomeTableViewCellItem) -> Bool {
    let result = lhs.identity == rhs.identity
    return result
}
