//
//  CLLocation.swift
//
//  Created by Nazih Shoura on 18/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

private let distanceFormatterMetric: MKDistanceFormatter = {
    let distanceFormatter = MKDistanceFormatter()
    distanceFormatter.units = .Metric
    distanceFormatter.unitStyle = .Default
    return distanceFormatter
}()

extension CLLocation {
    func userVisibleDistanceToLocation(lcoation: CLLocation) -> String {
        let distance = self.distanceFromLocation(lcoation)
        let distanceString = distanceFormatterMetric.stringFromDistance(distance)
        return distanceString
    }
}
