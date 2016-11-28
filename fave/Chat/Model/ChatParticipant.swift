//
//  ChatParticipant.swift
//  FAVE
//
//  Created by Michael Cheah on 8/2/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

extension ChatParticipant: Avatarable {
    var imageURL: NSURL? { return self.profileImageUrl }
    var firstLetter: Character {
        if let character = self.firstName.characters.first { return character}
        return "?".characters.first!
    }
    var lastLetter: Character? { return self.lastName.characters.first }
}

final class ChatParticipant: NSObject, NSCoding {

    let id: Int?
    let firstName: String
    let lastName: String
    let profileImageUrl: NSURL?
    let phoneNumber: String
    let participationStatus: UserParticipationStatus
    let participationStatusUserVisible: String
    var fullName: String {
        return firstName + " " + lastName
    }

    var initials: String {
        if let firstChar = firstName.characters.first, let secondChar = lastName.characters.first {
            return "\(firstChar)\(secondChar)"
        } else if let firstChar = firstName.characters.first {
            return "\(firstChar)"
        } else {
            return ""
        }
    }

    init(id: Int?
        , firstName: String
        , lastName: String
        , profileImageUrl: NSURL?
        , phoneNumber: String
        , participationStatus: UserParticipationStatus
        , participationStatusUserVisible: String
        ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
        self.participationStatus = participationStatus
        self.participationStatusUserVisible = participationStatusUserVisible
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).id") as? Int

        guard let firstName = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).firstName") as? String else { return nil }
        self.firstName = firstName

        guard let lastName = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).lastName") as? String else { return nil }
        self.lastName = lastName

        self.profileImageUrl = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).profileImageUrl") as? NSURL

        guard let phoneNumber = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).phoneNumber") as? String else { return nil }
        self.phoneNumber = phoneNumber

        self.participationStatus = { () -> UserParticipationStatus in
            guard let userParticipationStatusString = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).userParticipationStatus") as? String else { return UserParticipationStatus.Invited }
            guard let result = UserParticipationStatus(rawValue: userParticipationStatusString) else { return UserParticipationStatus.Invited }
            return result
        }()

        guard let participationStatusUserVisible = aDecoder.decodeObjectForKey("\(literal.ChatParticipant).participationStatusUserVisible") as? String else { return nil }
        self.participationStatusUserVisible = participationStatusUserVisible

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "\(literal.ChatParticipant).id")
        aCoder.encodeObject(firstName, forKey: "\(literal.ChatParticipant).firstName")
        aCoder.encodeObject(lastName, forKey: "\(literal.ChatParticipant).lastName")
        aCoder.encodeObject(profileImageUrl, forKey: "\(literal.ChatParticipant).profileImageUrl")
        aCoder.encodeObject(phoneNumber, forKey: "\(literal.ChatParticipant).phoneNumber")
        aCoder.encodeObject(participationStatus.rawValue, forKey: "\(literal.ChatParticipant).participationStatus")
        aCoder.encodeObject(participationStatusUserVisible, forKey: "\(literal.ChatParticipant).participationStatusUserVisible")
    }

    override func isEqual(object: AnyObject?) -> Bool {
        guard let chatParticipant = object as? ChatParticipant else { return false }

        let result = self.id == chatParticipant.id && self.phoneNumber == chatParticipant.phoneNumber

        return result
    }
}

func ==(lhs: ChatParticipant, rhs: ChatParticipant) -> Bool {
    let result = lhs.id == rhs.id && lhs.phoneNumber == rhs.phoneNumber
    return result
}

extension ChatParticipant: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ChatParticipant? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        let id = json["user_id"] as? Int

        guard let phoneNumber = json["phone"] as? String else { return nil }

        guard let name = json["name"] as? String else { return nil }
        let firstName = { () -> String in
            if let name = name.componentsSeparatedByString(" ").first { return name }
            return ""
        }()

        var lastName: String = ""
        if(name.containsString(" ")) {
            if let tempName = name.componentsSeparatedByString("").last {
                lastName = tempName
            }
        }

        let profileImageUrl = { () -> NSURL? in
            guard let value = json["user_image_url"] as? String else { return nil}
            return NSURL(string: value)
            }()

        let participationStatus = { () -> UserParticipationStatus in
            guard let value = json["status"] as? String else { return UserParticipationStatus.Invited }
            guard let result = UserParticipationStatus(rawValue: value) else { return UserParticipationStatus.Invited }

            return result
        }()

        let participationStatusUserVisible = { () -> String in
            guard let value = json["display_status"] as? String else { return ""}
            return value
        }()

        let result = ChatParticipant(id: id, firstName: firstName, lastName: lastName, profileImageUrl: profileImageUrl, phoneNumber: phoneNumber, participationStatus: participationStatus, participationStatusUserVisible: participationStatusUserVisible)
        return result
    }
}

extension ChatParticipant: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["name"] = fullName
        parameters["phone"] = phoneNumber

        return parameters
    }
}

enum UserParticipationStatus: String {
    case NotInvited = "not_invited"
    case Invited = ""
    case Maybe = "maybe"
    case Going = "yes"
    case NotGoing = "no"

    // Higher means higher priority
    var sortingPriority: Int {
        switch self {

        case .NotInvited:
            return -1
        case .Invited:
            return 0
        case .NotGoing:
            return 1
        case .Maybe:
            return 2
        case .Going:
            return 3
        }
    }
}
