//
//  Double.swift
//
//  Created by Nazih Shoura on 17/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
