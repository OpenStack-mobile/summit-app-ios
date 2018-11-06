//
//  VenueLocationDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
//import GoogleMaps
import CoreSummit

final class VenueLocationDetailViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - IB Outlets

    @IBOutlet private(set) weak var mapView: GMSMapView!
    
    // MARK: - Properties
    
    var venue: Identifier!
    
    // MARK: - Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        updateUI()
    }
    
    // MARK: - Methods
    
    private func updateUI() {
        
        assert(self.venue != nil, "No venue set")
        
        guard let venue = try! VenueListItem.find(self.venue, context: Store.shared.managedObjectContext)
            else { fatalError("Venue not found in cache. Invalid venue \(self.venue)") }
        
        guard let location = venue.location
            else { fatalError("Venue is not geolocated") }
        
        let marker = GMSMarker()
        var bounds = GMSCoordinateBounds()
        marker.position = location
        marker.map = mapView
        marker.title = venue.name
        marker.icon = #imageLiteral(resourceName: "map_pin")
        bounds = bounds.includingCoordinate(marker.position)
        mapView.selectedMarker = marker
        mapView.moveCamera(GMSCameraUpdate.fit(bounds))
        mapView.animate(toZoom: 15)
    }
}
