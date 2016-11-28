//
//  AdyenAuth3DS.swift
//  FAVE
//
//  Created by Light Dream on 25/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class AdyenAuth3DS: NSObject {

    let md: String
    let issuerURL: String
    let paRequest: String
    let termURL: String

    init(md: String, issuerURL: String, paRequest: String, termURL: String, apiService: APIService = apiServiceDefault) {
        self.md = md
        self.issuerURL = issuerURL
        self.paRequest = paRequest
        self.termURL = apiService.baseURL.absoluteString! + termURL
    }
}

extension AdyenAuth3DS: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> AdyenAuth3DS? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        guard let md = json["md"] as? String else {
            return nil
        }

        guard let issuerURL = json["issuer_url"] as? String else {
            return nil
        }

        guard let paRequest = json["pa_request"] as? String else {
            return nil
        }

        guard let termURL = json["term_url"] as? String else {
            return nil
        }

        let result = AdyenAuth3DS(md: md, issuerURL: issuerURL, paRequest: paRequest, termURL: termURL)
        return result
    }
}

extension AdyenAuth3DS: Deserializable {
    func deserialize() -> [String : AnyObject] {
        var params: [String: AnyObject] = [:]
        params["PaReq"] = self.paRequest
        params["MD"] = self.md
        params["TermUrl"] = self.termURL

        return params
    }
}
