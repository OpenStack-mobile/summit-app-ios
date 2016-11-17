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
import CoreData

@objc(OSSTVVenueMapViewController)
final class VenueMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    weak var delegate: VenueMapViewControllerDelegate?
    
    var selectedVenue: Identifier? {
        
        didSet { if isViewLoaded() { showSelectedVenue() } }
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    
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
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        if let venueID = self.selectedVenue,
            let venue = Store.shared.realm.objects(RealmVenue).filter("id = %@", venueID).first,
            let selectedAnnotation = mapView.annotations.filter({ $0.coordinate.latitude == Double(venue.lat) && $0.coordinate.longitude == Double(venue.long) }).first {
            
            mapView.selectAnnotation(selectedAnnotation, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let annotation = view.annotation as! VenueAnnotation
        
        delegate?.venueMapViewController(self, didSelectVenue: annotation.venue)
    }
}

// MARK: - Supporting Types

protocol VenueMapViewControllerDelegate: class {
    
    /// Informs the delegate that the venue selection has changed via the Map interface.
    func venueMapViewController(controller: VenueMapViewController, didSelectVenue venue: Identifier)
}

final class VenueAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    
    let subtitle: String?
    
    let coordinate: CLLocationCoordinate2D
    
    let venue: Identifier
    
    init?(venue: Venue) {
        
        guard let location = venue.location
            else { return nil }
        
        self.title = venue.name
        self.subtitle = venue.fullAddress
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.venue = venue.identifier
    }
}
