//
//  VenuesMapViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import GoogleMaps

protocol VenuesMapViewControllerProtocol {
    func addMarkers(venues:[VenueListItem])
}

class VenuesMapViewController: UIViewController, VenuesMapViewControllerProtocol, GMSMapViewDelegate, IndicatorInfoProvider {
    
    var presenter: IVenuesMapPresenter!
    
    var mapView: GMSMapView!
    var dictionary = Dictionary<GMSMarker, Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = GMSMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.myLocationEnabled = true
        view = mapView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewLoad()
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        let venueId = dictionary[marker]
        presenter.showVenueDetail(venueId!)
        return true
    }
    
    func addMarkers(venues: [VenueListItem]) {
        var bounds = GMSCoordinateBounds()
        
        var marker: GMSMarker
        for venue in venues {
            marker = GMSMarker()
            marker.icon = UIImage(named: "map_pin")
            marker.position = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
            marker.title = venue.name
            marker.map = mapView
            
            bounds = bounds.includingCoordinate(marker.position)
            
            dictionary[marker] = venue.id
        }
        
        let update = GMSCameraUpdate.fitBounds(bounds)
        mapView.moveCamera(update)
        mapView.animateToZoom(mapView.camera.zoom - 1)
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Map")
    }

}
