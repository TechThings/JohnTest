//
//  ContactProvider.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Contacts

protocol ContactProvider: Refreshable, Cachable {
    var contactsBundle: Variable<ContactsBundle> {get}
    var contactStorePermission: Variable<CNAuthorizationStatus> {get}
    func updateContactsBundle() -> Observable<ContactsBundle>
    func resetContactsBundle() -> Observable<ContactsBundle>
    func requestContactStorePermission()
}

final class ContactProviderDefault: Provider, ContactProvider {
    // MARK:- Dependency
    let uploadContactsAPI: UploadContactsAPI

    // MARK:- Provider variables
    let contactsBundle: Variable<ContactsBundle>
    let contactStorePermission: Variable<CNAuthorizationStatus> = Variable(CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts))

    private let contactStore = CNContactStore()
    private let contactsByPhoneNumber: Variable<[String: Contact]>

    init(
        uploadContactsAPI: UploadContactsAPI = UploadContactsAPIDefault()
        ) {

        let cashedContactsByPhoneNumber = ContactProviderDefault.loadCacheForContactsByPhoneNumber()
        contactsByPhoneNumber = Variable(cashedContactsByPhoneNumber)

        let cashedContactsBundle = ContactProviderDefault.loadCacheForContactsBundle()
        contactsBundle = Variable(cashedContactsBundle)

        self.uploadContactsAPI = uploadContactsAPI

        super.init()

        // Cache contacts
        contactsByPhoneNumber
            .asObservable()
            .subscribeNext { (contactsByPhoneNumber: [String: Contact]) in
                ContactProviderDefault.cache(contactsByPhoneNumber: contactsByPhoneNumber)
            }.addDisposableTo(disposeBag)

        // Cache faveContacts
        contactsBundle
            .asObservable()
            .subscribeNext { (contactsBundle: ContactsBundle) in
                ContactProviderDefault.cache(contactsBundle: contactsBundle)
            }.addDisposableTo(disposeBag)

        // Clear the logout
        app
            .logoutSignal
            .subscribeNext {
                ContactProviderDefault.clearCacheForContactsByPhoneNumber()
                ContactProviderDefault.clearCacheForContactsBundle()

                self.contactsByPhoneNumber.value = [String: Contact]()
                self.contactsBundle.value = ContactsBundle()
            }
            .addDisposableTo(disposeBag)

    }

    func requestContactStorePermission() {
        switch contactStorePermission.value {
        case .NotDetermined, .Denied:
            contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { [weak self] (accessGranted, error) in
                self?.contactStorePermission.value = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
                })
        default: break
        }
    }

    func resetContactsBundle() -> Observable<ContactsBundle> {
        self.contactsByPhoneNumber.value = [String: Contact]()
        ContactProviderDefault.clearCacheForContactsByPhoneNumber()
        self.contactsBundle.value = ContactsBundle()
        ContactProviderDefault.clearCacheForContactsBundle()
        return updateContactsBundle()
    }

    /**
     Updated the provider contactsBundle
     
     - author: Nazih Shoura
     
     - returns: A ContactsBundle containg the updated contacts only
     */
    func updateContactsBundle() -> Observable<ContactsBundle> {

        let updatedContactStoreContacts = requestUpdatedContactStoreContacts()

        guard let contacts = updatedContactStoreContacts.value else {
            if let error = updatedContactStoreContacts.error { return Observable.error(error) }
            return Observable.error(NSError.unknownError)
        }

        // Don't perform any requests if there's no new contacts
        guard !contacts.isEmpty else {
            return Observable.of(self.contactsBundle.value)
        }

        let contactsBundleRequest = getContactsBundleRequest(forContacts: contacts)

        let result = contactsBundleRequest
            .trackActivity(activityIndicator)
            .doOnError({ _ in
                self.contactsByPhoneNumber.value = [String: Contact]()
                ContactProviderDefault.clearCacheForContactsByPhoneNumber()
            })
            .doOnNext({ (contactsBundle: ContactsBundle) in
                var nonFaveContacts = self.contactsBundle.value.nonFaveContacts
                nonFaveContacts.appendContentsOf(contactsBundle.nonFaveContacts)

                var faveContacts = self.contactsBundle.value.faveContacts
                faveContacts.appendContentsOf(contactsBundle.faveContacts)

                let totalContactsBundle = ContactsBundle(nonFaveContacts: nonFaveContacts, faveContacts: faveContacts)
                self.contactsBundle.value = totalContactsBundle
            })

        return result
    }

    // MARK:- Helper methods

    private func getContactsBundleRequest(forContacts contacts: [Contact]) -> Observable<ContactsBundle> {

        let contactsChunks = contacts.split(intoArrayOfArraysWithMaxSize: 100)

        let contactsBundleRequest = contactsChunks
            .map { (contactsChunk: [Contact]) -> Observable<ContactsBundle> in
                let contactsNumbers = contactsChunk.map { (conact: Contact) -> String in conact.phoneNumber }
                let requestPayload = UploadContactsAPIRequestPayload(contactsNumbers: contactsNumbers)
                let contactsBundleRequest = self.uploadContactsAPI.uploadContacts(withRequestPayload: requestPayload)
                    .map { (uploadContactsAPIResponsePayload: UploadContactsAPIResponsePayload) -> ContactsBundle in
                        self.marry(contacts: contactsChunk, withContactsValidation: uploadContactsAPIResponsePayload.validatedContacts)
                }

                return contactsBundleRequest
            }
            .concat()
            .reduce(ContactsBundle()) { (A: ContactsBundle, contactsBundle: ContactsBundle) -> ContactsBundle in
                ContactsBundle(nonFaveContacts: contactsBundle.nonFaveContacts + A.nonFaveContacts, faveContacts: contactsBundle.faveContacts + A.faveContacts)
        }

        return contactsBundleRequest
    }

    private func requestUpdatedContactStoreContacts() -> Result<[Contact]> {

        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName)
            , CNContactPhoneNumbersKey
        ]

        let fetch = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetch.unifyResults = true
        fetch.predicate = nil // Set this to nil will give you all Contacts

        var contacts: [Contact] = []
        var contactsByPhoneNumber = self.contactsByPhoneNumber.value

        do {
            _ = try contactStore
                .enumerateContactsWithFetchRequest(fetch, usingBlock: { contact, cursor in
                    let contact = contact as CNContact
                    contact.phoneNumbers.forEach { (value: CNLabeledValue) in
                        let phoneNumber = (value.value as! CNPhoneNumber).valueForKey("digits") as! String
                        let contact = Contact(phoneNumber: phoneNumber, firstName: contact.givenName, lastName: contact.familyName, imageURL: nil, userId: nil)

                        // TODO: Check if the contact has been updated
                        if contactsByPhoneNumber[phoneNumber] == nil {
                            contacts.append(contact)
                            contactsByPhoneNumber[phoneNumber] = contact
                        }

                    }
                })
        } catch {
            return Result.Failure(ContactProviderError.ErrorFetchingContactsForDefaultContainer)
        }
        self.contactsByPhoneNumber.value = contactsByPhoneNumber
        return Result.Success(contacts)
    }

    private func marry(contacts contacts: [Contact], withContactsValidation contactsValidation: [String: [String: AnyObject]]) -> ContactsBundle {
        var nonFaveContacts = [Contact]()
        var faveContacts = [Contact]()

        for contact in contacts {
            if let value = contactsValidation[contact.phoneNumber]
                , userId = value["user_id"] as? Int {

                let imageURL: NSURL? = {
                    guard let imageURLString = value["uploaded_image_url"] as? String else { return nil}
                    return NSURL(string: imageURLString)
                }()

                let resultantContact = Contact(phoneNumber: contact.phoneNumber, firstName: contact.firstName, lastName: contact.lastName, imageURL: imageURL, userId: userId)
                faveContacts.append(resultantContact)
            } else {
                nonFaveContacts.append(contact)
            }
        }

        return ContactsBundle(nonFaveContacts: nonFaveContacts, faveContacts: faveContacts)
    }
}

