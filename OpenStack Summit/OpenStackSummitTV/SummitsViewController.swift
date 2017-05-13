//
//  SummitsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/25/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreSummit

@objc(OSSTVSummitsViewController)
final class SummitsViewController: UITableViewController {
    
    typealias Summit = SummitsResponse.Summit
    
    // MARK: - Properties
    
    private(set) var summits = [Summit]() {
        
        didSet { didLoadSummits() }
    }
    
    private(set) var loading = false {
        
        didSet { loadingChanged() }
    }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.layoutMargins.left = 90
        tableView.layoutMargins.right = 90
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject? = nil) {
        
        self.loading = true
        
        Store.shared.summits { (response) in
            
            OperationQueue.main.addOperation { [weak self] in
                
                guard let controller = self else { return }
                
                controller.loading = false
                
                switch response {
                    
                case let .error(error):
                    
                    controller.showErrorAlert((error as NSError).localizedDescription, retryHandler: { controller.refresh() })
                    
                case let .value(value):
                    
                    controller.summits = value.items.sorted { $0.0.start > $0.1.start }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func didLoadSummits() {
        
        self.tableView.reloadData()
    }
    
    @inline(__always)
    private func loadingChanged() {
        
        self.navigationItem.title = loading ? "Loading..." : "Summits"
        
        self.tableView.allowsSelection = loading == false
    }
    
    @inline(__always)
    private func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        
        let summit = self[indexPath]
        
        cell.textLabel?.text = summit.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: summit.timeZone.name)
        dateFormatter.dateFormat = "MMMM dd-"
        let stringDateFrom = dateFormatter.string(from: summit.start)
        
        dateFormatter.dateFormat = "dd, yyyy"
        let stringDateTo = dateFormatter.string(from: summit.end)
        
        cell.detailTextLabel?.text = stringDateFrom + stringDateTo
    }
    
    private subscript (indexPath: IndexPath) -> Summit {
        
        return self.summits[indexPath.row]
    }
    
    private func select(summit identifier: Identifier) {
        
        SummitManager.shared.summit.value = identifier
        
        assert(self.currentSummit != nil, "Summit must already be loaded")
        
        self.performSegue(withIdentifier: Segue.presentSummit.rawValue, sender: self)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.summits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummitTableViewCell", for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedSummit = self[indexPath]
        
        if let _ = try! SummitManagedObject.find(selectedSummit.identifier, context: Store.shared.managedObjectContext) {
            
            self.select(summit: selectedSummit.identifier)
            
        } else {
            
            Store.shared.summit(selectedSummit.identifier) { [weak self] (response) in
                
                OperationQueue.main.addOperation {
                    
                    guard let controller = self else { return }
                    
                    switch response {
                        
                    case let .error(error):
                        
                        controller.showErrorAlert((error as NSError).localizedDescription)
                        
                    case .value:
                        
                        controller.select(summit: selectedSummit.identifier)
                    }
                }
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let segueIdentifier = Segue(rawValue: segue.identifier!)!
        
        switch segueIdentifier {
            
        case .presentSummit:
            
            break
        }
    }
}

private extension SummitsViewController {
    
    enum Segue: String {
        
        case presentSummit
    }
}
