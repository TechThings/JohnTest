//
//  Category.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class SubCategory: NSObject, NSCoding {

    let id: Int
    let name: String
    let icon_url: NSURL?
    let color_hex: UIColor?

    init(id: Int,
         name: String,
         icon_url: NSURL?,
         color_hex: UIColor?
    ) {
        self.id = id
        self.name = name
        self.icon_url = icon_url
        self.color_hex = color_hex
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("\(literal.Category).id") as! Int
        self.name = aDecoder.decodeObjectForKey("\(literal.Category).name") as! String
        self.icon_url = aDecoder.decodeObjectForKey("\(literal.Category).icon_url") as? NSURL
        self.color_hex = aDecoder.decodeObjectForKey("\(literal.Category).color_hex") as? UIColor
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "\(literal.Category).id")
        aCoder.encodeObject(name, forKey: "\(literal.Category).name")
        aCoder.encodeObject(name, forKey: "\(literal.Category).icon_url")
        aCoder.encodeObject(name, forKey: "\(literal.Category).color_hex")
    }

}

extension SubCategory: Serializable {
    static func serialize(jsonRepresentation: AnyObject?) -> SubCategory? {
        guard let json = jsonRepresentation as? [String:AnyObject] else {
            return nil
        }

        // Properties to initialize
        var id: Int!
        var name: String!
        var icon_url: NSURL?
        var color_hex: UIColor?

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }
        if let value = json["name"] as? String {
            name = value
        }
        if let value = json["icon_url"] as? String {
            if let url = NSURL(string: value) {
                icon_url = url
            }
        }
        if let value = json["color_hex"] as? String {
            color_hex = UIColor(hexStringFast: value)

        }

        // Verify properties and initialize object
        if let id = id, name = name {
            let result = SubCategory(
                    id: id,
                    name: name,
                    icon_url: icon_url,
                    color_hex: color_hex
                    )
            return result
        }
        return nil
    }
}