extension ContactProviderDefault {
    func refresh() {
        // Refresh the provided variables
    }
}

// MARK:- Cashe
extension ContactProviderDefault {
    static func clearCacheForContactsByPhoneNumber() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(literal.ContactProviderDefault).contactsByPhoneNumber")
    }

    static func cache(contactsByPhoneNumber contactsByPhoneNumber: [String: Contact]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(contactsByPhoneNumber)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.ContactProviderDefault).contactsByPhoneNumber")
    }

    static func loadCacheForContactsByPhoneNumber() -> [String: Contact] {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.ContactProviderDefault).contactsByPhoneNumber") as? NSData else {
            return [String: Contact]()
        }

        guard let contactsByPhoneNumber = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: Contact] else {
            ContactProviderDefault.clearCacheForContactsByPhoneNumber()
            return [String: Contact]()
        }
        return contactsByPhoneNumber
    }

    static func clearCacheForContactsBundle() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(literal.ContactProviderDefault).contactsBundle")
    }

    static func cache(contactsBundle contactsBundle: ContactsBundle) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(contactsBundle)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.ContactProviderDefault).contactsBundle")
    }

    static func loadCacheForContactsBundle() -> ContactsBundle {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.ContactProviderDefault).contactsBundle") as? NSData else {
            return ContactsBundle()
        }

        guard let contactsBundle = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? ContactsBundle else {
            ContactProviderDefault.clearCacheForContactsBundle()
            return ContactsBundle()
        }
        return contactsBundle
    }

}

enum ContactProviderError: DescribableError {
    case ErrorFetchingContactsForDefaultContainer

    var description: String {
        switch self {
        case .ErrorFetchingContactsForDefaultContainer:
            return "Error Fetching Contacts For Default Container"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .ErrorFetchingContactsForDefaultContainer:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }
}
