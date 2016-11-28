//
//  OutletMapAnnotationView.swift
//  KFIT
//
//  Created by Nazih Shoura on 17/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import DeviceKit

final class OutletMapAnnotationView: MKAnnotationView {
    private(set) var showingCustomCallout: Bool = false
    private weak var outletCalloutView: UIView?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func showOutletCalloutView(outletCalloutView: UIView) {
        var rect = CGRect.zero
        rect = CGRect(x: 0, y: 0, width: 310, height: 220)

        // 13 is half the width of the pin image
        outletCalloutView.frame = CGRectMake(-(rect.size.width / 2) + 13, -(rect.size.height), rect.size.width, rect.size.height)
        outletCalloutView.setNeedsLayout()
        outletCalloutView.layoutIfNeeded()
        outletCalloutView.alpha = 0

        addSubview(outletCalloutView)
        self.outletCalloutView = outletCalloutView
        UIView.animateWithDuration(0.2, animations: {
            self.outletCalloutView!.alpha = 1
            }) { _ in
                self.showingCustomCallout = true
        }
    }

    /**
     If there's a custom callout that was previously shown, it will be removed. Otherwise, this method dosen't do anything
     */
    func hideOutletCalloutView() {
        if self.outletCalloutView != nil {
            UIView.animateWithDuration(0.2, animations: {
                self.outletCalloutView!.alpha = 0
            }) { _ in
                self.outletCalloutView!.removeFromSuperview()
            }
        }
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        if let _ = hitView {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var isInside = CGRectContainsPoint(self.bounds, point)
        if !isInside {
            for view in self.subviews {
                isInside = CGRectContainsPoint(view.frame, point)
                if isInside {break}
            }
        }
        return isInside
    }
}
