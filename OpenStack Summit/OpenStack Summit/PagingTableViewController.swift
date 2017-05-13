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

protocol PagingTableViewController: class, UITableViewDataSource, UITableViewDelegate, ActivityViewController, MessageEnabledViewController {
    
    associatedtype Item
    
    var pageController: PageController<Item> { get }
    
    var tableView: UITableView! { get }
    
    #if os(iOS)
    var refreshControl: UIRefreshControl? { get }
    #endif
    
    func willLoadData()
    
    func didLoadNextPage(_ response: ErrorValue<[PageControllerChange]>)
}

extension PagingTableViewController {
    
    func willLoadData() {
        
        if pageController.items.isEmpty {
            
            showActivityIndicator()
        }
    }
    
    func didLoadNextPage(_ response: ErrorValue<[PageControllerChange]>) {
        
        dismissActivityIndicator(true)
        
        #if os(iOS)
        refreshControl?.endRefreshing()
        #endif
        
        switch response {
            
        case let .error(error):
            
            showErrorMessage(error, fileName: #file, lineNumber: #line)
            
        case let .value(changes):
            
            let wasCached = pageController.cached != nil && pageController.pages.count == 1
            
            if wasCached {
                
                tableView.reloadData()
                
            } else {
                
                tableView.beginUpdates()
                
                #if os(iOS) || os(tvOS)
                
                for change in changes {
                    
                    let indexPath = IndexPath(row: change.index, section: 0)
                    
                    switch change.change {
                        
                    case .delete:
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    case .insert:
                        
                        tableView.insertRows(at: [indexPath], with: .fade)
                        
                    case .update:
                        
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
                
                #elseif os(OSX)
                                        
                    for change in changes {
                        
                        let indexSet = NSIndexSet(index: change.index) as IndexSet
                        
                        switch change.change {
                            
                        case .delete:
                            
                            tableView.removeRows(at: indexSet, withAnimation: .effectFade)
                            
                        case .insert:
                            
                            tableView.insertRows(at: indexSet, withAnimation: .effectFade)
                            
                        case .update:
                            
                            tableView.removeRows(at: indexSet, withAnimation: [])
                            tableView.insertRows(at: indexSet, withAnimation: [])
                        }
                    }
                    
                #endif
                
                tableView.endUpdates()
            }
        }
    }
}
