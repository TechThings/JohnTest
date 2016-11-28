//
//  ListingsTableViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 10/28/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation

final class ListingsViewModelState {
    // MARK:- Constant
    let page: Int
    let loadedEverything: Bool
    let categoryType: String
    let order: ListingsOrder?
    let subCategories: [SubCategory]
    let priceRanges: Int?
    let distances: Int?
    let category: Category

    init (page: Int
        , loadedEverything: Bool
        , subCategories: [SubCategory]
        , categoryType: String
        , order: ListingsOrder?
        , priceRanges: Int?
        , distances: Int?
        , category: Category
        ) {
        self.page = page
        self.loadedEverything = loadedEverything
        self.subCategories = subCategories
        self.categoryType = categoryType
        self.order = order
        self.priceRanges = priceRanges
        self.distances = distances
        self.category = category
    }
}

func ==(lhs: ListingsViewModelState, rhs: ListingsViewModelState) -> Bool {
    return lhs.page == rhs.page && lhs.loadedEverything == rhs.loadedEverything && lhs.subCategories == rhs.subCategories && lhs.categoryType == rhs.categoryType && lhs.order == rhs.order && lhs.priceRanges == rhs.priceRanges && lhs.distances == rhs.distances
}

final class ListingsTableViewModel: ViewModel {

    // MARK:- Dependency
    private let listingsAPI: ListingsGroupAPI
    var isLoading = true

    let location: Variable<CLLocation?>

    // MARK:- Constants
    let listingsPerPage = 20

    let functionality: Variable<ListingsViewModelFunctionality>

    // MARK:- State
    let state: Variable<ListingsViewModelState>
    var subCategories = [String]()
    let listings = Variable([ListingsGroup]())
    let isEmpty = Variable(false)
    let isFiltered = Variable(false)
    let footerHidden: Driver<Bool>

    var sectionsModels: Driver<[ListingsTableViewModelSectionModel]> = Driver.of([ListingsTableViewModelSectionModel]())
    let dataSource = RxTableViewSectionedAnimatedDataSource<ListingsTableViewModelSectionModel>()

