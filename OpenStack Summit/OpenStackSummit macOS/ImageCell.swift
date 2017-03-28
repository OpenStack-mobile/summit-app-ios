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
    
    var imageURL: NSURL? { get set }
}

private extension ImageCell {
    
    private func configureView(newValue: NSURL?, _ oldValue: NSURL?) {
        
        if imageURL != oldValue {
            
            imageView?.image = placeholderImage
            
            if let url = imageURL {
                
                imageView?.loadCached(url)
            }
        }
    }
}

class ImageTableViewCell: NSTableCellView, ImageCell {
    
    var placeholderImage: NSImage?
    
    var imageURL: NSURL? {
        
        didSet { configureView(imageURL, oldValue) }
    }
}

class ImageCollectionViewItem: NSCollectionViewItem, ImageCell {
    
    var placeholderImage: NSImage?
    
    var imageURL: NSURL? {
        
        didSet { configureView(imageURL, oldValue) }
    }
}
