//
//  Channel.swift
//  FAVE
//
//  Created by Nazih Shoura on 03/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import SendBirdSDK

final class Channel: NSObject, NSCoding {

    let ownerId: Int
    let url: NSURL
    let listing: ListingType
    let citySlug: String
    var chatParticipants: [ChatParticipant]
    let messagingServiceChannel: Variable<SendBirdMessagingChannel?>

    init(
        ownerId: Int
        , url: NSURL
        , listing: ListingType
        , citySlug: String
        , chatParticipants: [ChatParticipant]
        , sendBirdMessagingChannel: SendBirdMessagingChannel? = nil
        ) {
        self.messagingServiceChannel = Variable(nil)
        self.ownerId = ownerId
        self.url = url
        self.listing = listing
        self.citySlug = citySlug
        self.chatParticipants = chatParticipants
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        guard let ownerId = aDecoder.decodeObjectForKey("\(literal.Channel).ownerId") as? Int else { return nil }
        self.ownerId = ownerId

        guard let url = aDecoder.decodeObjectForKey("\(literal.Channel).url") as? NSURL else { return nil }
        self.url = url

        guard let listing = aDecoder.decodeObjectForKey("\(literal.Channel).listing") as? Listing else { return nil }
        self.listing = listing

        guard let citySlug = aDecoder.decodeObjectForKey("\(literal.Channel).citySlug") as? String else { return nil }
        self.citySlug = citySlug

        guard let chatParticipants = aDecoder.decodeObjectForKey("\(literal.Channel).chatParticipants") as? [ChatParticipant] else { return nil }
        self.chatParticipants = chatParticipants

        // SendBirdChannel is not NSCoding wtf!
//        self.messagingServiceChannel = Variable(aDecoder.decodeObjectForKey("\(literal.Channel).messagingServiceChannel") as? SendBirdMessagingChannel)
        self.messagingServiceChannel = Variable(nil)

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(ownerId, forKey: "\(literal.Channel).ownerId")
        aCoder.encodeObject(url, forKey: "\(literal.Channel).url")
        aCoder.encodeObject(listing, forKey: "\(literal.Channel).listing")
        aCoder.encodeObject(citySlug, forKey: "\(literal.Channel).citySlug")
        aCoder.encodeObject(chatParticipants, forKey: "\(literal.Channel).chatParticipants")
        // SendBirdChannel is not NSCoding wtf!
//        aCoder.encodeObject(messagingServiceChannel.value, forKey: "\(literal.Channel).messagingServiceChannel")
    }

    override func isEqual(object: AnyObject?) -> Bool {
        guard let channel = object as? Channel else { return false }

        let result = self.url.absoluteString == channel.url.absoluteString

        return result
    }

    func channelTitle(forUser user: User) -> String {
        // Exclude ourselves from the title

        let participantsNames = self.chatParticipants.filter { (chatParticipant: ChatParticipant) -> Bool in chatParticipant.id != user.id }.map { (chatParticipant: ChatParticipant) -> String in chatParticipant.firstName }
        return String.participantsString(fromNames: participantsNames)
    }
}

extension Channel: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> Channel? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let ownerId = json["owner_id"] as? Int else {return nil}

        guard let url = { () -> NSURL? in
            guard let value = json["channel_url"] as? String else { return nil}
            return NSURL(string: value)
            }() else {return nil}

        guard let listing = Listing.serialize(json["listing"]) else {return nil}
        guard let citySlug = json["city_slug"] as? String else {return nil}

        guard let chatParticipants = { () -> [ChatParticipant]? in
            guard let chatParticipantsRepresentation = json["participants"] as? [AnyObject] else { return nil }
            var chatParticipants = [ChatParticipant]()
            for chatParticipantRepresentation in chatParticipantsRepresentation {
                if let chatParticipant = ChatParticipant.serialize(chatParticipantRepresentation) {
                    chatParticipants.append(chatParticipant)
                }
            }

            if chatParticipants.isEmpty {
                return nil
            }
            return chatParticipants

        }() else {return nil}

        let result = Channel(
            ownerId: ownerId
            , url: url
            , listing: listing
            , citySlug: citySlug
            , chatParticipants: chatParticipants
        )

        return result
    }
}

extension Channel: Deserializable {
    func deserialize() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()

        parameters["channel_url"] = url.absoluteString
        parameters["listing_id"] = listing.id
        parameters["city_slug"] = citySlug
        parameters["participants"] = chatParticipants.map { (chatParticipant: ChatParticipant) -> [String: AnyObject] in chatParticipant.deserialize()}

        return parameters
    }
}
