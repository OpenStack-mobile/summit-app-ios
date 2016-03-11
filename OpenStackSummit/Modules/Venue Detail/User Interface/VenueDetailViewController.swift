//
//  VenueDetailViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import ImageSlideshow
import GoogleMaps

@objc
public protocol IVenueDetailViewController {
    var navigationController: UINavigationController? { get }
    
    var name: String! { get set }
    var location: String! { get set }
    var images: [String]! { get set }
    var maps: [String]! { get set }
    
    func toggleMap(visible: Bool)
    func toggleMapsGallery(visible: Bool)
    func toggleImagesGallery(visible: Bool)
    func toggleMapNavigation(visible: Bool)
    
    func addMarker(venue: VenueDTO)
}

class VenueDetailViewController: UIViewController, IVenueDetailViewController, GMSMapViewDelegate {
    
    private var imagesInternal: [String]!
    private var mapsInternal: [String]!
    
    var name: String! {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }

    var location: String! {
        get {
            return locationLabel.text
        }
        set {
            locationLabel.text = newValue
        }
    }
    
    var images: [String]! {
        get {
            return imagesInternal
        }
        set {
            if imagesInternal == nil {
                imagesInternal = newValue
                var imageInputs:[HanekeInputSource] = []
                
                for image in imagesInternal {
                    let url = image.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    imageInputs.append(HanekeInputSource(urlString: url, frame: imagesSlideshow.bounds)!)
                }
                
                imagesSlideshow.setImageInputs(imageInputs)
            }
        }
    }
    
    var maps: [String]! {
        get {
            return mapsInternal
        }
        set {
            if mapsInternal == nil {
                mapsInternal = newValue
                var imageInputs:[HanekeInputSource] = []
                
                for map in mapsInternal {
                    let url = map.stringByReplacingOccurrencesOfString("https", withString: "http", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    imageInputs.append(HanekeInputSource(urlString: url, frame: mapsSlideshow.bounds)!)
                }
                
                mapsSlideshow.setImageInputs(imageInputs)
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var imagesSlideshow: ImageSlideshow!
    @IBOutlet weak var imagesSlideshowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapsSlideshow: ImageSlideshow!
    @IBOutlet weak var mapView: GMSMapView!
    
    var presenter: IVenueDetailPresenter!
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesSlideshow.contentScaleMode = .ScaleAspectFill
        mapsSlideshow.contentScaleMode = .ScaleAspectFill
        
        mapView.myLocationEnabled = true
        mapView.delegate = self
    }
    
    @IBAction func openInFullScreen(sender: UITapGestureRecognizer) {
        let slideshow = sender.view as! ImageSlideshow
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            slideshow.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialPage = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow);
        ctr.transitioningDelegate = self.transitionDelegate!
        self.presentViewController(ctr, animated: true, completion: nil)
    }
    
    @IBAction func navigateToVenueLocationDetail(sender: UITapGestureRecognizer) {
        if !arrowImageView.hidden {
            presenter.showVenueLocationDetail()
        }
    }
    
    func addMarker(venue: VenueDTO) {
        let marker = GMSMarker()
        var bounds = GMSCoordinateBounds()
        marker.position = CLLocationCoordinate2DMake(venue.lat, venue.long)
        marker.map = mapView
        marker.title = venue.name
        marker.icon = UIImage(named: "map_pin")
        bounds = bounds.includingCoordinate(marker.position)
        mapView.selectedMarker = marker
        
        let update = GMSCameraUpdate.fitBounds(bounds)
        mapView.moveCamera(update)
        mapView.animateToZoom(mapView.camera.zoom - 6)
    }
    
    func toggleMap(visible: Bool) {
        mapView.hidden = !visible
    }
    
    func toggleMapsGallery(visible: Bool) {
        mapsSlideshow.hidden = !visible
    }
    
    func toggleImagesGallery(visible: Bool) {
        imagesSlideshow.hidden = !visible
        imagesSlideshowHeightConstraint.constant = visible ? 220 : 0
        imagesSlideshow.updateConstraints()
    }
    
    func toggleMapNavigation(visible: Bool) {
        arrowImageView.hidden = !visible
    }
}
