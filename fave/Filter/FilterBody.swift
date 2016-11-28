//
//  Filter.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class FilterBody {
    let type: String
    let sections: [FilterSection]

    init(
        type: String
        , sections: [FilterSection]
        ) {
        self.type = type
        self.sections = sections
    }
}

extension FilterBody: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> FilterBody? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let type = json["type"] as? String else {return nil}

        var sections = [FilterSection]()
        if let value = json["sections"] as? [AnyObject] {
            for representation in value {
                if let section = FilterSection.serialize(representation) {
                    sections.append(section)
                }
            }
        }

        let result = FilterBody(type: type, sections: sections)
        return result
    }
}
