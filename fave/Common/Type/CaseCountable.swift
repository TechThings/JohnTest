//
//  CaseCountable.swift
//
//  Created by Nazih Shoura on 08/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

protocol CaseCountable {
    /**
     Calculate the number of cases the enum has
     
     - author: Nazih Shoura
     
     - returns: Number of cases the enum has
     */
    static func countCases() -> Int

    /// Number of cases the enum has
    static var caseCount: Int { get }
}

extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    static func countCases() -> Int {
        // starting at zero, verify whether the enum can be instantiated from the Int and increment until it cannot
        var count = 0
        while let _ = Self(rawValue: count) { count += 1 }
        return count
    }
}
