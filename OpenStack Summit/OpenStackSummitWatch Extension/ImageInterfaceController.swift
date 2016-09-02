//
//  ImageInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class ImageInterfaceController: WKInterfaceController {
    
    static let identifier = "Image"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var imageView: WKInterfaceImage!
    
    @IBOutlet weak var activityIndicator: WKInterfaceImage!
    
    // MARK: - Properties
    
    private(set) var image: Image!
    
    // MARK: - Loading
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let image = (context as? Context<Image>)?.value
            else { fatalError("Invalid context") }
        
        self.image = image
        
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
        
        guard let imageURL = NSURL(string: image.url)
            else { return }
        
        // show activity indicator
        activityIndicator.setImageNamed("Activity")
        activityIndicator.startAnimatingWithImagesInRange(NSRange(location: 0, length: 30), duration: 1.0, repeatCount: 0)
        activityIndicator.setHidden(false)
        imageView.setHidden(true)
        
        // load image
        imageView.loadCached(imageURL) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            // hide activity indicator
            controller.activityIndicator.setHidden(true)
            controller.imageView.setHidden(false)
            
            // show alert image
            
            guard case .Data = response else {
                
                controller.imageView.setImageNamed("alert")
                return
            }
        }
    }
}