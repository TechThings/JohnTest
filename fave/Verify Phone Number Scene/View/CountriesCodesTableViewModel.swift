//
//  CountriesCodesTableViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import PhoneNumberKit

typealias CountryPhoneRepresentation = (countryName: String, countryCallingCode: String, countryCode: String)

/**
 *  @author Nazih Shoura
 *
 *  CountriesCodesTableViewModel
 */
final class CountriesCodesTableViewModel: ViewModel {

    let dataSource = RxTableViewSectionedReloadDataSource<CountriesCodesTableViewModelSectionModel>()
    let countriesPhoneRepresentations: Variable<[CountryPhoneRepresentation]>

    // MARK- Output
    var sectionsModels: Driver<[CountriesCodesTableViewModelSectionModel]> = Driver.of([CountriesCodesTableViewModelSectionModel]())

    // MARK:- Input
    let searchText: ControlProperty<String>
    let selectedCountryCode: Variable<CountryPhoneRepresentation>

    static let CountriesPhoneRepresentations: [CountryPhoneRepresentation] = {
        let phoneNumberKit = PhoneNumberKit()
        var countriesPhoneRepresentations = [CountryPhoneRepresentation]()
        NSLocale.ISOCountryCodes().forEach { (isoCode: String) in
            guard let countryName = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: isoCode) else { return }
            guard let countryCallingCode = phoneNumberKit.codeForCountry(isoCode) else { return }
            countriesPhoneRepresentations.append(CountryPhoneRepresentation(countryName: countryName, countryCallingCode: String(countryCallingCode), countryCode: isoCode))
        }
        return countriesPhoneRepresentations
    }()

    init(
        searchText: ControlProperty<String>
        , selectedCountryCode: Variable<CountryPhoneRepresentation>
        ) {
        self.searchText = searchText
        self.countriesPhoneRepresentations = Variable(CountriesCodesTableViewModel.CountriesPhoneRepresentations)
        self.selectedCountryCode = selectedCountryCode

        self.sectionsModels = countriesPhoneRepresentations
            .asDriver()
            .map {  (countriesCodes: [CountryPhoneRepresentation]) -> [CountriesCodesTableViewModelSectionModel] in
                let items = countriesCodes
                    .map { (countryPhoneRepresentation: (countryName: String, countryCallingCode: String, countryCode: String)) -> CountriesCodesTableViewModelSectionItem in
                        return CountriesCodesTableViewModelSectionItem.CountriesCodesSectionItem(viewModel: CountriesCodesTableViewCellModel(countryPhoneRepresentation: countryPhoneRepresentation, selectedCountryCode: selectedCountryCode))

                }
                return [CountriesCodesTableViewModelSectionModel.CountiesCodeSection(items: items)]
        }

        super.init()

        // Filter faveContacts and nonFaveContacts
        searchText
            .asObservable()
            .skip(1)
            .throttle(0.1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { [weak self] (searchText: String) in
                guard let strongSelf = self else { return }
                let query = searchText.lowercaseString
                if query == "" {
                    strongSelf.countriesPhoneRepresentations.value = CountriesCodesTableViewModel.CountriesPhoneRepresentations
                    return
                }

                strongSelf.countriesPhoneRepresentations.value = CountriesCodesTableViewModel
                    .CountriesPhoneRepresentations
                    .filter { (countriesPhoneRepresentations: (countryName: String, countryCallingCode: String, countryCode: String)) -> Bool in
                        countriesPhoneRepresentations.countryName.lowercaseString.containsString(query)
                }

            }.addDisposableTo(disposeBag)

        skinTableViewDataSource(dataSource)

    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<CountriesCodesTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .CountriesCodesSectionItem(viewModel):
                let cell: CountriesCodesTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell
            }
        }
    }

}

enum CountriesCodesTableViewModelSectionModel {
    case CountiesCodeSection(items: [CountriesCodesTableViewModelSectionItem])
}

extension CountriesCodesTableViewModelSectionModel: SectionModelType {
    typealias Item = CountriesCodesTableViewModelSectionItem

    var items: [CountriesCodesTableViewModelSectionItem] {
        switch  self {
        case .CountiesCodeSection(items: let items):
            return items
        }
    }

    init(original: CountriesCodesTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .CountiesCodeSection(items: _):
            self = .CountiesCodeSection(items: items)
        }
    }
}

enum CountriesCodesTableViewModelSectionItem {
    case CountriesCodesSectionItem(viewModel: CountriesCodesTableViewCellModel)
}
