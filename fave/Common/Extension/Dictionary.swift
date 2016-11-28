//
//  Dictionary.swift
//
//  Created by Nazih Shoura on 14/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

func += <KeyType, ValueType> (inout left: [KeyType: ValueType], right: [KeyType: ValueType]) {
    for (key, value) in right {
        left[key] = value
    }
}

func + <KeyType, ValueType> (left: [KeyType: ValueType], right: [KeyType: ValueType]) -> [KeyType: ValueType] {
    var result = left
    for (key, value) in right {
        result[key] = value
    }
    return result
}
