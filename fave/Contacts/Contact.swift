//
//  Contact.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

extension Contact: Avatarable {
    var firstLetter: Character {
        if let firstChar = self.firstName.characters.first {
            return firstChar
        } else {
            return "?".characters.first!
        }
    }

    var lastLetter: Character? { return self.lastName.characters.first }
    var participationStatus: UserParticipationStatus { return .NotInvited }
}

final class Contact: NSObject, NSCoding {

    let phoneNumber: String
    let firstName: String
    let lastName: String
    let imageURL: NSURL?
    let userId: Int?
    var isFaveContacts: Bool { return self.userId != nil }

    init(
        phoneNumber: String
        , firstName: String
        , lastName: String
        , imageURL: NSURL?
        , userId: Int?
        ) {
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
        self.userId = userId
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.phoneNumber = aDecoder.decodeObjectForKey("\(literal.Contact).phoneNumber") as! String
        self.firstName = aDecoder.decodeObjectForKey("\(literal.Contact).firstName") as! String
        self.lastName = aDecoder.decodeObjectForKey("\(literal.Contact).lastName") as! String
        self.imageURL = aDecoder.decodeObjectForKey("\(literal.Contact).imageURL") as? NSURL
        self.userId = aDecoder.decodeObjectForKey("\(literal.Contact).userId") as? Int
        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(phoneNumber, forKey: "\(literal.Contact).phoneNumber")
        aCoder.encodeObject(firstName, forKey: "\(literal.Contact).firstName")
        aCoder.encodeObject(lastName, forKey: "\(literal.Contact).lastName")
        aCoder.encodeObject(imageURL, forKey: "\(literal.Contact).imageURL")
        aCoder.encodeObject(userId, forKey: "\(literal.Contact).userId")
    }
}

func ==(lhs: Contact, rhs: Contact) -> Bool {
    return lhs.phoneNumber == rhs.phoneNumber && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
}

//
//extension Contact: Serializable {
//    static func serialize(jsonRepresentation: AnyObject?) -> Contact? {
//        guard let json = jsonRepresentation as? [String : AnyObject] else {
//            return nil
//        }
//        
//        guard let Variable = json["<#API variable#>"] as? <#Type#> else {return nil}
//        
//        guard let Variable = { () -> <#Type#>? in
//            // Transform the received value
//            return json["<#API variable#>"] as? <#Type#>
//            }() else {return nil}
//        
//        let <#Optinal Variable#> = json["<#API variable#>"] as? <#Type#>
//        
//        let result = Contact(
//            <#Variable#>: <#Variable#>
//            , <#Variable#>: <#Variable#>
//            , <#Variable#>: <#Variable#>
//            , <#Variable#>: <#Variable#>
//            , <#Variable#>: <#Variable#>
//            , <#Variable#>: <#Variable#>
//            , <#Optinal Variable#>: <#Optinal Variable#>
//        )
//        return result
//    }
//}
//
