//
//  APIService.swift
//  KFIT
//
//  Created by Nazih Shoura on 02/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

protocol APIService {
    /**
     The base url to be used by th comfirming APIs
     
     - author: Nazih Shoura
     */
    var baseURL: NSURL {get}
}

final class APIServiceDefault: Service, APIService {

    var baseURL: NSURL {
        get {
            return NSURL(string: app.keys.BaseURLString)!
        }
    }

    init() {
        super.init()
    }
}
