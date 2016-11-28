//
//  Review.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class Review {

    let name: String
    let rating: Float
    let comment: String
    let created_at: String

    init(
        name: String
        , rating: Float
        , comment: String
        , created_at: String
        ) {
        self.name = name
        self.rating = rating
        self.comment = comment
        self.created_at = created_at
    }
}

extension Review: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> Review? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let name = json["name"] as? String else {return nil}
        guard let rating = json["rating"] as? Float else {return nil}
        guard let comment = json["comment"] as? String else {return nil}
        guard let created_at = json["created_at"] as? String else {return nil}

        let result = Review(
            name: name
            , rating: rating
            , comment: comment
            , created_at: (created_at.RFC3339DateTime?.RedeemDateString)!
        )
        return result
    }
}
