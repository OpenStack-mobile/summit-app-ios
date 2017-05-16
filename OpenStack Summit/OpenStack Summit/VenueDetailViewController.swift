//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import ImageSlideshow
// import GoogleMaps
import CoreSummit

final class VenueDetailViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var scrollView: UIScrollView!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var locationLabel: UILabel!
    @IBOutlet private(set) weak var arrowImageView: UIImageView!
    @IBOutlet private(set) weak var imagesSlideshow: ImageSlideshow!
    @IBOutlet private(set) weak var imagesSlideshowHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var mapsSlideshow: ImageSlideshow!
    @IBOutlet private(set) weak var mapView: GMSMapView!
    
    // MARK: - Accessors
    
    private(set) var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue
        }
    }

    private(set) var location: String  {
        get {
            return locationLabel.text ?? ""
        }
        set {
            locationLabel.text = newValue
        }
    }
    
    private(set) var images = [URL]() {
        didSet { configure(slideshow: imagesSlideshow, with: images) }
    }
    
    private(set) var maps = [URL]() {
        didSet { configure(slideshow: mapsSlideshow, with: maps) }
    }
    
    // MARK: - Properties
    
    var venue: Identifier!
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesSlideshow.contentScaleMode = .scaleAspectFill
        mapsSlideshow.contentScaleMode = .scaleAspectFill
        
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        navigationItem.title = "VENUE"
        
        updateUI()
    }
    
    // MARK: - Action
    
    @IBAction func openInFullScreen(_ sender: UITapGestureRecognizer) {
        let slideshow = sender.view as! ImageSlideshow
        
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            slideshow.setScrollViewPage(page, animated: false)
        }
        
        //ctr.initialImageIndex = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate.init(slideshowView: slideshow, slideshowController: ctr)
        ctr.transitioningDelegate = self.transitionDelegate!
        self.present(ctr, animated: true, completion: nil)
        
        ctr.closeButton.setImage(#imageLiteral(resourceName: "close"), for: UIControlState())
    }
    
    @IBAction func navigateToVenueLocationDetail(_ sender: UITapGestureRecognizer) {
        
        if !arrowImageView.isHidden {
            
            let venueLocationDetailVC = R.storyboard.venue.venueLocationDetailViewController()!
            
            venueLocationDetailVC.venue = venue
            
            self.show(venueLocationDetailVC, sender: self)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        assert(self.venue != nil, "No venue set")
        
        guard let venue = try! VenueListItem.find(self.venue, context: Store.shared.managedObjectContext)
            else { fatalError("Venue not found in cache. Invalid venue \(self.venue)") }
        
        self.name = venue.name
        self.location = venue.address
        
        self.toggleImagesGallery(venue.images.count > 0)
        self.images = venue.images
        
        self.toggleMapNavigation(venue.maps.count > 0)
        self.toggleMapsGallery(venue.maps.count > 0)
        self.toggleMap(venue.maps.count == 0 && venue.location != nil)
        
        if venue.maps.count > 0 {
            self.maps = venue.maps
        }
        else if let location = venue.location {
            
            let marker = GMSMarker()
            var bounds = GMSCoordinateBounds()
            marker.position = location
            marker.map = mapView
            marker.title = venue.name
            marker.icon = #imageLiteral(resourceName: "map_pin")
            bounds = bounds.includingCoordinate(marker.position)
            mapView.selectedMarker = marker
            
            let update = GMSCameraUpdate.fit(bounds)
            mapView.moveCamera(update)
            mapView.animate(toZoom: mapView.camera.zoom - 6)
        }
    }
    
    @inline(__always)
    private func toggleMap(_ visible: Bool) {
        mapView.isHidden = !visible
    }
    
    @inline(__always)
    private func toggleMapsGallery(_ visible: Bool) {
        mapsSlideshow.isHidden = !visible
    }
    
    @inline(__always)
    private func toggleImagesGallery(_ visible: Bool) {
        imagesSlideshow.isHidden = !visible
        imagesSlideshowHeightConstraint.constant = visible ? 220 : 0
        imagesSlideshow.updateConstraints()
    }
    
    @inline(__always)
    private func toggleMapNavigation(_ visible: Bool) {
        arrowImageView.isHidden = !visible
    }
    
    @inline(__always)
    private func configure(slideshow: ImageSlideshow, with imageURLs: [URL]) {
        
        let imageInputs = imageURLs.map { HanekeInputSource(url: $0) }
        
        slideshow.setImageInputs(imageInputs)
    }
}
