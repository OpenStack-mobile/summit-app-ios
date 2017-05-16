//
//  ViewController.swift
//  Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Cocoa
import CoreSummit

final class SummitsViewController: NSViewController, PagingTableViewController {
    
    typealias Summit = SummitsResponse.Summit
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView!
    
    @IBOutlet private(set) weak var activityIndicator: NSProgressIndicator!
    
    @IBOutlet private(set) weak var refreshButton: NSButton!
    
    // MARK: - Properties
    
    lazy var pageController: PageController<Summit> = PageController(fetch: Store.shared.summits)
    
    // MARK: - Loading

    override func viewDidLoad() {
        super.viewDidLoad()
                
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
    
    @IBAction func tableViewClick(_ sender: AnyObject) {
        
        defer { tableView.deselectAll(sender) }
        
        guard tableView.selectedRow >= 0,
            case let .item(item) = pageController.items[tableView.selectedRow]
            else { return }
        
        showActivityIndicator()
        
        Store.shared.summit(item.identifier) { [weak self] (response) in
            
            OperationQueue.main.addOperation {
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorMessage(error)
                    
                case .value:
                    
                    // set summit
                    SummitManager.shared.summit.value = item.identifier
                    
                    // reload data
                    controller.refresh()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func configure(cell: SummitTableViewCell, with summit: Summit) {
        
        let currentSummit = SummitManager.shared.summit.value == summit.identifier && self.currentSummit != nil
        
        if currentSummit {
            
            cell.indicatorImageView.image = NSImage(named: NSImageNameStatusAvailable)
            
        } else {
            
            cell.indicatorImageView.image = NSImage(named: NSImageNameStatusNone)
        }
        
        cell.nameLabel!.stringValue = summit.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: summit.timeZone.name)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.string(from: summit.start)
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.string(from: summit.end)
        
        cell.dateLabel!.stringValue = stringDateFrom + stringDateTo
    }
    
    // MARK: - ActivityViewController
    
    func showActivityIndicator() {
        
        refreshButton.isHidden = true
        tableView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimation(nil)
    }
    
    func dismissActivityIndicator(_ animated: Bool = true) {
        
        refreshButton.isHidden = false
        tableView.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimation(nil)
    }

    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return pageController.items.count
    }
    
    // MARK: - NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let data = pageController.items[row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.make(withIdentifier: SummitTableViewCell.identifier, owner: nil) as! SummitTableViewCell
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = NSTableCellView()
            
            cell.textField?.stringValue = "Loading..."
            
            return cell
        }
    }
}

// MARK: - Supporting Types

final class SummitTableViewCell: NSTableCellView {
    
    static let identifier = "SummitTableViewCell"
    
    @IBOutlet private(set) weak var nameLabel: NSTextField!
    
    @IBOutlet private(set) weak var dateLabel: NSTextField!
    
    @IBOutlet private(set) weak var indicatorImageView: NSImageView!
}

