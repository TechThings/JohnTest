//
//  User.swift
//  FAVE
//
//  Created by Nazih Shoura on 30/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

enum Gender: String {
    case Male = "Male"
    case Female = "Female"
    case NotSpecify = "Not Specified"
}

enum UserStatus {
    case Authenticated  // Authenticated with Phone number
    case Registered     // Registered there email and password
    case Guest          // Guest
}

final class User: NSObject, NSCoding {

    // Class Methods
    private final class func status(forUser user: User) -> UserStatus {
        if user == User.guestUser { return .Guest }
        if (user.email == nil || user.name == nil) { return .Authenticated  }
        return .Registered
    }

    final class var guestUser: User {
        return User(id: 0, name: NSLocalizedString("guest", comment: ""), email: "guest@fave.com", phoneNumber: "0", accountKitId: nil, profileImageURL: nil, gender: nil, dateOfBirth: nil, lastName: nil, firstName: nil, countryIsoCode: nil, referralCode: nil, advertisingId: nil, sendbirdAccessToken: nil, veritransToken: "")
    }

    /// Convinence variable to indicate whiether the user is a guest or not
    var isGuest: Bool {
        get {
            return self == User.guestUser
        }
    }

    var userStatus: UserStatus {
        get {
            return User.status(forUser: self)
        }
    }

    let id: Int
    let name: String?
    let email: String?
    let phoneNumber: String?
    let accountKitId: Int? // Should be deleted
    let profileImageURL: NSURL?
    let gender: Gender?
    let dateOfBirth: NSDate?
    let lastName: String?
    let firstName: String?
    let countryIsoCode: String?
    let referralCode: String?
    let advertisingId: String?
    let sendbirdAccessToken: String?
    let veritransToken: String

    init(
        id: Int
        , name: String?
        , email: String?
        , phoneNumber: String?
        , accountKitId: Int?
        , profileImageURL: NSURL?
        , gender: Gender?
        , dateOfBirth: NSDate?
        , lastName: String?
        , firstName: String?
        , countryIsoCode: String?
        , referralCode: String?
        , advertisingId: String?
        , sendbirdAccessToken: String?
        , veritransToken: String
        ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.accountKitId = accountKitId
        self.profileImageURL = profileImageURL
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.lastName = lastName
        self.firstName = firstName
        self.countryIsoCode = countryIsoCode
        self.referralCode = referralCode
        self.advertisingId = advertisingId
        self.sendbirdAccessToken = sendbirdAccessToken
        self.veritransToken = veritransToken
    }

