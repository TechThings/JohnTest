//
//  AddBTPaymentMethodAPIDefault.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddBTPaymentMethodAPIDefault: Refreshable, Cachable {
    var <#Provided Variable#>: Variable<<#Type#>> {get}
}

class AddBTPaymentMethodAPIDefaultDefault: Provider, AddBTPaymentMethodAPIDefault {
    // MARK:- Dependency
    let <#Dependency#>: <#Type#>

    // MARK:- Provider variables
    let <#variables#>: Variable<<#Type#>>

    init(
        <#Dependency#>: <#Type#> = <#Dependency default#> ()
        ) {
        self.<#Dependency#> = <#Dependency#>

        let cashed<#variables#> = AddBTPaymentMethodAPIDefault.loadCacheFor<#variables#>()
        <#variables#> = Variable(cashed<#variables#>)

        super.init()

        // MARK:- <#Provided Variable#>
        // Cache the <#Provided Variable#>
        <#Provided Variable#>
            .asObservable()
            .subscribeNext { (<#Provided Variable#>: <#Provided Variable Type#>) in
                AddBTPaymentMethodAPIDefaultDefault<#Provided Variable#>()
            }.addDisposableTo(disposeBag)

        // Clear the cashe on logout
        app
            .logoutSignal
            .subscribeNext { AddBTPaymentMethodAPIDefaultDefault.clearCacheFor<#Provided Variable#>() }
            .addDisposableTo(disposeBag)

        // Set to the default value logout
        app
            .logoutSignal
            .map { <#Provided Variable Default value#> }
            .bindTo(<#Provided Variable#>)
            .addDisposableTo(disposeBag)
    }
}

extension AddBTPaymentMethodAPIDefaultDefault {
    func refresh() {
        // Refresh the provided variables
    }
}

// MARK:- Cashe
extension AddBTPaymentMethodAPIDefaultDefault {
    static func clearCacheFor<#Provided Variable#>() {
    NSUserDefaults
    .standardUserDefaults()
    .setObject(
    nil, forKey: "\(literal.AddBTPaymentMethodAPIDefaultDefault).<#Provided Variable#>")
    }

    static func cache(<#Provided Variable#> <#Provided Variable#>: <#Provided Variable Type#>) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(<#Provided Variable#>)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.AddBTPaymentMethodAPIDefaultDefault).<#Provided Variable#>")
    }

    static func loadCacheFor<#Provided Variable#>() -> <#Provided Variable Type#> {
    guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.AddBTPaymentMethodAPIDefaultDefault).<#Provided Variable#>") as? NSData else {
    return <#Provided Variable Default value#>
    }

    guard let <#Provided Variable#> = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? <#Provided Variable Type#> else {
    AddBTPaymentMethodAPIDefaultDefault.clearCacheFor<#Provided Variable#>()
    return <#Provided Variable Default value#>
    }
    return <#Provided Variable#>
    }
}

enum AddBTPaymentMethodAPIDefaultError: ErrorType {
    case <#Error#>

    var localizedDescription: String {
        switch self {
        case .<#Error#>:
        return NSLocalizedString("<#Error Description#>", comment: "")
        }
    }

    var localizedFailureReason: String {
        switch self {
        case .<#Error#>:
        return NSLocalizedString("<#Error Failure Reason#>", comment: "")
        }
    }
}
