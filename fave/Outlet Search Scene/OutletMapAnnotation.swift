//
//  OutletMapAnnotation.swift
//  KFIT
//
//  Created by Nazih Shoura on 17/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

@objc
final class OutletMapAnnotation: NSObject, MKAnnotation {
    var focused = false
    var outlet: Outlet!

    @objc let coordinate: CLLocationCoordinate2D

    init(outlet: Outlet) {
        self.coordinate = outlet.location.coordinate
        self.outlet = outlet
    }
}
