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
import CoreSummit

final class VenuesMapViewController: UIViewController, GMSMapViewDelegate, IndicatorInfoProvider {
    
    // MARK: - Properties
    
    var mapView: GMSMapView!
    private(set) var dictionary = [GMSMarker: Int]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = GMSMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.myLocationEnabled = true
        view = mapView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        /// get Internal Venues with Coordinates
        let venues = VenueListItem.from(realm: Store.shared.realm.objects(RealmVenue).filter({ $0.isInternal && !$0.lat.isEmpty && !$0.long.isEmpty }))
        
        self.addMarkers(venues)
    }
    
    private func addMarkers(venues: [VenueListItem]) {
        var bounds = GMSCoordinateBounds()
        
        for venue in venues {
            let marker = GMSMarker()
            marker.icon = R.image.map_pin()!
            marker.position = CLLocationCoordinate2DMake(venue.location.latitude, venue.location.longitude)
            marker.title = venue.name
            marker.map = mapView
            
            bounds = bounds.includingCoordinate(marker.position)
            
            dictionary[marker] = venue.identifier
        }
        
        let update = GMSCameraUpdate.fitBounds(bounds)
        mapView.moveCamera(update)
        mapView.animateToZoom(mapView.camera.zoom - 1)
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        
        guard let venue = dictionary[marker]
            else { return false }
        
        let venueDetailViewController = R.storyboard.venue.venueDetailViewController()!
        venueDetailViewController.venue = venue
        
        self.showViewController(venueDetailViewController, sender: self)
        return true
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Map")
    }
}
