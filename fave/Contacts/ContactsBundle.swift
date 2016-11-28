//
//  ContactsBundle.swift
//  FAVE
//
//  Created by Nazih Shoura on 12/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class ContactsBundle: NSObject, NSCoding {
    let nonFaveContacts: [Contact]
    let faveContacts: [Contact]
    init(nonFaveContacts: [Contact] = [Contact]()
        , faveContacts: [Contact] = [Contact]()) {
        self.nonFaveContacts = nonFaveContacts
        self.faveContacts = faveContacts
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.faveContacts = aDecoder.decodeObjectForKey("\(literal.ContactsBundle).faveContacts") as! [Contact]
        self.nonFaveContacts = aDecoder.decodeObjectForKey("\(literal.ContactsBundle).nonFaveContacts") as! [Contact]
        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(faveContacts, forKey: "\(literal.ContactsBundle).faveContacts")
        aCoder.encodeObject(nonFaveContacts, forKey: "\(literal.ContactsBundle).nonFaveContacts")
    }
}
