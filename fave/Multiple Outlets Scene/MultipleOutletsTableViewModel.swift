//
//  MultipleOutletsTableViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct MultipleOutletsTableViewModelState {
    // MARK:- Constant    
    init (
        ) {
    }
}

final class MultipleOutletsTableViewModel: ViewModel {

    // MARK:- State
    let state: Variable<MultipleOutletsTableViewModelState>

    // MARK:- Dependency
    private let multipleOutletsAPI: MultipleOutletsAPI
    private let outlets = Variable<[Outlet]>([Outlet]())

    // MARK- Output
    let sectionsModels: Driver<[MultipleOutletsTableViewModelSectionModel]>
    let dataSource = RxTableViewSectionedReloadDataSource<MultipleOutletsTableViewModelSectionModel>()

    //MARK:- Signal
    let presentViewController = PublishSubject<UIViewController>()
    let pushViewController = PublishSubject<UIViewController>()
    let dismissViewController = PublishSubject<Void>()
    let listing: ListingType

    init(
        multipleOutletsAPI: MultipleOutletsAPI = MultipleOutletsAPIDefault()
        , listing: ListingType
        , state: MultipleOutletsTableViewModelState = MultipleOutletsTableViewModelState()
        ) {
        self.state = Variable(state)
        self.multipleOutletsAPI = multipleOutletsAPI
        self.listing = listing

        // First Section
        let offerSectionViewModel = MultipleOutletsOfferViewModel(listing: listing)
        let offerSectionItem = MultipleOutletsTableViewModelSectionItem.OfferSectionItem(viewModel: offerSectionViewModel)
        let offerSectionModel = MultipleOutletsTableViewModelSectionModel.OfferSection(items: [offerSectionItem])

        self.sectionsModels = outlets
            .asObservable()
            .map { (outlets: [Outlet]) -> [MultipleOutletsTableViewModelSectionModel] in

                let items = outlets
                    .map { (outlet: Outlet) -> MultipleOutletsTableViewModelSectionItem in
                    MultipleOutletsTableViewModelSectionItem.OutletSectionItem(viewModel: MultipleOutletsOutletViewModel(listing: listing, outlet: outlet))
                }
                let outletSectionModel = MultipleOutletsTableViewModelSectionModel.OutletsSection(items: items)
                return [offerSectionModel, outletSectionModel]
            }
            .asDriver(onErrorJustReturn: [MultipleOutletsTableViewModelSectionModel]())
            .startWith([offerSectionModel])

        super.init()

        skinTableViewDataSource(dataSource)

    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<MultipleOutletsTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .OutletSectionItem(viewModel):
                let cell: MultipleOutletsOutletTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.multipleOutletsOutletView.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .OfferSectionItem(viewModel):
                let cell: MultipleOutletsOfferTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.multipleOutletsOfferView.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
            }
        }
    }

}

extension MultipleOutletsTableViewModel: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {
        case .OfferSectionItem(viewModel: _):
            //return UITableViewAutomaticDimension
            return 90
        case let .OutletSectionItem(viewModel: viewModel):
            //return UITableViewAutomaticDimension
            return viewModel.calculateHeight()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {
        case let .OutletSectionItem(viewModel: viewModel):
            let outletId = viewModel.listing.outlet.id
            let companyId = listing.company.id
            let vm = OutletViewControllerViewModel(outletId: outletId, companyId: companyId)
            let vc = OutletViewController.build(vm)
            lightHouseService.navigate.onNext { (viewController: UIViewController) in
                viewController.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            return
        }
    }
}

// MARK:- Refreshable
extension MultipleOutletsTableViewModel: Refreshable {
    func refresh() {
        let requestPayload = MultipleOutletsAPIRequestPayload(page: nil, limit: 100, location: nil, listingId: listing.id)

        let response = multipleOutletsAPI
            .getMultipleOutlets(withRequestPayload: requestPayload)

        response
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                })
            })
            .map({ (multipleOutletsAPIResponsePayload: MultipleOutletsAPIResponsePayload) -> [Outlet] in
                return multipleOutletsAPIResponsePayload.outlets
            })
            .bindTo(outlets)
            .addDisposableTo(disposeBag)
    }
}

enum MultipleOutletsTableViewModelSectionModel {
    case OfferSection(items: [MultipleOutletsTableViewModelSectionItem])
    case OutletsSection(items: [MultipleOutletsTableViewModelSectionItem])
}

enum MultipleOutletsTableViewModelSectionItem {
    case OfferSectionItem(viewModel: MultipleOutletsOfferViewModel)
    case OutletSectionItem(viewModel: MultipleOutletsOutletViewModel)
}

extension MultipleOutletsTableViewModelSectionModel: SectionModelType {
    typealias Item = MultipleOutletsTableViewModelSectionItem

    var items: [MultipleOutletsTableViewModelSectionItem] {
        switch  self {
        case .OfferSection(items: let items):
            return items
        case .OutletsSection(items: let items):
            return items
        }
    }

    init(original: MultipleOutletsTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .OfferSection(items: _):
            self = .OfferSection(items: items)
        case .OutletsSection(items: _):
            self = .OutletsSection(items: items)
        }
    }
}

// MARK:- Statful
extension MultipleOutletsTableViewModel: Statful {}
