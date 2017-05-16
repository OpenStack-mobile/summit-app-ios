//
//  ImageTableViewCell.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/22/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

protocol ImageCell: class {
    
    var imageView: NSImageView? { get }
    
    var placeholderImage: NSImage? { get set }
    
    var imageURL: URL? { get set }
}

private extension ImageCell {
    
    func configureView(_ newValue: URL?, _ oldValue: URL?) {
        
        if imageURL != oldValue {
            
            imageView?.image = placeholderImage
            
            if let url = imageURL {
                
                imageView?.loadCached(url)
            }
            
        } else if newValue == nil && oldValue == nil {
            
            imageView?.image = placeholderImage
        }
    }
}

class ImageTableViewCell: NSTableCellView, ImageCell {
    
    var placeholderImage: NSImage?
    
    var imageURL: URL? {
        
        didSet { configureView(imageURL, oldValue) }
    }
}

class ImageCollectionViewItem: NSCollectionViewItem, ImageCell {
    
    var placeholderImage: NSImage?
    
    var imageURL: URL? {
        
        didSet { configureView(imageURL, oldValue) }
    }
}
