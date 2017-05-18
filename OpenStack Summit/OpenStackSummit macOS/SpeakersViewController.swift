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
import Predicate

final class SpeakersViewController: NSViewController, NSFetchedResultsControllerDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, SearchableController {
    
    typealias CollectionViewItem = ImageCollectionViewItem
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var collectionView: NSCollectionView!
    
    // MARK: - Properties
    
    var searchTerm = "" {
        
        didSet { configureView() }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<SpeakerManagedObject>!
    
    private var summitObserver: Int?
    
    private lazy var placeholderImage: NSImage = #imageLiteral(resourceName: "generic-user-avatar")
    
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
        
        let summitID = Expression.value(.int64(SummitManager.shared.summit.value))
        
        //let summitPredicate = NSPredicate(format: "summits.id CONTAINS %@", summitID)
        let summitPredicate: Predicate = (#keyPath(SpeakerManagedObject.summits.id)).compare(.contains, summitID)
        
        let searchPredicate: Predicate
        
        if searchTerm.isEmpty {
            
            searchPredicate = .value(true)
            
        } else {
            
            let value = Expression.value(.string(searchTerm))
            
            //searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@ OR lastName CONTAINS[c] %@", searchTerm, searchTerm)
            searchPredicate = (#keyPath(SpeakerManagedObject.firstName)).compare(.contains, [.caseInsensitive], value)
                || (#keyPath(SpeakerManagedObject.lastName)).compare(.contains, [.caseInsensitive], value)
        }
        
        let predicate: Predicate = .compound(.and([searchPredicate, summitPredicate]))
        
        self.fetchedResultsController = NSFetchedResultsController(Speaker.self,
                                                                   delegate: self,
                                                                   predicate: predicate,
                                                                   sortDescriptors: SpeakerManagedObject.sortDescriptors,
                                                                   context: Store.shared.managedObjectContext)
        
        try! self.fetchedResultsController.performFetch()
        
        self.collectionView.reloadData()
    }
    
    private func configure(item: CollectionViewItem, at indexPath: IndexPath) {
        
        let managedObject = fetchedResultsController.object(at: indexPath)
        
        let speaker = Speaker(managedObject: managedObject)
        
        item.textField!.stringValue = speaker.name
        
        item.placeholderImage = self.placeholderImage
        
        item.imageURL = speaker.picture
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
        
        let speaker = fetchedResultsController.object(at: indexPath) 
        
        AppDelegate.shared.mainWindowController.view(data: .speaker, identifier: speaker.id)
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
