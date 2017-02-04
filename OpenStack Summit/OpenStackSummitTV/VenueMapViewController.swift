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
final class VenueMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    weak var delegate: VenueMapViewControllerDelegate?
    
    var selectedVenue: Identifier? {
        
        didSet { if isViewLoaded() { showSelectedVenue() } }
    }
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let predicate = NSPredicate(format: "(latitude != nil AND longitude != nil) AND summit.id == %@", summitID)
        
        let sort = [NSSortDescriptor(key: "venueType", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Venue.self, delegate: self, predicate: predicate, sortDescriptors: sort, sectionNameKeyPath: "venueType", context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
         updateUI()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        if isDataLoaded {
            
            self.navigationItem.title = NSLocalizedString("Venues", comment: "")
            
            // reload map view if empty but shouldnt be
            if self.fetchedResultsController.fetchedObjects?.isEmpty == false && self.mapView.annotations.isEmpty {
                
                for venue in Venue.from(managedObjects: (self.fetchedResultsController.fetchedObjects as! [VenueManagedObject])) {
                    
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
            let selectedAnnotation = mapView.annotations.firstMatching({ $0.coordinate.latitude == Double(venue.latitude ?? "") && $0.coordinate.longitude == Double(venue.longitude ?? "") }) {
            
            mapView.selectAnnotation(selectedAnnotation, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        let annotation = view.annotation as! VenueAnnotation
        
        delegate?.venueMapViewController(self, didSelectVenue: annotation.venue)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        updateUI()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let managedObject = anObject as! VenueManagedObject
        
        let venue = Venue(managedObject: managedObject)
        
        guard let location = venue.location
            else { fatalError("Predicate must filter venues with no location") }
        
        switch type {
            
        case .Insert:
            
            let annotation = VenueAnnotation(venue: venue)!
            
            mapView.addAnnotation(annotation)
            
        case .Delete:
            
            guard let annotation = mapView.annotations.firstMatching({ ($0 as? VenueAnnotation)?.venue == venue.identifier })
                else { return }
            
            mapView.removeAnnotation(annotation)
            
        case .Update:
            
            guard let annotation = mapView.annotations.firstMatching({ ($0 as? VenueAnnotation)?.venue == venue.identifier }) as? VenueAnnotation
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
            
        case .Move: break
        }
    }
}

// MARK: - Supporting Types

protocol VenueMapViewControllerDelegate: class {
    
    /// Informs the delegate that the venue selection has changed via the Map interface.
    func venueMapViewController(controller: VenueMapViewController, didSelectVenue venue: Identifier)
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
