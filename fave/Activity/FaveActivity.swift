//
//  FaveActivity.swift
//  FAVE
//
//  Created by Kevin Mun on 06/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

enum ListingType {
    case <#case#>
}

class FaveActivity: NSObject, NSCoding {
    let id: Int
    let name: String
    let descriptionActivity: String?
    let tips: String?
    let purchasable: Bool
    let allAccess: Bool
    let purchaseDetails: PurchaseDetails
    let activityImage: NSURL?
    let company: Company
    let outlet: Outlet

    init(id: Int, name: String, descriptionActivity: String?, purchasable: Bool, allAccess: Bool, purchaseDetails: PurchaseDetails, activityImage: NSURL? ,company: Company, outlet: Outlet, tips: String?) {
        self.id = id
        self.name = name
        self.descriptionActivity = descriptionActivity
        self.purchasable = purchasable
        self.allAccess = allAccess
        self.purchaseDetails = purchaseDetails
        self.activityImage = activityImage
        self.company = company
        self.outlet = outlet
        self.tips = tips
    }

    // MARK: NSCoding
    @objc required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("FaveActivity.id")
        self.name = aDecoder.decodeObjectForKey("FaveActivity.name") as! String
        self.descriptionActivity = aDecoder.decodeObjectForKey("FaveActivity.descriptionActivity") as! String?
        self.purchasable = aDecoder.decodeBoolForKey("FaveActivity.purchasable")
        self.allAccess = aDecoder.decodeBoolForKey("FaveActivity.allAccess")
        self.purchaseDetails = aDecoder.decodeObjectForKey("FaveActivity.purchaseDetails") as! PurchaseDetails
        self.activityImage = aDecoder.decodeObjectForKey("FaveActivity.activityImage") as? NSURL
        self.company = aDecoder.decodeObjectForKey("FaveActivity.company") as! Company
        self.outlet = aDecoder.decodeObjectForKey("FaveActivity.outlet") as! Outlet
        self.tips = aDecoder.decodeObjectForKey("FaveActivity.tips") as! String?
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(id, forKey: "FaveActivity.id")
        aCoder.encodeObject(name, forKey: "FaveActivity.name")
        aCoder.encodeObject(descriptionActivity, forKey: "FaveActivity.descriptionActivity")
        aCoder.encodeBool(purchasable, forKey: "FaveActivity.purchasable")
        aCoder.encodeBool(allAccess, forKey: "FaveActivity.allAccess")
        aCoder.encodeObject(purchaseDetails, forKey: "FaveActivity.purchaseDetails")
        aCoder.encodeObject(activityImage, forKey: "FaveActivity.activityImage")
        aCoder.encodeObject(company, forKey: "FaveActivity.company")
        aCoder.encodeObject(outlet, forKey: "FaveActivity.outlet")
        aCoder.encodeObject(tips, forKey: "FaveActivity.tips")

    }

    func getDisplayImage() -> NSURL {
        if let activityImage = activityImage {
            return activityImage
        } else {
            return company.profileImageURL
        }
    }

    // helper method solely for analytics
    func getActivityTypeForAnalytics() -> Int {
        if (purchasable && allAccess) {
            return 3
        } else if (purchasable) {
            return 2
        } else {
            return 1
        }
    }
}

extension FaveActivity: Serializable {
    class func serialize(jsonRepresentation: AnyObject?) -> FaveActivity? {

        guard let json = jsonRepresentation as? [String : AnyObject] else {
            return nil
        }

        // Properties to initialize (copy from the object being serilized)
        var id: Int!
        var name: String!
        var descriptionActivity: String?
        var activityImage: NSURL?
        var purchasable: Bool!
        var allAccess: Bool!
        var purchaseDetails: PurchaseDetails!
        var company: Company!
        var outlet: Outlet!
        var tips: String!

        // Properties initialization
        if let value = json["id"] as? Int {
            id = value
        }

        if let value = json["name"] as? String {
            name = value
        }

        if let value = json["description"] as? String {
            descriptionActivity = value
        }

        if let value = json["purchasable"] as? Bool {
            purchasable = value
        }

        if let value = json["all_access"] as? Bool {
            allAccess = value
        }

        if let value = json["featured_image"] as? String {
            activityImage = NSURL(string: value)
        }

        if let value = json["purchase_details"] {
            purchaseDetails = PurchaseDetails.serialize(value)
        }

        if let value = json["company"] {
            company = Company.serialize(value)
        }

        if let value = json["outlet"] {
            outlet = Outlet.serialize(value)
        }

        if let value = json["tips"] as? String {
            tips = value
        }

        // Verify properties and initialize object
        if let id = id, name = name, purchasable = purchasable, purchaseDetails = purchaseDetails, company = company, outlet = outlet {
            let result = FaveActivity(id: id, name: name, descriptionActivity: descriptionActivity, purchasable: purchasable,  allAccess: allAccess, purchaseDetails: purchaseDetails, activityImage: activityImage, company: company, outlet: outlet, tips:tips)

            return result
        }
        return nil
    }
}
