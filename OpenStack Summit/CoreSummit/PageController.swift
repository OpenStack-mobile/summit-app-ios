//
//  PageController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/4/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public final class PageController<Item> {
    
    // MARK: - Properties
    
    public let perPage: Int
    
    public var fetch: (page: Int, perPage: Int, response: (ErrorValue<Page<Item>>) -> ()) -> ()
    
    public var callback = PageControllerCallback<Item>()
    
    public let operationQueue: NSOperationQueue
    
    public private(set) var pages = [Page<Item>]() {
        
        didSet { updateItemsCache() }
    }
    
    public private(set) var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private var itemsCache = [Item]()
    
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
                    
                case .Error: break
                    
                case let .Value(value):
                    
                    controller.pages.append(value)
                }
                
                controller.callback.didLoadNextPage(response)
            }
        }
    }
    
    // MARK: - Data
    
    public var count: Int {
        
        var count = itemsCache.count
        
        if dataLoaded == false {
            
            count += 1
        }
        
        return count
    }
    
    public subscript (index: Int) -> PageControllerData<Item> {
        
        if index < itemsCache.count {
            
            let item = itemsCache[index]
            
            return .item(item)
            
        } else {
            
            assert(dataLoaded == false)
         
            return .loading
        }
    }
    
    public var dataLoaded: Bool {
        
        guard let lastPage = pages.last
            else { return false }
        
        return lastPage.currentPage == lastPage.lastPage
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    private func updateItemsCache() {
        
        self.itemsCache = pages.reduce([Item](), combine: { $0.0 + $0.1.items })
    }
}

// MARK: - Supporting Types

public enum PageControllerData<Item> {
    
    case loading
    case item(Item)
}

public struct PageControllerCallback<Item> {
    
    public var reloadData: () -> () = { _ in }
    
    public var willLoadData: () -> () = { _ in }
    
    public var didLoadNextPage: (ErrorValue<Page<Item>>) -> () = { _ in }
}
