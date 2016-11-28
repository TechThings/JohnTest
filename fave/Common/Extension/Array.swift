//
//  Array.swift
//  FAVE
//
//  Created by Thanh KFit on 7/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

public extension SequenceType {

    /// Categorises elements of self into a dictionary, with the keys given by keyFunc

    func categorise<U: Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

public extension Array {
    func split(intoArrayOfArraysWithMaxSize splitSize: Int) -> [[Element]] {
        let splitSize = 100
        let ArrayOfArrays = self.startIndex.stride(to: self.count, by: splitSize).map {
            Array(self[$0 ..< $0.advancedBy(splitSize, limit: self.endIndex)])
        }
        return ArrayOfArrays
    }
}
