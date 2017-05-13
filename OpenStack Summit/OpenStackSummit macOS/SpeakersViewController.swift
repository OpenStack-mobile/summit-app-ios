//
//  SpeakersViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/20/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit
import CoreData
import CoreSummit

final class SpeakersViewController: NSViewController, NSFetchedResultsControllerDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, SearchableController {
    
    typealias CollectionViewItem = ImageCollectionViewItem
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var collectionView: NSCollectionView!
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    private var summitObserver: Int?
    
    private lazy var placeholderImage: NSImage = NSImage(named: "generic-user-avatar")!
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = summitObserver {
            
            SummitManager.shared.summit.remove(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitObserver = SummitManager.shared.summit.observe { [weak self] _ in self?.configureView() }
        
        configureView()
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "Speakers"
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
        userActivity.becomeCurrent()
        
        self.userActivity = userActivity
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.speakers.rawValue]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        let summitID = NSNumber(value: Int64(SummitManager.shared.summit.value))
        
        let summitPredicate = NSPredicate(format: "summits.id CONTAINS %@", summitID)
        
        let searchPredicate: NSPredicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = NSPredicate(value: true)
            
        } else {
            
            searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@ OR lastName CONTAINS[c] %@", searchTerm, searchTerm)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, summitPredicate])
        
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext) as! NSFetchedResultsController<NSFetchRequestResult>
        
        try! self.fetchedResultsController.performFetch()
        
        self.collectionView.reloadData()
    }
    
    private func configure(item: CollectionViewItem, at indexPath: IndexPath) {
        
        let managedObject = fetchedResultsController.object(at: indexPath) as! SpeakerManagedObject
        
        let speaker = Speaker(managedObject: managedObject)
        
        item.textField!.stringValue = speaker.name
        
        item.placeholderImage = self.placeholderImage
        
        item.imageURL = URL(string: speaker.pictureURL)
    }
    
    // MARK: - NSCollectionViewDataSource
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "PersonCollectionViewItem", for: indexPath) as! CollectionViewItem
        
        configure(item: item, at: indexPath)
        
        return item
    }
    
    // MARK: - NSCollectionViewDelegate
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        defer { collectionView.deselectItems(at: indexPaths) }
        
        let indexPath = indexPaths.first!
        
        let speaker = fetchedResultsController.object(at: indexPath) as! SpeakerManagedObject
        
        AppDelegate.shared.mainWindowController.view(.speaker, identifier: speaker.identifier)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        //self.tableView.endUpdates()
        
        self.collectionView.reloadData()
    }
}
