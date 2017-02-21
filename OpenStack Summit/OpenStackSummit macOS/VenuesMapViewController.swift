//
//  VenuesMapViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import MapKit
import CoreLocation
import CoreData
import CoreSummit

final class VenueMapViewController: NSViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    private var summitObserver: Int?
    
    private lazy var popover: (NSPopover, VenueDetailViewController) = {
        
        let venueDetailViewController = self.storyboard!.instantiateControllerWithIdentifier("VenueDetailViewController") as! VenueDetailViewController
        self.addChildViewController(venueDetailViewController)
        
        let popover = NSPopover()
        popover.behavior = .Transient
        popover.animates = true
        popover.contentViewController = venueDetailViewController
        
        return (popover, venueDetailViewController)
    }()
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = summitObserver {
            
            SummitManager.shared.summit.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        popover.0.close()
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let summitID = NSNumber(longLong: Int64(SummitManager.shared.summit.value))
        
        let predicate = NSPredicate(format: "(latitude != nil AND longitude != nil) AND summit.id == %@", summitID)
        
        let sort = [NSSortDescriptor(key: "venueType", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(Venue.self, delegate: self, predicate: predicate, sortDescriptors: sort, context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        // reload mapview
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for venue in Venue.from(managedObjects: (self.fetchedResultsController.fetchedObjects as! [VenueManagedObject])) {
            
            let annotation = VenueAnnotation(venue: venue)!
            
            mapView.addAnnotation(annotation)
        }
        
        showSelectedVenue(nil)
    }
    
    func showSelectedVenue(venue: Identifier?) {
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        if let venueID = venue,
            let venue = try! Venue.find(venueID, context: Store.shared.managedObjectContext),
            let selectedAnnotation = mapView.annotations.firstMatching({ $0.coordinate.latitude == Double(venue.latitude ?? "") && $0.coordinate.longitude == Double(venue.longitude ?? "") }) {
            
            mapView.selectAnnotation(selectedAnnotation, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is VenueAnnotation {
            
            let reuseIdentifier = "Venue"
            
            let annotationView: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView {
                
                annotationView = dequeuedView
                
            } else {
                
                let newAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                
                newAnnotationView.canShowCallout = true
                newAnnotationView.pinTintColor = .redColor()
                
                annotationView = newAnnotationView
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView annotationView: MKAnnotationView) {
        
        if let venueAnnotation = annotationView.annotation as? VenueAnnotation {
            
            mapView.deselectAnnotation(annotationView.annotation, animated: false)
            
            popover.1.venue = venueAnnotation.venue
            
            popover.0.showRelativeToRect(annotationView.bounds,
                                         ofView: annotationView,
                                         preferredEdge: .MinX)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
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

final class VenueAnnotation: NSObject, MKAnnotation {
    
    let venue: Identifier
    
    let coordinate: CLLocationCoordinate2D
    
    private(set) var title: String?
    
    private(set) var subtitle: String?
    
    init?(venue: Venue) {
        
        guard let location = venue.location
            else { return nil }
        
        self.title = venue.name
        self.subtitle = venue.fullAddress
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.venue = venue.identifier
    }
}