    init(
        listingsAPI: ListingsGroupAPI = ListingsGroupAPIDefault()
        , functionality: Variable<ListingsViewModelFunctionality>
        , state: ListingsViewModelState
        , location: Variable<CLLocation?>
        ) {
        self.listingsAPI = listingsAPI
        self.state = Variable(state)
        self.functionality = functionality
        self.location = location

        let headerViewModel = ListingsHeaderTableViewCellViewModel(filter: state.category)
        let headerSectionItem = ListingsTableViewModelSectionItem.HeaderSectionItem(viewModel: headerViewModel)
        let headerSection = ListingsTableViewModelSectionModel.HeaderSection(items: [headerSectionItem])

        self.footerHidden = self.state
            .asDriver()
            .map({ (state: ListingsViewModelState) -> Bool in
                return state.loadedEverything
            })
            .distinctUntilChanged()

        super.init()

        self.sectionsModels = Observable.combineLatest(listings.asObservable(), isFiltered.asObservable(), isEmpty.asObservable(), resultSelector: { (listingsGroups: [ListingsGroup], isFiltered: Bool, isEmpty: Bool) -> [ListingsTableViewModelSectionModel] in

            var sections = [ListingsTableViewModelSectionModel]()

            sections.append(headerSection)

            if isFiltered {
                let filterIsOnViewModel = FilterIsOnTableViewCellViewModel(state: state)
                let filterIsOnSectionItem = ListingsTableViewModelSectionItem.FilterOnSectionItem(viewModel: filterIsOnViewModel)
                let filterIsOnSection = ListingsTableViewModelSectionModel.FilterTabSection(items: [filterIsOnSectionItem])
                sections.append(filterIsOnSection)
            } else {
                let filterIsOffViewModel = FilterIsOffTableViewCellViewModel(state: state)
                let filterIsOffSectionItem = ListingsTableViewModelSectionItem.FilterOffSectionItem(viewModel: filterIsOffViewModel)
                let filterIsOffSection = ListingsTableViewModelSectionModel.FilterTabSection(items: [filterIsOffSectionItem])
                sections.append(filterIsOffSection)
            }

            if isEmpty {
                let emptyViewModel = MyFaveEmptyResultTableViewCellViewModel(message: NSLocalizedString("no_offers", comment: ""), details: NSLocalizedString("choose_another_category", comment: ""))
                let emptyResultSectionItem = ListingsTableViewModelSectionItem.ListingEmptySectionItem(viewModel: emptyViewModel)
                let emptyResultSection = ListingsTableViewModelSectionModel.ListingsSection(items: [emptyResultSectionItem])
                sections.append(emptyResultSection)
            } else {
                for listingsGroup in listingsGroups {
                    var items = [ListingsTableViewModelSectionItem]()

                    let outlet = listingsGroup.outlet
                    let outletViewModel = ListingsGroupedOutletTableViewCellViewModel(outlet: outlet)
                    let outletSectionItem = ListingsTableViewModelSectionItem.OutletSectionItem(viewModel: outletViewModel)
                    items.append(outletSectionItem)

                    for index in 0...listingsGroup.rowDisplayNumber - 1 {
                        if let listing = listingsGroup.listings[safe: index] {
                            let offerViewModel = ListingsGroupedOfferTableViewCellViewModel(listing: listing, outlet: outlet)
                            let offerSectionItem = ListingsTableViewModelSectionItem.OfferSectionItem(viewModel: offerViewModel)
                            items.append(offerSectionItem)
                        }
                    }

                    if listingsGroup.rowDisplayNumber < listingsGroup.totalOffers {
                        let viewAllOffersViewModel = ListingsViewAllOffersTableViewCellViewModel(outlet: outlet)
                        let viewAllOffersItem = ListingsTableViewModelSectionItem.ViewAllOffersItem(viewModel: viewAllOffersViewModel)
                        items.append(viewAllOffersItem)
                    }

                    let listingGroupSection = ListingsTableViewModelSectionModel.ListingsSection(items: items)
                    sections.append(listingGroupSection)
                }
            }

            return sections
        }).asDriver(onErrorDriveWith: Driver.of([ListingsTableViewModelSectionModel]()))

        self.state
            .asObservable()
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                return lhs == rhs
            })
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (state) in
                self?.requestListings()
            }.addDisposableTo(disposeBag)

        self.state
            .asObservable()
            .distinctUntilChanged({ (lhs, rhs) -> Bool in
                return lhs == rhs
            })
            .map { (state: ListingsViewModelState) -> Bool in
                return state.subCategories.count != 0 || state.distances != nil || state.priceRanges != nil
            }.bindTo(isFiltered)
            .addDisposableTo(disposeBag)

        self.listings
            .asObservable()
            .skip(1)
            .map { (listings) -> Bool in
                return listings.count == 0
            }.bindTo(isEmpty)
            .addDisposableTo(disposeBag)

        self.location
            .asObservable()
            .filterNil()
            .skip(1)
            .subscribeNext { [weak self] (_) in
                self?.refresh()
            }.addDisposableTo(disposeBag)

        skinTableViewDataSource(dataSource)
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .None,
                                                                   reloadAnimation: .None,
                                                                   deleteAnimation: .None)
    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<ListingsTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .HeaderSectionItem(viewModel):
                let cell: ListingsHeaderTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .FilterOffSectionItem(viewModel):
                let cell: FilterIsOffTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .FilterOnSectionItem(viewModel):
                let cell: FilterIsOnTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.delegate = self
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .ListingEmptySectionItem(viewModel):
                let cell: MyFaveEmptyResultTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .OutletSectionItem(viewModel):
                let cell: ListingsGroupedOutletTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .OfferSectionItem(viewModel):
                let cell: ListingsGroupedOfferTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .ViewAllOffersItem(viewModel):
                let cell: ListingsViewAllOffersTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
            }
        }
    }

    func requestListings() {
        // Don't hit the API if we have loaded everything
        if state.value.loadedEverything {
            return
        }

        let categoryIds = state.value.subCategories.map { (category) -> Int in
            return category.id
        }

        let listingsAPIRequestPayload = ListingsGroupAPIRequestPayload(page: state.value.page, limit: listingsPerPage, order: state.value.order, location: location.value, featured: nil, categoryIds: categoryIds, collectionIds: nil, categoryType: state.value.categoryType, listingTypes: nil, favorited_outlet: nil, outletIds: nil, priceRanges: state.value.priceRanges, distances: state.value.distances)

        _ = listingsAPI
            .getListings(withRequestPayload: listingsAPIRequestPayload)
            .trackActivity(activityIndicator)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(
                onNext: { [weak self] (respond) in
                    guard let strongSelf = self else { return }
                     strongSelf.updateNewRespond(respond)
                }, onError: { [weak self] (error) in
                    self?.isLoading = false
                }
            ).addDisposableTo(disposeBag)
    }

    private func updateNewRespond(respond: ListingsGroupAPIResponsePayload) {
        if state.value.page == 1 {
            listings.value = respond.listings
        } else {
            listings.value.appendContentsOf(respond.listings)
        }

        self.updateViewModelState(
            withPage: self.state.value.page,
            loadedEverything: respond.listings.isEmpty,
            subCategories: self.state.value.subCategories,
            categoryType: self.state.value.categoryType,
            order: self.state.value.order,
            priceRanges: state.value.priceRanges,
            distances: state.value.distances,
            category: state.value.category
        )

        self.isLoading = false
    }

    private func updateViewModelState(withPage page: Int, loadedEverything: Bool, subCategories: [SubCategory], categoryType: String, order: ListingsOrder?, priceRanges: Int?, distances: Int?, category: Category) {
        state.value = ListingsViewModelState(page: page, loadedEverything: loadedEverything, subCategories: subCategories, categoryType: categoryType, order: order, priceRanges: priceRanges, distances: distances, category: category)
    }

    func updateFilter(subCategories: [SubCategory], priceRanges: Int?, distances: Int?) {
        state.value = ListingsViewModelState(page: 1, loadedEverything: false, subCategories: subCategories, categoryType: state.value.categoryType, order: state.value.order, priceRanges: priceRanges, distances: distances, category: state.value.category)
    }

    func updateSubCategories(subCategories: [SubCategory]) {
        state.value = ListingsViewModelState(page: 1, loadedEverything: false, subCategories: subCategories, categoryType: state.value.categoryType, order: state.value.order, priceRanges: state.value.priceRanges, distances: state.value.distances, category: state.value.category)
    }

    func updateOrder(order: ListingsOrder) {
        state.value = ListingsViewModelState(page: 1, loadedEverything: false, subCategories: state.value.subCategories, categoryType: state.value.categoryType, order: order, priceRanges: state.value.priceRanges, distances: state.value.distances, category: state.value.category)
    }

    func loadNextPage() {
        updateViewModelState(withPage: state.value.page + 1, loadedEverything: state.value.loadedEverything, subCategories: state.value.subCategories, categoryType: state.value.categoryType, order: state.value.order, priceRanges: state.value.priceRanges, distances: state.value.distances, category: state.value.category)
    }
}

