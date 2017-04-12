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
    
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public init?(urlString: String) {
        
        guard let url = URL(string: urlString)
            else { return nil }
        
        self.url = url
    }
    
    @objc public func setToImageView(_ imageView: UIImageView) {
        imageView.hnk_setImageFromURL(url, format: Format<UIImage>(name: "original"))
    }
}
