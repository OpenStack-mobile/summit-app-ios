//
//  VenuesMapViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//import GoogleMaps
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
        
        let summit = SummitManager.shared.summit.value
        
        let predicate: Predicate = "summit.id" == summit
            &&& "locationType" == Venue.LocationType.Internal.rawValue
            &&& .keyPath("latitude") != .value(.null)
            &&& .keyPath("longitude") != .value(.null)
        
        let venues = try! VenueListItem.filter(predicate, context: Store.shared.managedObjectContext)
        
        var bounds = GMSCoordinateBounds()
        
        for venue in venues {
            
            guard let location = venue.location
                else { fatalError("Cannot show venue with no coordinates: \(venue)") }
            
            let marker = GMSMarker()
            marker.icon = R.image.map_pin()!
            marker.position = location
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
        
        showLocationDetail(venue)
        
        return true
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Map")
    }
}
