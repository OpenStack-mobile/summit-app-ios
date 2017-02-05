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
    
    final var fetchedResultsController: NSFetchedResultsController!
    
    final private var changes = [Change]()
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        self.changes = []
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            
            if let insertIndexPath = newIndexPath {
                self.changes.append(.insert(insertIndexPath))
            }
        case .Delete:
            
            if let deleteIndexPath = indexPath {
                self.changes.append(.delete(deleteIndexPath))
            }
        case .Update:
            if let updateIndexPath = indexPath,
                let _ = self.collectionView!.cellForItemAtIndexPath(updateIndexPath) {
                
                self.changes.append(.update(updateIndexPath))
            }
        case .Move:
            
            if let old = indexPath,
                let new = newIndexPath {
                
                self.changes.append(.move(old: old, new: new))
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        self.changes.append(.section(index: sectionIndex, type: type))
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.collectionView?.performBatchUpdates({ [weak self] in
            
            guard let controller = self,
                let collectionView = controller.collectionView
                else { return }
            
            for change in controller.changes {
                
                switch change {
                    
                case let .section(index, type):
                    
                    switch type {
                        
                    case .Insert:
                        
                        collectionView.insertSections(NSIndexSet(index: index))
                        
                    case .Delete:
                        
                        collectionView.deleteSections(NSIndexSet(index: index))
                        
                    default: break
                    }
                    
                case let .insert(indexPath):
                    
                    collectionView.insertItemsAtIndexPaths([indexPath])
                    
                case let .delete(indexPath):
                    
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                    
                case let .update(indexPath):
                    
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                    
                case let .move(old, new):
                    
                    collectionView.moveItemAtIndexPath(old, toIndexPath: new)
                }
            }
            
            }) { (completed) in }
    }
}

// MARK: - Supporting Types

private extension CollectionViewController {
    
    enum Change {
        
        case section(index: Int, type: NSFetchedResultsChangeType)
        case insert(NSIndexPath)
        case delete(NSIndexPath)
        case update(NSIndexPath)
        case move(old: NSIndexPath, new: NSIndexPath)
    }
}
