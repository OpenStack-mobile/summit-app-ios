//
//  VenuesMapInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class VenuesMapInterfaceController: WKInterfaceController {
    
    static let identifier = "VenuesMap"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: WKInterfaceMap!
    
    // MARK: - Properties
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        mapView.removeAllAnnotations()
        
        guard let summit = Store.shared.cache
            else { return }
        
        var locations = [CLLocationCoordinate2D]()
        
        for location in summit.locations {
            
            guard case let .venue(venue) = location,
                let location = venue.location
                else { continue }
            
            locations.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        
        // calculate visible region
        if let firstVenue = locations.first {
            
            mapView.setRegion(MKCoordinateRegion(center: firstVenue, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)))
        }
        
        // add locations to Map
        locations.forEach { mapView.addAnnotation($0, withPinColor: .Red) }
    }
}
