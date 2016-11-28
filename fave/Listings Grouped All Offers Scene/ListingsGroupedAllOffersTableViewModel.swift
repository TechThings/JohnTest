//
//  ListingsGroupedAllOffersTableViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 11/15/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct ListingsGroupedAllOffersTableViewModelState {
    // MARK:- Constant
    init (
        ) {
    }
}

final class ListingsGroupedAllOffersTableViewModel: ViewModel {

    // MARK:- State
    let state: Variable<ListingsGroupedAllOffersTableViewModelState>

    // MARK:- Dependency
    private let listingsAPI: ListingsAPI
    private let locationService: LocationService

    // MARK:- Variable
    let listings: Variable<[ListingType]> = Variable([ListingType]())
    let outlet: Outlet

    // MARK- Output
    var sectionsModels: Driver<[ListingsGroupedAllOffersTableViewModelSectionModel]> = Driver.of([ListingsGroupedAllOffersTableViewModelSectionModel]())
    let dataSource = RxTableViewSectionedReloadDataSource<ListingsGroupedAllOffersTableViewModelSectionModel>()

    //MARK:- Signal
    let presentViewController = PublishSubject<UIViewController>()
    let pushViewController = PublishSubject<UIViewController>()
    let dismissViewController = PublishSubject<Void>()

    init(
        listingsAPI: ListingsAPI = ListingsAPIDefault(),
        locationService: LocationService = LocationServiceDefault(),
        outlet: Outlet,
        state: ListingsGroupedAllOffersTableViewModelState = ListingsGroupedAllOffersTableViewModelState()
        ) {
        self.listingsAPI = listingsAPI
        self.outlet = outlet
        self.locationService = locationService
        self.state = Variable(state)
        super.init()

        self.sectionsModels = self.listings.asObservable()
            .map({ [weak self] (listings) -> [ListingsGroupedAllOffersTableViewModelSectionModel] in
                guard let strongSelf = self else {
                    return [ListingsGroupedAllOffersTableViewModelSectionModel]()
                }
                var sections = [ListingsGroupedAllOffersTableViewModelSectionModel]()
                var items = [ListingsGroupedAllOffersTableViewModelSectionItem]()
                for listing in listings {
                    let cellViewModel = ListingsGroupedOfferTableViewCellViewModel(listing: listing, outlet: strongSelf.outlet)
                    let listingSectionItem = ListingsGroupedAllOffersTableViewModelSectionItem.OfferSectionItem(viewModel: cellViewModel)
                    items.append(listingSectionItem)
                }
                sections.append(ListingsGroupedAllOffersTableViewModelSectionModel.OfferSection(items: items))
                return sections
            }).asDriver(onErrorJustReturn: [ListingsGroupedAllOffersTableViewModelSectionModel]())

        skinTableViewDataSource(dataSource)

    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<ListingsGroupedAllOffersTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .OfferSectionItem(viewModel):
                let cell: ListingsGroupedOfferTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
            }
        }
    }
}

// MARK:- Refreshable
extension ListingsGroupedAllOffersTableViewModel: Refreshable {
    func refresh() {
        let requestPayload = ListingsAPIRequestPayload(page: 1, limit: 100, order: nil, location: locationService.currentLocation.value, featured: nil, categoryIds: nil, collectionIds: nil, categoryType: nil, listingTypes: nil, favorited_outlet: nil, outletIds: [self.outlet.id], priceRanges: nil, distances: nil)

        let response = listingsAPI
            .getListings(withRequestPayload: requestPayload)

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                })
                })
            .map({ (responsePayload: ListingsAPIResponsePayload) -> [ListingType] in
                responsePayload.listings
            })
            .bindTo(listings)
            .addDisposableTo(disposeBag)

    }
}

extension ListingsGroupedAllOffersTableViewModel: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {
        case .OfferSectionItem(viewModel: let cellViewModel):
            return cellViewModel.cellHeight
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {
        case .OfferSectionItem(viewModel: let cellViewModel):
            let listingViewModel = ListingViewModel(listingId: cellViewModel.listing.id, outletId: outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate()))
            let listingViewController = ListingViewController.build(listingViewModel)
            lightHouseService.navigate.onNext({ (viewController) in
                viewController.navigationController?.pushViewController(listingViewController, animated: true)
            })
        }
    }
}

enum ListingsGroupedAllOffersTableViewModelSectionModel {
    case OfferSection(items: [ListingsGroupedAllOffersTableViewModelSectionItem])
}

extension ListingsGroupedAllOffersTableViewModelSectionModel: SectionModelType {
    typealias Item = ListingsGroupedAllOffersTableViewModelSectionItem

    var items: [ListingsGroupedAllOffersTableViewModelSectionItem] {
        switch  self {
        case .OfferSection(items: let items):
            return items
        }
    }

    init(original: ListingsGroupedAllOffersTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .OfferSection(items: _):
            self = .OfferSection(items: items)
        }
    }
}

enum ListingsGroupedAllOffersTableViewModelSectionItem {
    case OfferSectionItem(viewModel: ListingsGroupedOfferTableViewCellViewModel)
}

// MARK:- Statful
extension ListingsGroupedAllOffersTableViewModel: Statful {}
