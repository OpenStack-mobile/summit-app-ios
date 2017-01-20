//
//  PageController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/4/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import SwiftFoundation

public final class PageController<Item> {
    
    // MARK: - Properties
    
    public let perPage: Int
    
    public var fetch: (page: Int, perPage: Int, response: (ErrorValue<Page<Item>>) -> ()) -> ()
    
    public var callback = PageControllerCallback<Item>()
    
    public let operationQueue: NSOperationQueue
    
    public private(set) var pages = [Page<Item>]() {
        
        didSet { updateItems() }
    }
    
    public private(set) var items = [PageControllerData<Item>]()
    
    public private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    public init(fetch: (page: Int, perPage: Int, response: (ErrorValue<Page<Item>>) -> ()) -> (),
                perPage: Int = 10,
                operationQueue: NSOperationQueue = NSOperationQueue.mainQueue()) {
        
        self.fetch = fetch
        self.perPage = perPage
        self.operationQueue = operationQueue
    }
    
    // MARK: - Methods
    
    public func refresh() {
        
        self.pages = []
        self.callback.reloadData()
        self.loadNextPage()
    }
    
    public func loadNextPage() {
        
        guard dataLoaded == false
            && isLoading == false
            else { return }
        
        let currentPage = pages.last?.currentPage ?? 0
        
        let nextPage = currentPage + 1
        
        isLoading = true
        
        callback.willLoadData()
        
        fetch(page: nextPage, perPage: perPage) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            controller.operationQueue.addOperationWithBlock {
                
                controller.isLoading = false
                
                switch response {
                    
                case let .Error(error):
                    
                    controller.callback.didLoadNextPage(.Error(error))
                    
                case let .Value(value):
                    
                    let previousCount = controller.items.count
                    
                    let previousLastIndex = previousCount > 0 ? previousCount - 1 : 0
                    
                    assert(previousCount != previousLastIndex || previousCount == 0)
                     
                    controller.pages.append(value)
                    
                    if value.items.isEmpty && previousCount != 0 {
                        
                        assert(value.currentPage == value.lastPage, "Empty page but not last")
                        
                        let removedRow = PageControllerChange(index: previousLastIndex, change: .delete)
                        
                        controller.callback.didLoadNextPage(.Value([removedRow]))
                        
                        return
                    }
                    
                    let newCount = controller.items.count
                    
                    var changes = [PageControllerChange]()
                    
                    if previousCount > 0 {
                        
                        changes.append(PageControllerChange(index: previousLastIndex, change: .update))
                    }
                    
                    for index in previousCount ..< newCount {
                        
                        changes.append(PageControllerChange(index: index, change: .insert))
                    }
                    
                    controller.callback.didLoadNextPage(.Value(changes))
                }
            }
        }
    }
    
    // MARK: - Data
    
    public var dataLoaded: Bool {
        
        guard let lastPage = pages.last
            else { return false }
        
        return lastPage.currentPage == lastPage.lastPage
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func updateItems() {
        
        items = pages.reduce([Item](), combine: { $0.0 + $0.1.items }).map({ .item($0) })
        
        if dataLoaded == false && items.isEmpty == false {
            
            items.append(.loading)
        }
    }
}

// MARK: - Supporting Types

public enum PageControllerData<Item> {
    
    case loading
    case item(Item)
}

public struct PageControllerChange {
    
    public enum ChangeType {
        
        case update
        case insert
        case delete
    }
    
    public let index: Int
    
    public let change: ChangeType
}

public struct PageControllerCallback<Item> {
    
    public var reloadData: () -> () = { _ in }
    
    public var willLoadData: () -> () = { _ in }
    
    public var didLoadNextPage: (ErrorValue<[PageControllerChange]>) -> () = { _ in }
}
