 //
//  HanekeInputSource.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import Haneke
import ImageSlideshow

public final class HanekeInputSource: InputSource {
    
    public let url: NSURL
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public init?(urlString: String) {
        
        guard let url = NSURL(string: urlString)
            else { return nil }
        
        self.url = url
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.hnk_setImageFromURL(url, format: Format<UIImage>(name: "original"))
    }
}