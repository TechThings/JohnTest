//
//  ContactViewTableViewCellModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ContactViewTableViewCellModel
 */
final class ContactViewTableViewCellModel: ViewModel {

    // MARK:- Dependency

    // MARK:- Variable

    //MARK:- Input
    let contact: Variable<Contact>
    let didTap = PublishSubject<()>()

    // MARK:- Intermediate

    // MARK- Output
    let name: Driver<String>
    let phoneNumber: Driver<String>
    let imageURL: Driver<NSURL?>
    let selectedImage: Driver<UIImage?>
    let chatParticipants: Variable<[ChatParticipant]>
    let selected: Variable<Bool>
    init(
        contact: Contact
        , chatParticipants: Variable<[ChatParticipant]> = Variable([ChatParticipant]())
        ) {
        self.contact = Variable(contact)
        self.chatParticipants = chatParticipants
        name = Driver.of("\(contact.firstName) \(contact.lastName)")
        phoneNumber = Driver.of(contact.phoneNumber)
        imageURL = Driver.of(contact.imageURL)

        // Set the initial value of selected (true if chatParticipants contains the passed contact)
        let phoneNumbers = chatParticipants.value.map { (chatParticipant: ChatParticipant) -> String in chatParticipant.phoneNumber }
        selected = Variable(phoneNumbers.contains(contact.phoneNumber))

        // Update selectedImage when selected is updated
        selectedImage = selected
            .asDriver()
            .map({ (selected: Bool) -> UIImage? in
                if selected { return UIImage(named: "ic_checkbox_selected") } else { return UIImage(named: "ic_checkbox")}
                }
        )

        super.init()

        // Update selected when the user tap
        didTap
            .map { _ -> Bool in !self.selected.value }
            .bindTo(selected)
            .addDisposableTo(disposeBag)

        // Update selected when the user tap
        selected
            .asObservable()
            .skip(1) // The first value is the result of
            .subscribeNext { [weak self] (selected: Bool) in

                let chatParticipant = ChatParticipant(id: contact.userId, firstName: contact.firstName, lastName: contact.lastName, profileImageUrl: contact.imageURL, phoneNumber: contact.phoneNumber, participationStatus: .Invited, participationStatusUserVisible: "")

                if selected {
                    self?.chatParticipants.value.append(chatParticipant)
                } else {
                    if let index = self?.chatParticipants.value.indexOf(chatParticipant) {
                        self?.chatParticipants.value.removeAtIndex(index)
                    }
                    return
                }

            }.addDisposableTo(disposeBag)

    }
}
