//
//  SearchTableViewHeaderView.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/31/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import UIKit

final class SearchTableViewHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "SearchTableViewHeaderView"
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    
    @IBOutlet private(set) weak var moreButton: Button!
}
