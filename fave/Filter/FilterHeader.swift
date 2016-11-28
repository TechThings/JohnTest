//
//  FilterHeader.swift
//  FAVE
//
//  Created by Thanh KFit on 9/14/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

enum FilterViewType: String {
    case Single = "single"
    case SubCategories = "sub_categories"
}

enum FilterQueryType: String {
    case Category = "category_type"
    case PriceRanges = "price_ranges"
    case Distances = "distances"
    case CategoryIds = "category_ids"
}

final class FilterHeader {
    let title: String
    let viewType: FilterViewType
    let queryType: FilterQueryType
    let data: [FilterHeaderData]

    init(
        title: String,
        viewType: FilterViewType,
        queryType: FilterQueryType,
        data: [FilterHeaderData]
        ) {
        self.title = title
        self.viewType = viewType
        self.queryType = queryType
        self.data = data
    }
}

extension FilterHeader: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> FilterHeader? {
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

        var data = [FilterHeaderData]()
        if let value = json["data"] as? [AnyObject] {
            for represetation in value {
                if let sectionData = FilterHeaderData.serialize(represetation) {
                    data.append(sectionData)
                }
            }
        }

        let result = FilterHeader(title: title, viewType: viewType, queryType: queryType, data: data)
        return result
    }
}
