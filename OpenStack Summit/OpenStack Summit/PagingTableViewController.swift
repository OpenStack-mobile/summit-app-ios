//
//  PagingTableViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/6/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import Foundation
import CoreSummit

protocol PagingTableViewController: class, TableViewDataSource, ShowActivityIndicatorProtocol, MessageEnabledViewController {
    
    associatedtype Item
    
    var pageController: PageController<Item> { get }
    
    var tableView: TableView! { get }
    
    #if os(iOS)
    var refreshControl: UIRefreshControl? { get }
    #endif
    
    func willLoadData()
    
    func didLoadNextPage(response: ErrorValue<[PageControllerChange]>)
}

extension PagingTableViewController {
    
    func willLoadData() {
        
        if pageController.items.isEmpty {
            
            showActivityIndicator()
        }
    }
    
    func didLoadNextPage(response: ErrorValue<[PageControllerChange]>) {
        
        hideActivityIndicator()
        
        #if os(iOS)
        refreshControl?.endRefreshing()
        #endif
        
        switch response {
            
        case let .Error(error):
            
            showErrorMessage(error, fileName: #file, lineNumber: #line)
            
        case let .Value(changes):
            
            let wasCached = pageController.cached != nil && pageController.pages.count == 1
            
            if wasCached {
                
                tableView.reloadData()
                
            } else {
                
                tableView.beginUpdates()
                
                for change in changes {
                    
                    let indexPath = NSIndexPath(forRow: change.index, inSection: 0)
                    
                    switch change.change {
                        
                    case .delete:
                        
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        
                    case .insert:
                        
                        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        
                    case .update:
                        
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
                }
                
                tableView.endUpdates()
            }
        }
    }
}
