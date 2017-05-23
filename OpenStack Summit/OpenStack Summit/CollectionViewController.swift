//
//  CollectionViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    final var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    final private var changes = [Change]()
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.changes = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            
            if let insertIndexPath = newIndexPath {
                self.changes.append(.insert(insertIndexPath))
            }
        case .delete:
            
            if let deleteIndexPath = indexPath {
                self.changes.append(.delete(deleteIndexPath))
            }
        case .update:
            if let updateIndexPath = indexPath,
                let _ = self.collectionView!.cellForItem(at: updateIndexPath) {
                
                self.changes.append(.update(updateIndexPath))
            }
        case .move:
            
            if let old = indexPath,
                let new = newIndexPath {
                
                self.changes.append(.move(old: old, new: new))
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        self.changes.append(.section(index: sectionIndex, type: type))
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.collectionView?.performBatchUpdates({ [weak self] in
            
            guard let controller = self,
                let collectionView = controller.collectionView
                else { return }
            
            for change in controller.changes {
                
                switch change {
                    
                case let .section(index, type):
                    
                    switch type {
                        
                    case .insert:
                        
                        collectionView.insertSections(IndexSet(integer: index))
                        
                    case .delete:
                        
                        collectionView.deleteSections(IndexSet(integer: index))
                        
                    default: break
                    }
                    
                case let .insert(indexPath):
                    
                    collectionView.insertItems(at: [indexPath])
                    
                case let .delete(indexPath):
                    
                    collectionView.deleteItems(at: [indexPath])
                    
                case let .update(indexPath):
                    
                    collectionView.reloadItems(at: [indexPath])
                    
                case let .move(old, new):
                    
                    collectionView.moveItem(at: old, to: new)
                }
            }
            
            }) { (completed) in }
    }
}

// MARK: - Supporting Types

private extension CollectionViewController {
    
    enum Change {
        
        case section(index: Int, type: NSFetchedResultsChangeType)
        case insert(IndexPath)
        case delete(IndexPath)
        case update(IndexPath)
        case move(old: IndexPath, new: IndexPath)
    }
}
