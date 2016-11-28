//
//  OutletGGMapsSearchResponsePayload.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

struct OutletGGMapsSearchResponsePayload {
    var outletsSearch = [OutletGGMapsSearch]()

    init(outletsSearch: [OutletGGMapsSearch]) {
        self.outletsSearch = outletsSearch
    }
}

extension OutletGGMapsSearchResponsePayload : Serializable {

    typealias Type = OutletGGMapsSearchResponsePayload

    static func serialize(jsonRepresentation: AnyObject?) -> OutletGGMapsSearchResponsePayload? {

        var outletsSearch = [OutletGGMapsSearch]()
        if let json = jsonRepresentation as? [String: AnyObject] {
            if let value = json["results"] as? [AnyObject] {
                for representation in value {
                    if let outlet = OutletGGMapsSearch.serialize(representation) {
                        outletsSearch.append(outlet)
                    }
                }
            }
        }

        let result = OutletGGMapsSearchResponsePayload(outletsSearch: outletsSearch)
        return result
    }
}