// MARK:- Refreshable
extension ListingsTableViewModel: Refreshable {
    func refresh() {
        isLoading = true
        state.value = ListingsViewModelState(page: 1,
                                             loadedEverything: false,
                                             subCategories: state.value.subCategories,
                                             categoryType: state.value.categoryType,
                                             order: state.value.order,
                                             priceRanges: state.value.priceRanges,
                                             distances: state.value.distances,
                                             category: state.value.category)
        requestListings()
    }

    func reset() {
        isLoading = true
        state.value = ListingsViewModelState(page: 1,
                                             loadedEverything: false,
                                             subCategories: [],
                                             categoryType: state.value.categoryType,
                                             order: state.value.order,
                                             priceRanges: nil,
                                             distances: nil,
                                             category: state.value.category)
        requestListings()
    }
}

enum ListingsTableViewModelSectionModel {
    case HeaderSection(items: [ListingsTableViewModelSectionItem])
    case FilterTabSection(items: [ListingsTableViewModelSectionItem])
    case ListingsSection(items: [ListingsTableViewModelSectionItem])
}

enum ListingsTableViewModelSectionItem: IdentifiableType, Equatable {
    case HeaderSectionItem(viewModel: ListingsHeaderTableViewCellViewModel)
    case FilterOffSectionItem(viewModel: FilterIsOffTableViewCellViewModel)
    case FilterOnSectionItem(viewModel: FilterIsOnTableViewCellViewModel)
    case ListingEmptySectionItem(viewModel: MyFaveEmptyResultTableViewCellViewModel)
    case OutletSectionItem(viewModel: ListingsGroupedOutletTableViewCellViewModel)
    case OfferSectionItem(viewModel: ListingsGroupedOfferTableViewCellViewModel)
    case ViewAllOffersItem(viewModel: ListingsViewAllOffersTableViewCellViewModel)

    var identity: String {
        switch self {
        case let .HeaderSectionItem(viewModel): return viewModel.UUID
        case let .FilterOffSectionItem(viewModel): return viewModel.UUID
        case let .FilterOnSectionItem(viewModel): return viewModel.UUID
        case let .ListingEmptySectionItem(viewModel): return viewModel.UUID
        case let .OutletSectionItem(viewModel): return viewModel.UUID
        case let .OfferSectionItem(viewModel): return viewModel.UUID
        case let .ViewAllOffersItem(viewModel): return viewModel.UUID
        }
    }
}

func ==(lhs: ListingsTableViewModelSectionItem, rhs: ListingsTableViewModelSectionItem) -> Bool {
    let result = lhs.identity == rhs.identity
    return result
}

extension ListingsTableViewModelSectionModel: AnimatableSectionModelType {

    typealias Item = ListingsTableViewModelSectionItem

