//
//  ListingsCollectionsTableViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

final class ListingsCollectionsTableViewModel: ViewModel {

    // MARK:- Dependency
    let listingsCollectionsAPI: ListingsCollectionsAPI

    // MARK:- Input

    // MARK:- Intermediate
    let listingsCollections = Variable([ListingsCollection]())

    // MARK- Output
    let sectionsModels: Driver<[ListingsCollectionsTableViewModelSectionModel]>
    let dataSource = RxTableViewSectionedReloadDataSource<ListingsCollectionsTableViewModelSectionModel>()

    init(
        listingsCollectionsAPI: ListingsCollectionsAPI = ListingsCollectionsAPIDefault()
        ) {
        self.listingsCollectionsAPI = listingsCollectionsAPI

        self.sectionsModels = listingsCollections
            .asObservable()
            .map { (listingsCollections: [ListingsCollection]) -> [ListingsCollectionsTableViewModelSectionModel] in
                let items = listingsCollections
                    .map { (listingsCollection: ListingsCollection) -> ListingsCollectionsTableViewModelSectionItem in
                        ListingsCollectionsTableViewModelSectionItem.ListingsCollectionsSectionItem(viewModel: ListingsCollectionViewModel(listingsCollection: listingsCollection))
                }
                return [ListingsCollectionsTableViewModelSectionModel.ListingsCollectionsSection(items: items)]
            }
            .asDriver(onErrorJustReturn: [ListingsCollectionsTableViewModelSectionModel]())
            .startWith([ListingsCollectionsTableViewModelSectionModel]())

        super.init()

        skinTableViewDataSource(dataSource)
    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<ListingsCollectionsTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .ListingsCollectionsSectionItem(viewModel):
                let cell: ListingsCollectionViewTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.listingsCollectionView.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
            }
        }
    }
}

extension ListingsCollectionsTableViewModel: Refreshable {
    func refresh() {
        let response = listingsCollectionsAPI
            .listingsCollections(withRequestPayload: ListingsCollectionsAPIRequestPayload())

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                })
            })
            .map({ (listingsCollectionsAPIResponsePayload: ListingsCollectionsAPIResponsePayload) -> [ListingsCollection] in
                listingsCollectionsAPIResponsePayload.listingsCollections
            })
            .bindTo(listingsCollections)
            .addDisposableTo(disposeBag)
    }
}

enum ListingsCollectionsTableViewModelSectionModel {
    case ListingsCollectionsSection(items: [ListingsCollectionsTableViewModelSectionItem])
}

extension ListingsCollectionsTableViewModelSectionModel: SectionModelType {
    typealias Item = ListingsCollectionsTableViewModelSectionItem

    var items: [ListingsCollectionsTableViewModelSectionItem] {
        switch  self {
        case .ListingsCollectionsSection(items: let items):
            return items
        }
    }

    init(original: ListingsCollectionsTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .ListingsCollectionsSection(items: _):
            self = .ListingsCollectionsSection(items: items)
        }
    }
}

enum ListingsCollectionsTableViewModelSectionItem {
    case ListingsCollectionsSectionItem(viewModel: ListingsCollectionViewModel)
}
