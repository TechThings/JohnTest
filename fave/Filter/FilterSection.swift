//
//  FilterSection.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class FilterSection {

    let title: String
    let viewType: FilterViewType
    let queryType: FilterQueryType
    let data: [AnyObject]

    init(
        title: String,
        viewType: FilterViewType,
        queryType: FilterQueryType,
        data: [AnyObject]
        ) {
        self.title = title
        self.viewType = viewType
        self.queryType = queryType
        self.data = data
    }
}

extension FilterSection: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> FilterSection? {
        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        guard let title = json["title"] as? String else {return nil}

        guard let viewTypeString = json["view_type"] as? String,
            let viewType = FilterViewType(rawValue: viewTypeString) else {
                return nil
        }

        guard let queryTypeString = json["query_type"] as? String,
            let queryType = FilterQueryType(rawValue: queryTypeString) else {
            return nil
        }

        var data = [AnyObject]()

        if let value = json["data"] as? [AnyObject] {
            for representation in value {
                switch viewType {
                case .Single:
                    if let sectionData = FilterSectionData.serialize(representation) {
                        data.append(sectionData)
                    }
                case .SubCategories:
                    if let sectionData = SubCategory.serialize(representation) {
                        data.append(sectionData)
                    }
                }
            }
        }

        let result = FilterSection(title: title, viewType: viewType, queryType: queryType, data: data)
        return result
    }
}
