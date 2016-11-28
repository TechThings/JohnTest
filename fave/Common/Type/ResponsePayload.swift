//
//  ResponsePayload.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/6/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol ResponsePayload {
    static var logger: Logger { get }
}

extension ResponsePayload {
    static var logger: Logger { return loggerDefault }
}
