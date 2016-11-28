//
//  AddPaymentMethodTableViewModel.swift
//  FAVE
//
//  Created by Ranjeet on 23/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/**
 *  @author Ranjeet
 *
 *  AddPaymentMethodTableViewModel
 */
final class AddPaymentMethodTableViewModel: ViewModel {

    // MARK- Output
    let sectionsModels: Driver<[AddPaymentMethodTableViewModelSectionModel]>
    let dataSource = RxTableViewSectionedReloadDataSource<AddPaymentMethodTableViewModelSectionModel>()

    init(resultSubject: PublishSubject<PaymentMethod?>, adyenPayment: AdyenPaymentFacade) {
        let addCreditCardTableViewModelSectionItem = AddPaymentMethodTableViewModelSectionItem.AddCreditCardTableViewModelSectionItem(viewModel: AddPaymentMethodTableViewCellViewModel(resultSubject: resultSubject, adyenPayment: adyenPayment))
        var sections = [AddPaymentMethodTableViewModelSectionModel]()
            sections.append(AddPaymentMethodTableViewModelSectionModel.AddPaymentMethodTableViewModelSection(items: [addCreditCardTableViewModelSectionItem]))

        self.sectionsModels = Driver.of(sections)

        super.init()

        skinTableViewDataSource(dataSource)

    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<AddPaymentMethodTableViewModelSectionModel>) {

        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .AddCreditCardTableViewModelSectionItem(viewModel):
                let cell: AddPaymentMethodTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell
            }
        }
    }
}

enum AddPaymentMethodTableViewModelSectionModel {
    case AddPaymentMethodTableViewModelSection(items: [AddPaymentMethodTableViewModelSectionItem])
}

extension AddPaymentMethodTableViewModelSectionModel: SectionModelType {
    typealias Item = AddPaymentMethodTableViewModelSectionItem

    var items: [AddPaymentMethodTableViewModelSectionItem] {
        switch  self {
        case .AddPaymentMethodTableViewModelSection(items: let items):
            return items
        }
    }

    init(original: AddPaymentMethodTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .AddPaymentMethodTableViewModelSection(items: _):
            self = .AddPaymentMethodTableViewModelSection(items: items)
        }
    }
}

enum AddPaymentMethodTableViewModelSectionItem {
    case AddCreditCardTableViewModelSectionItem(viewModel: AddPaymentMethodTableViewCellViewModel)
}
