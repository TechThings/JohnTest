//
//  FilterSectionData.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class FilterSectionData {

    let id: Int
    let name: String
    let label: String?

    init(
        id: Int
        , name: String
        , label: String?
        ) {
        self.id = id
        self.name = name
        self.label = label
    }
}

extension FilterSectionData: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> FilterSectionData? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let id = json["id"] as? Int else {return nil}
        guard let name = json["name"] as? String else {return nil}
        let label = json["label"] as? String

        let result = FilterSectionData(id: id, name: name, label: label)
        return result
    }
}
