//
//  ShareMessage.swift
//  FAVE
//
//  Created by Thanh KFit on 7/21/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class ShareMessage: NSObject, NSCoding {
    let email: String?
    let message: String?
    let twitter: String?
    let whatsapp: String?
    let url: NSURL?
    let copyString: String?

    init(
        email: String?
        , message: String?
        , twitter: String?
        , whatsapp: String?
        , url: NSURL?
        , copyString: String?
        ) {
        self.email = email
        self.message = message
        self.twitter = twitter
        self.whatsapp = whatsapp
        self.url = url
        self.copyString = copyString
        super.init()
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObjectForKey("\(literal.ShareMessage).email") as? String
        self.message = aDecoder.decodeObjectForKey("\(literal.ShareMessage).message") as? String
        self.twitter = aDecoder.decodeObjectForKey("\(literal.ShareMessage).twitter") as? String
        self.whatsapp = aDecoder.decodeObjectForKey("\(literal.ShareMessage).whatsapp") as? String
        self.url = aDecoder.decodeObjectForKey("\(literal.ShareMessage).url") as? NSURL
        self.copyString = aDecoder.decodeObjectForKey("\(literal.ShareMessage).copyString") as? String

        super.init()
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(email, forKey: "\(literal.ShareMessage).email")
        aCoder.encodeObject(message, forKey: "\(literal.ShareMessage).message")
        aCoder.encodeObject(twitter, forKey: "\(literal.ShareMessage).twitter")
        aCoder.encodeObject(whatsapp, forKey: "\(literal.ShareMessage).whatsapp")
        aCoder.encodeObject(url, forKey: "\(literal.ShareMessage).url")
        aCoder.encodeObject(copyString, forKey: "\(literal.ShareMessage).copyString")
    }
}

extension ShareMessage: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> ShareMessage? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        let email = json["email"] as? String
        let message = json["message"] as? String
        let twitter = json["twitter"] as? String
        let whatsapp = json["whatsapp"] as? String
        var url: NSURL? = nil
        if let urlString = json["url"] as? String {
            url = NSURL(string: urlString)
        }
        let copyString = json["copy"] as? String

        let result = ShareMessage(
            email: email
            , message: message
            , twitter: twitter
            , whatsapp: whatsapp
            , url: url
            , copyString: copyString
        )
        return result
    }
}