    var items: [ListingsTableViewModelSectionItem] {
        switch  self {
        case .HeaderSection(items: let items):
            return items
        case .FilterTabSection(items: let items):
            return items
        case .ListingsSection(items: let items):
            return items
        }
    }

    init(original: ListingsTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .HeaderSection(items: _):
            self = .HeaderSection(items: items)
        case .FilterTabSection(items: _):
            self = .FilterTabSection(items: items)
        case .ListingsSection(items: _):
            self = .ListingsSection(items: items)
        }
    }

    var identity: String {
        switch self {
        case .HeaderSection(items: _): return literal.ListingsHeaderSectionIdentifier
        case .FilterTabSection(items: _): return literal.ListingsFilterSectionIdentifier
        case .ListingsSection(items: _): return literal.ListingsListingsSectionIdentifier
        }
    }
}

func ==(lhs: ListingsTableViewModelSectionModel, rhs: ListingsTableViewModelSectionModel) -> Bool {
    let result = lhs.identity == rhs.identity
    return result
}

extension ListingsTableViewModel: FilterIsOnTableViewCellDelegate {
    func filterIsOnTableViewCellDidTapReset() {
        reset()
    }
}

extension ListingsTableViewModel: FilterUpdateDelegate {
    func filterDidUpdate(state: ListingsViewModelState) {
        self.state.value = state
    }
}

extension ListingsTableViewModel: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {
        case .FilterOffSectionItem(viewModel: _):
            return 45

        case .FilterOnSectionItem(viewModel: _):
            return 45

        case .HeaderSectionItem(viewModel: _):
            return 90

        case let .OfferSectionItem(viewModel: viewModel):
//            return 95
            return viewModel.cellHeight

        case .OutletSectionItem(viewModel: _):
            return 104

        case .ListingEmptySectionItem(viewModel: _):
            return 250

        case .ViewAllOffersItem(viewModel: _):
            return 50
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let numberOfSection = tableView.numberOfSections
        let currentSection = indexPath.section
        if currentSection > numberOfSection - 5 && isLoading == false {
            loadNextPage()
            isLoading = true
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = dataSource.itemAtIndexPath(indexPath)
        switch item {

        case .FilterOnSectionItem(viewModel: _), .FilterOffSectionItem(viewModel: _):
            lightHouseService.navigate
                .onNext { [weak self] (viewController) in
                    guard let strongSelf = self else {return}
                    let vc = FilterViewController.build(FilterViewControllerViewModel(state: strongSelf.state.value))
                    vc.delegate = strongSelf
                    viewController.presentViewController(vc, animated: true, completion: nil)
            }

        case let .OutletSectionItem(viewModel: viewModel):
            if let companyId = viewModel.outlet.company?.id {
                let outletViewModel = OutletViewControllerViewModel(outletId: viewModel.outlet.id, companyId: companyId)
                let outletViewController = OutletViewController.build(outletViewModel)
                outletViewController.hidesBottomBarWhenPushed = true
                lightHouseService.navigate.onNext({ (viewController) in
                    viewController.navigationController?.pushViewController(outletViewController, animated: true)
                })
            }

        case let .OfferSectionItem(viewModel: viewModel):
            switch functionality.value {
            case .Initiate():
                let listingViewModel = ListingViewModel(listingId: viewModel.listing.id, outletId: viewModel.outlet.id, functionality: Variable(ListingViewModelFunctionality.Initiate()))
                let listingViewController = ListingViewController.build(listingViewModel)
                listingViewController.hidesBottomBarWhenPushed = true
                lightHouseService.navigate.onNext({ (viewController) in
                    viewController.navigationController?.pushViewController(listingViewController, animated: true)
                })

            case let .InitiateFromChat(channelListing: channelListing):
                let listingViewModel = ListingViewModel(listingId: viewModel.listing.id, outletId: viewModel.outlet.id,  functionality: Variable(ListingViewModelFunctionality.InitiateFromChat(channelListing: channelListing)))
                let listingViewController = ListingViewController.build(listingViewModel)
                listingViewController.hidesBottomBarWhenPushed = true
                lightHouseService.navigate.onNext({ (viewController) in
                    viewController.navigationController?.pushViewController(listingViewController, animated: true)
                })
            }

        case let .ViewAllOffersItem(viewModel: viewModel):
            let allOffersViewModel = ListingsGroupedAllOffersViewControllerViewModel(outlet: viewModel.outlet)
            let allOffersViewController = ListingsGroupedAllOffersViewController.build(allOffersViewModel)
            allOffersViewController.hidesBottomBarWhenPushed = true
            lightHouseService.navigate.onNext({ (viewController) in
                viewController.navigationController?.pushViewController(allOffersViewController, animated: true)
            })

        default:
            return
        }
    }
}
