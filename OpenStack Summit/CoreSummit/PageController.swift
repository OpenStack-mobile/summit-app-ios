//
//  PageController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/4/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import Foundation

public final class PageController<Item> {
    
    // MARK: - Properties
    
    public let perPage: Int
    
    public var fetch: (_ page: Int, _ perPage: Int, _ response: @escaping (ErrorValue<Page<Item>>) -> ()) -> ()
    
    public var cached: (() -> [Item])?
    
    public var callback = PageControllerCallback<Item>()
    
    public let operationQueue: OperationQueue
    
    public private(set) var pages = [Page<Item>]() {
        
        didSet { updateItems(oldValue) }
    }
    
    public private(set) var items = [PageControllerData<Item>]()
    
    public private(set) var isLoading: Bool = false
    
    public var cacheLoaded: Bool {
        
        return pages.isEmpty && items.isEmpty == false
    }
    
    // MARK: - Initialization
    
    public init(fetch: @escaping (_ page: Int, _ perPage: Int, _ response: @escaping (ErrorValue<Page<Item>>) -> ()) -> (),
                perPage: Int = 10,
                operationQueue: OperationQueue = OperationQueue.main) {
        
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
        
        fetch(nextPage, perPage) { [weak self] (response) in
            
            guard let controller = self else { return }
            
            controller.operationQueue.addOperation {
                
                controller.isLoading = false
                
                switch response {
                    
                case let .error(error):
                    
                    controller.callback.didLoadNextPage(.error(error))
                    
                case let .value(value):
                    
                    if controller.cacheLoaded {
                        
                        controller.items = []
                        
                        controller.callback.reloadData()
                    }
                    
                    let previousCount = controller.items.count
                    
                    let previousLastIndex = previousCount > 0 ? previousCount - 1 : 0
                    
                    assert(previousCount != previousLastIndex || previousCount == 0)
                     
                    controller.pages.append(value)
                    
                    if value.items.isEmpty && previousCount != 0 {
                        
                        assert(value.currentPage == value.lastPage, "Empty page but not last")
                        
                        let removedRow = PageControllerChange(index: previousLastIndex, change: .delete)
                        
                        controller.callback.didLoadNextPage(.value([removedRow]))
                        
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
                    
                    controller.callback.didLoadNextPage(.value(changes))
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
    private func updateItems(_ oldValue: [Page<Item>]) {
        
        // reset if loaded from cache previously
        if oldValue.isEmpty && items.isEmpty == false {
            
            items = []
        }
        
        // load from cache
        if pages.isEmpty {
            
            items = cached?().map { .item($0) } ?? []
            
        } else {
            
            // get items from pages
            
            items = pages.reduce([Item](), { $0.0 + $0.1.items }).map({ .item($0) })
            
            if dataLoaded == false && items.isEmpty == false {
                
                items.append(.loading)
            }
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