    required convenience init?(coder decoder: NSCoder) {

        let id = decoder.decodeIntegerForKey("\(literal.User).id")

        let name = decoder.decodeObjectForKey("\(literal.User).name") as? String
        let email = decoder.decodeObjectForKey("\(literal.User).email") as? String
        let phoneNumber = decoder.decodeObjectForKey("\(literal.User).phoneNumber") as? String
        let referralCode = decoder.decodeObjectForKey("\(literal.User).referralCode") as? String
        let advertisingId = decoder.decodeObjectForKey("\(literal.User).advertisingId") as? String
        let sendbirdAccessToken = decoder.decodeObjectForKey("\(literal.User).sendbirdAccessToken") as? String

        var accountKitId: Int?
        if decoder.containsValueForKey("\(literal.User).accountKitId") {
            accountKitId = decoder.decodeIntegerForKey("\(literal.User).accountKitId")
        }

        let profileImageURL = decoder.decodeObjectForKey("\(literal.User).profileImageURL") as? NSURL
        let dateOfBirth = decoder.decodeObjectForKey("\(literal.User).dateOfBirth") as? NSDate

        var gender: Gender? = nil
        if let genderString = decoder.decodeObjectForKey("\(literal.User).gender") as? String {
            gender = Gender(rawValue: genderString)
        }

        let lastName = decoder.decodeObjectForKey("\(literal.User).lastName") as? String
        let firstName = decoder.decodeObjectForKey("\(literal.User).firstName") as? String
        let countryIsoCode = decoder.decodeObjectForKey("\(literal.User).countryIsoCode") as? String

        let veritransToken = (decoder.decodeObjectForKey("\(literal.User).veritransToken") as? String).emptyOnNil()

        self.init(
            id: id
            , name: name
            , email: email
            , phoneNumber: phoneNumber
            , accountKitId: accountKitId
            , profileImageURL: profileImageURL
            , gender: gender
            , dateOfBirth: dateOfBirth
            , lastName: lastName
            , firstName: firstName
            , countryIsoCode: countryIsoCode
            , referralCode: referralCode
            , advertisingId: advertisingId
            , sendbirdAccessToken: sendbirdAccessToken
            , veritransToken: veritransToken
        )
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(id, forKey: "\(literal.User).id")
        coder.encodeObject(name, forKey: "\(literal.User).name")
        coder.encodeObject(email, forKey: "\(literal.User).email")
        coder.encodeObject(phoneNumber, forKey: "\(literal.User).phoneNumber")
        if accountKitId != nil {
            coder.encodeInteger(accountKitId!, forKey: "\(literal.User).accountKitId")
        }
        coder.encodeObject(profileImageURL, forKey: "\(literal.User).profileImageURL")
        coder.encodeObject(dateOfBirth, forKey: "\(literal.User).dateOfBirth")
        coder.encodeObject(gender?.rawValue, forKey: "\(literal.User).gender")
        coder.encodeObject(lastName, forKey: "\(literal.User).lastName")
        coder.encodeObject(firstName, forKey: "\(literal.User).firstName")
        coder.encodeObject(countryIsoCode, forKey: "\(literal.User).countryIsoCode")
        coder.encodeObject(referralCode, forKey: "\(literal.User).referralCode")
        coder.encodeObject(advertisingId, forKey: "\(literal.User).advertisingId")
        coder.encodeObject(sendbirdAccessToken, forKey: "\(literal.User).sendbirdAccessToken")
        coder.encodeObject(veritransToken, forKey: "\(literal.User).veritransToken")
    }

}

extension User: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> User? {
        guard let json = jsonRepresentation else {
            return nil
        }

        guard let id = json["id"] as? Int else {return nil}
        let name = json["name"] as? String
        let email = json["email"] as? String
        let phoneNumber = json["phone"] as? String
        let accountKitId = json["acckit_id"] as? Int
        let referralCode = json["referral_code"] as? String
        let sendbirdAccessToken = json["sendbird_access_token"] as? String
        guard let veritransToken = json["veritrans_access_token"] as? String else { return nil }
        var firstName: String? = name?.componentsSeparatedByString(" ").first // get firstName from name
        var lastName: String? = nil
        var profileImageURL: NSURL? = nil
        var countryIsoCode: String? = nil
        var dateOfBirth: NSDate? = nil
        var gender: Gender? = nil
        var advertisingId: String? = nil

        if let profile = json["profile"] as? [String: AnyObject] {
            firstName = profile["first_name"] as? String
            countryIsoCode = profile["country_iso_code"] as? String
            lastName = profile["last_name"] as? String

            profileImageURL = { () -> NSURL? in
                if let value = profile["uploaded_image_url"] as? String { return NSURL(string: value) }
                return nil
            }()

            dateOfBirth = { () -> NSDate? in
                if let value = profile["date_of_birth"] as? String { return value.APIDate }
                return nil
            }()

            gender = { () -> Gender? in
                if let value = profile["gender"] as? String { return Gender(rawValue: value) }
                return nil
            }()

            advertisingId = { () -> String? in
                return profile["advertising_id"] as? String
            }()
        }

        let result = User(id: id
            , name: name
            , email: email
            , phoneNumber: phoneNumber
            , accountKitId: accountKitId
            , profileImageURL: profileImageURL
            , gender: gender
            , dateOfBirth: dateOfBirth
            , lastName: lastName
            , firstName: firstName
            , countryIsoCode: countryIsoCode
            , referralCode: referralCode
            , advertisingId: advertisingId
            , sendbirdAccessToken: sendbirdAccessToken
            , veritransToken: veritransToken
)
        return result
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email
}
