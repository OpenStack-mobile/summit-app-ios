//
//  VenueLocationDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreSummit

final class VenueLocationDetailViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - IB Outlets

    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.myLocationEnabled = true
        mapView.delegate = self
    }
    
    // MARK: - Methods
    
    func addMarker(venue: Venue) {
        let marker = GMSMarker()
        var bounds = GMSCoordinateBounds()
        marker.position = CLLocationCoordinate2DMake(venue.location.latitude, venue.location.longitude)
        marker.map = mapView
        marker.title = venue.name
        marker.icon = R.image.map_pin()!
        bounds = bounds.includingCoordinate(marker.position)
        mapView.selectedMarker = marker
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
    }
}
