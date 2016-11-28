//
//  ContactsTableViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum ContactsTableViewModelModelFunctionality {
    case AddChannelParticipants(chatParticipants: Variable<[ChatParticipant]>, filterChatParticipants: [ChatParticipant])
    case SetChannelParticipants(chatParticipants: Variable<[ChatParticipant]>)
}

/**
 *  @author Nazih Shoura
 *
 *  ContactsTableViewModel
 */
final class ContactsTableViewModel: ViewModel {

    // MARK:- Dependency
    private let contactProvider: ContactProvider

    // MARK:- Variable
    let chatParticipants: Variable<[ChatParticipant]>
    let contactsBundle = Variable(ContactsBundle())

    //MARK:- Input
    let searchText: ControlProperty<String>

    // MARK:- Intermediate

    // MARK- Output
    var sectionsModels: Driver<[ContactsTableViewModelSectionModel]> = Driver.of([ContactsTableViewModelSectionModel]())
    let dataSource = RxTableViewSectionedReloadDataSource<ContactsTableViewModelSectionModel>()

    //MARK:- Signal
    let itemSelectedAtIndexPath = PublishSubject<NSIndexPath>()
    let presentViewController = PublishSubject<UIViewController>()
    let pushViewController = PublishSubject<UIViewController>()
    let dismissViewController = PublishSubject<Void>()

    init(
        contactProvider: ContactProvider = ContactProviderDefault()
        , searchText: ControlProperty<String>
        , contactsTableViewModelModelFunctionality: ContactsTableViewModelModelFunctionality
        ) {
        self.searchText = searchText
        self.contactProvider = contactProvider
        switch contactsTableViewModelModelFunctionality {
        case let .SetChannelParticipants(chatParticipants):
            self.chatParticipants = chatParticipants
        case let .AddChannelParticipants(chatParticipants, _):
            self.chatParticipants = chatParticipants
        }

        super.init()

        self.sectionsModels = contactsBundle
            .asObservable()
            .map { (contactsBundle: ContactsBundle) -> [ContactsTableViewModelSectionModel] in
                var sections = [ContactsTableViewModelSectionModel]()

                // Fave contacts section
                let faveContactsItems = contactsBundle.faveContacts
                    .map { (contact: Contact) -> ContactsTableViewModelSectionItem in
                        ContactsTableViewModelSectionItem.ContactsSectionItem(viewModel: ContactViewTableViewCellModel(contact: contact, chatParticipants: self.chatParticipants))
                }
                if !faveContactsItems.isEmpty {
                    sections.append(ContactsTableViewModelSectionModel.ContactsSection(items: [ContactsTableViewModelSectionItem.FaveContactHeaderItem]))
                    sections.append(ContactsTableViewModelSectionModel.ContactsSection(items: faveContactsItems))
                }

                // Non Fave contacts section
                let nonFaveContactsItems = contactsBundle.nonFaveContacts
                    .map { (contact: Contact) -> ContactsTableViewModelSectionItem in
                        ContactsTableViewModelSectionItem.ContactsSectionItem(viewModel: ContactViewTableViewCellModel(contact: contact, chatParticipants: self.chatParticipants))
                }

                if !nonFaveContactsItems.isEmpty {
                    sections.append(ContactsTableViewModelSectionModel.ContactsSection(items: [ContactsTableViewModelSectionItem.NonFaveContactHeaderItem]))
                    sections.append(ContactsTableViewModelSectionModel.ContactsSection(items: nonFaveContactsItems))
                }

                return sections
            }
            .asDriver(onErrorJustReturn: [ContactsTableViewModelSectionModel]())

        switch contactsTableViewModelModelFunctionality {
        case .SetChannelParticipants(_):
            contactProvider
                .contactsBundle
                .asObservable()
                .bindTo(contactsBundle)
                .addDisposableTo(disposeBag)
        case let .AddChannelParticipants(_, filterChatParticipants):
            let filteredIds = filterChatParticipants
                .map { (filterChatParticipant: ChatParticipant) -> Int? in filterChatParticipant.id }
            contactProvider
                .contactsBundle
                .asObservable()
                .subscribeNext({ [weak self] (contactsBundle: ContactsBundle) in
                    let filteredFaveContacts = contactsBundle.faveContacts.filter({ (contact: Contact) -> Bool in
                        let result = !filteredIds.contains { $0 == contact.userId }
                        return result
                    })
                    self?.contactsBundle.value = ContactsBundle(nonFaveContacts: contactsBundle.nonFaveContacts, faveContacts:  filteredFaveContacts)
                    })
                .addDisposableTo(disposeBag)
        }

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
                    strongSelf.contactsBundle.value = strongSelf.contactProvider.contactsBundle.value
                    return
                }

                let faveContacts = strongSelf.contactProvider.contactsBundle.value.faveContacts.filter { (Contact: Contact) -> Bool in
                    Contact.firstName.lowercaseString.containsString(query)
                        || Contact.lastName.lowercaseString.containsString(query)
                }

                let nonFaveContacts = strongSelf.contactProvider.contactsBundle.value.nonFaveContacts.filter { (Contact: Contact) -> Bool in
                    Contact.firstName.lowercaseString.containsString(query)
                        || Contact.lastName.lowercaseString.containsString(query)
                }

                strongSelf.contactsBundle.value = ContactsBundle(nonFaveContacts: nonFaveContacts, faveContacts: faveContacts)

            }.addDisposableTo(disposeBag)

        skinTableViewDataSource(dataSource)

        refresh()
    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<ContactsTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .ContactsSectionItem(viewModel):
                let cell: ContactViewTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell
            case .FaveContactHeaderItem:
                let cell: FaveContactHeaderTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                return cell
            case .NonFaveContactHeaderItem:
                let cell: NonFaveContactHeaderTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                return cell

            }
        }
    }
}

// MARK:- Refreshable
extension ContactsTableViewModel: Refreshable {
    func refresh() {
        contactProvider.requestContactStorePermission()
        contactProvider
            .updateContactsBundle()
            .trackActivity(app.activityIndicator)
            .subscribeError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

extension ContactsTableViewModel: Resettable {
    @objc
    func reset() {
        contactProvider.resetContactsBundle()
            .trackActivity(app.activityIndicator)
            .subscribeError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

enum ContactsTableViewModelSectionModel {
    case ContactsSection(items: [ContactsTableViewModelSectionItem])
}

extension ContactsTableViewModelSectionModel: SectionModelType {
    typealias Item = ContactsTableViewModelSectionItem

    var items: [ContactsTableViewModelSectionItem] {
        switch  self {
        case .ContactsSection(items: let items):
            return items
        }
    }

    init(original: ContactsTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .ContactsSection(items: _):
            self = .ContactsSection(items: items)
        }
    }
}

enum ContactsTableViewModelSectionItem {
    case ContactsSectionItem(viewModel: ContactViewTableViewCellModel)
    case FaveContactHeaderItem
    case NonFaveContactHeaderItem
}
