//
//  DetailImageTableViewCell.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/9/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

final class DetailImageTableViewCell: UITableViewCell {
    
    #if os(iOS)
    typealias Label = CopyableLabel
    #elseif os(tvOS)
    typealias Label = UILabel
    #endif
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: Label!
}
