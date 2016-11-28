//
//  OutletsMapView.swift
//  KFIT
//
//  Created by Nazih Shoura on 15/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

final class OutletsMapView: View {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myLocationButton: UIButton!

    var viewModel: OutletsMapViewModel!

    private(set) weak var selectedOutletCalloutView: OutletCalloutView?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()
    }

    func setup() {
        clipsToBounds = true
        // mapView configuration
        mapView.mapType = .Standard
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    private func displayMarkersForOutletsFocusedCollection(outletsFocusedCollection: [(outlet: Outlet, focused: Bool)]) {
        for outletFocusedCollection in outletsFocusedCollection {
            let outletMapAnnotation = OutletMapAnnotation(outlet: outletFocusedCollection.outlet)

            outletMapAnnotation.focused = outletFocusedCollection.focused

            mapView.addAnnotation(outletMapAnnotation)
        }
    }
}

extension OutletsMapView: ViewModelBindable {
    func bind() {
        viewModel
            .region
            .asObservable()
            .subscribeNext { [weak self] region in
                if let region = region {
                    self?.mapView.setRegion(region, animated: true)
                }
            }.addDisposableTo(disposeBag)

        viewModel
            .resetMapTrigger
            .asObservable()
            .subscribeNext { [weak self] _ in
                if let strongSelf = self {
                strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                }
            }.addDisposableTo(disposeBag)

        viewModel
            .outletsFocusedCollectionToAdd
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.displayMarkersForOutletsFocusedCollection($0)
        }.addDisposableTo(disposeBag)

        myLocationButton
            .rx_tap
            .asObservable()
            .subscribeNext { [weak self] _ in
                self?.viewModel.updateRegion()
            }.addDisposableTo(disposeBag)
    }

    private func resetOutletAnnotationFocusForOutlets() {
    }

}

extension OutletsMapView: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {

        for (index, view) in views.enumerate() {
            if view.annotation is MKUserLocation {
                continue
            }

            // Check if current annotation is inside visible map rect, else go to next one
            let point: MKMapPoint  =  MKMapPointForCoordinate(view.annotation!.coordinate)
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue
            }

            let endFrame: CGRect = view.frame

            // Move annotation out of view
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.frame.size.height, view.frame.size.width, view.frame.size.height)

            // Animate drop
            let delay = 0.00 * Double(index)
            UIView.animateWithDuration(0.2
                , delay: delay
                , options: UIViewAnimationOptions.CurveEaseIn
                , animations: { _ in
                    view.frame = endFrame
                }
                , completion: { _ in
                }
            )
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        var outletMapAnnotationView: OutletMapAnnotationView? = nil
        if let outletMapAnnotation = annotation as? OutletMapAnnotation {
            if let view = mapView.dequeueReusableAnnotationViewWithIdentifier(String(OutletMapAnnotationView)) as? OutletMapAnnotationView {
                outletMapAnnotationView = view
            } else {
                outletMapAnnotationView = OutletMapAnnotationView(annotation: outletMapAnnotation, reuseIdentifier: String(OutletMapAnnotationView))
            }

            outletMapAnnotationView!.canShowCallout = false
            outletMapAnnotationView!.image = UIImage(named: "ic_map_marker")

            //outletMapAnnotationView!.image = outletMapAnnotation.focused ?
            //    UIImage(named: "ic_map_marker")
            //    : UIImage(named: "ic_map_marker")
        }
        return outletMapAnnotationView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let outletMapAnnotationView = view as? OutletMapAnnotationView {
            if let outletMapAnnotation = outletMapAnnotationView.annotation as? OutletMapAnnotation {

                // Create outletSearch callout view
                let outletCalloutViewModel = OutletCalloutViewModel(outlet: outletMapAnnotation.outlet)
                let outletCalloutView = OutletCalloutView()
                outletCalloutView.viewModel = outletCalloutViewModel
                outletCalloutView.bind()

                // Show the outletSearch callout view on the annotation view
                outletMapAnnotationView.showOutletCalloutView(outletCalloutView)

                // Observe the click event on the outletSearch call out view
                selectedOutletCalloutView = outletCalloutView
                selectedOutletCalloutView?
                    .backgroundButton
                    .rx_tap
                    .subscribeNext { [weak self] _ in

                        if let outlet = self?.selectedOutletCalloutView?.viewModel.outlet {
                            guard let company = outlet.company else { return }
                            let vc = OutletViewController.build(OutletViewControllerViewModel(outletId: outlet.id, companyId: company.id))
                            vc.hidesBottomBarWhenPushed = true
                            UIViewController.currentViewController?.navigationController?.pushViewController(vc, animated: true)
                        }

                    }.addDisposableTo(disposeBag)

                // Center the map on the selected annotation
                var center = mapView.convertCoordinate(view.annotation!.coordinate, toPointToView: mapView)
                center.y = center.y - 100
                mapView.setCenterCoordinate(mapView.convertPoint(center, toCoordinateFromView: mapView), animated: true)

            }
        }
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if let outletMapAnnotationView =  view as? OutletMapAnnotationView {
            outletMapAnnotationView.hideOutletCalloutView()
        }
    }
}

extension OutletsMapView: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}
