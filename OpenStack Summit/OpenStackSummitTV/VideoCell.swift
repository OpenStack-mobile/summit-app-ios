//
//  VideoCell.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit


@objc(OSSTVVideoCell)
final class VideoCell: UICollectionViewCell {
    
    @IBOutlet private(set) weak var label: UILabel!
    
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    // MARK: Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // These properties are also exposed in Interface Builder.
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
        
        label.alpha = 0.0
    }
    
    // MARK: UICollectionReusableView
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset the label's alpha value so it's initially hidden.
        label.alpha = 0.0
    }
    
    // MARK: UIFocusEnvironment
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        /*
         Update the label's alpha value using the `UIFocusAnimationCoordinator`.
         This will ensure all animations run alongside each other when the focus
         changes.
         */
        coordinator.addCoordinatedAnimations({
            if self.isFocused {
                self.label.alpha = 1.0
            }
            else {
                self.label.alpha = 0.0
            }
            }, completion: nil)
    }
}
