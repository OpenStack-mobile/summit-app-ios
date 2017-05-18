//
//  VenueMapViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation
import MapKit
import CoreSummit
import Predicate

@objc(OSSTVVenueMapViewController)
final class VenueMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    weak var delegate: VenueMapViewControllerDelegate?
    
    var selectedVenue: Identifier? {
        
        didSet { if isViewLoaded { showSelectedVenue() } }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<VenueManagedObject>!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //let predicate = NSPredicate(format: "(latitude != nil AND longitude != nil) AND summit.id == %@", summitID)
        let predicate: Predicate = .keyPath(#keyPath(VenueManagedObject.latitude)) != .value(.null)
            && .keyPath(#keyPath(VenueManagedObject.longitude)) != .value(.null)
            && #keyPath(VenueManagedObject.summit.id) == SummitManager.shared.summit.value
        
        let sort = [NSSortDescriptor(key: #keyPath(VenueManagedObject.venueType), ascending: true),
                    NSSortDescriptor(key: #keyPath(VenueManagedObject.name), ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Venue.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: sort,
                                                                   sectionNameKeyPath: #keyPath(VenueManagedObject.venueType),
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        if isDataLoaded {
            
            self.navigationItem.title = NSLocalizedString("Venues", comment: "")
            
            // reload map view if empty but shouldnt be
            if self.fetchedResultsController.fetchedObjects?.isEmpty == false && self.mapView.annotations.isEmpty {
                
                for venue in Venue.from(managedObjects: (self.fetchedResultsController.fetchedObjects ?? [])) {
                    
                    let annotation = VenueAnnotation(venue: venue)!
                    
                    mapView.addAnnotation(annotation)
                }
            }
            
            showSelectedVenue()
            
        } else {
            
            self.navigationItem.title = NSLocalizedString("Loading Summit...", comment: "")
        }
    }
    
    private func showSelectedVenue() {
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        if let venueID = self.selectedVenue,
            let venue = try! Venue.find(venueID, context: Store.shared.managedObjectContext),
            let selectedAnnotation = mapView.annotations.first(where: { $0.coordinate.latitude == Double(venue.latitude ?? "") && $0.coordinate.longitude == Double(venue.longitude ?? "") }) {
            
            mapView.selectAnnotation(selectedAnnotation, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation as! VenueAnnotation
        
        delegate?.venueMapViewController(self, didSelectVenue: annotation.venue)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        updateUI()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let managedObject = anObject as! VenueManagedObject
        
        let venue = Venue(managedObject: managedObject)
        
        guard let location = venue.location
            else { fatalError("Predicate must filter venues with no location") }
        
        switch type {
            
        case .insert:
            
            let annotation = VenueAnnotation(venue: venue)!
            
            mapView.addAnnotation(annotation)
            
        case .delete:
            
            guard let annotation = mapView.annotations.first(where: { ($0 as? VenueAnnotation)?.venue == venue.identifier })
                else { return }
            
            mapView.removeAnnotation(annotation)
            
        case .update:
            
            guard let annotation = mapView.annotations.first(where: { ($0 as? VenueAnnotation)?.venue == venue.identifier }) as? VenueAnnotation
                else { return }
            
            if annotation.coordinate.latitude == location.latitude
                && annotation.coordinate.longitude == location.longitude {
                
                // update title and subtitle
                annotation.title = venue.name
                annotation.subtitle = venue.fullAddress
                
            } else {
                
                // update coordinates
                let newAnnotation = VenueAnnotation(venue: venue)!
                mapView.removeAnnotation(annotation)
                mapView.addAnnotation(newAnnotation)
            }
            
        case .move: break
        }
    }
}

// MARK: - Supporting Types

protocol VenueMapViewControllerDelegate: class {
    
    /// Informs the delegate that the venue selection has changed via the Map interface.
    func venueMapViewController(_ controller: VenueMapViewController, didSelectVenue venue: Identifier)
}

final class VenueAnnotation: NSObject, MKAnnotation {
    
    let venue: Identifier
    
    let coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var subtitle: String?
        
    init?(venue: Venue) {
        
        guard let location = venue.location
            else { return nil }
        
        self.title = venue.name
        self.subtitle = venue.fullAddress
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.venue = venue.identifier
    }
}
