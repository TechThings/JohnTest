//
//  HomeSection.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum HomeSectionType: String {
    case Featured = "featured"
    case Offers = "offers"
    case Collections = "collections"
    case Partners = "partners"
}

final class HomeSection {

    let name: String
    // TAG: Thanh
    // TODO: This shoud store a RequestPayload, Not a dectionary. Make the request payloads confirm to Serializable, then create them using the parameters you received from API
//    let requestPayload: RequestPayload
    let parameters: [String: AnyObject]
    let type: HomeSectionType

    init(
        name: String
//        , requestPayload: RequestPayload
        , parameters: [String: AnyObject]
        , type: HomeSectionType
        ) {
        self.name = name
//        self.requestPayload = requestPayload
        self.parameters = parameters
        self.type = type
    }
}

extension HomeSection: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> HomeSection? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let name = json["name"] as? String else {return nil}
        guard let parameters = json["parameters"] as? [String: AnyObject] else {return nil}
        guard let typeString = json["type"] as? String,
            let type = HomeSectionType(rawValue: typeString)
            else {return nil}

        let result = HomeSection(
            name: name
            , parameters: parameters
            , type: type
        )
        return result
    }
}
