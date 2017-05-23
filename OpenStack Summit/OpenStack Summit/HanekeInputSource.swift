 //
//  HanekeInputSource.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Haneke
import ImageSlideshow

final class HanekeInputSource: InputSource {
    
    let url: URL
    
    init(url: URL) {
        
        self.url = url
    }
    
    /**
     Load image from the source to image view.
     - parameter imageView: The image view to load the image into.
     - parameter callback: Callback called after the image was set to the image view.
     - parameter image: Image that was set to the image view.
     */
    func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        
        imageView.hnk_setImageFromURL(url.environmentScheme,
                                      format: Format<UIImage>(name: "original"),
                                      failure: { _ in callback(nil) },
                                      success: { callback($0) })
    }
}
