//
//  TableViewHeaderView.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/25/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

final class TableViewHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "TableViewHeaderView"
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
}
