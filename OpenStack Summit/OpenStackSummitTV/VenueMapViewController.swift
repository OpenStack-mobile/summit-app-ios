//
//  VenueMapViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import CoreSummit
import RealmSwift

@objc(OSSTVVenueMapViewController)
final class VenueMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var selectedVenue: Identifier? {
        
        didSet { showSelectedVenue() }
    }
    
    private var notificationToken: NotificationToken!
    
    // MARK: - Loading
    
    deinit {
        
        notificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        notificationToken = Store.shared.realm.addNotificationBlock { _ in self.updateUI() }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        // remove all annotations
        mapView.removeAnnotations(mapView.annotations)
        
        let locations = Venue.from(realm: Store.shared.realm.objects(RealmVenue)).filter { $0.location != nil }
        
        let annotations = locations.map { VenueAnnotation(venue: $0)! }
        
        mapView.addAnnotations(annotations)
        
        showSelectedVenue()
    }
    
    private func showSelectedVenue() {
        
        if let venueID = self.selectedVenue,
            let venue = Store.shared.realm.objects(RealmVenue).filter("id = %@", venueID).first,
            let selectedAnnotation = mapView.annotations.filter({ $0.coordinate.latitude == Double(venue.lat) && $0.coordinate.longitude == Double(venue.long) }).first {
            
            mapView.selectAnnotation(selectedAnnotation, animated: true)
            
        } else {
            
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    
}

// MARK: - Supporting Types

final class VenueAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    
    let subtitle: String?
    
    let coordinate: CLLocationCoordinate2D
    
    init?(venue: Venue) {
        
        guard let location = venue.location
            else { return nil }
        
        coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        title = venue.name
        
        subtitle = venue.fullAddress
    }
}
