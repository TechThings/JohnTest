//
//  CollectionType.swift
//
//  Created by Nazih Shoura on 26/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension CollectionType where Generator.Element: Identifiable {

    func indexOf(element: Self.Generator.Element) -> Self.Index? {
        return self.indexOf { $0.id == element.id }
    }
}
