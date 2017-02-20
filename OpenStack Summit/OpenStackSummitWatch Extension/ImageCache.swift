//
//  ImageCache.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

public final class ImageCache {
    
    public static let shared = ImageCache()
    
    public init() { }
    
    // MARK: - Properties
    
    private let internalCache = NSCache()
    
    public var urlSession = NSURLSession.sharedSession()
    
    // MARK: - Accessors
    
    public var totalCostLimit: Int {
        
        get { return internalCache.totalCostLimit }
        
        set { internalCache.totalCostLimit = newValue }
    }
    
    public var countLimit: Int {
        
        get { return internalCache.countLimit }
        
        set { internalCache.countLimit = newValue }
    }
    
    // MARK: - Methods
    
    public func clear() {
        
        internalCache.removeAllObjects()
    }
    
    public func load(url: NSURL, completion: Response -> ()) {
        
        // attempt to get from cache first
        if let cachedImageData = self[url] {
            
            completion(.Data(cachedImageData))
            return
        }
        
        let task = urlSession.dataTaskWithURL(url) { (data, response, error) in
            
            guard error == nil else {
                
                completion(.Error(error!))
                return
            }
            
            guard let data = data else {
                
                completion(.NoData(response!))
                return
            }
            
            // cache
            self[url] = data
            
            // success!
            completion(.Data(data))
        }
        
        task.resume()
    }
    
    // MARK: - Subscripting
    
    public subscript (url: NSURL) -> NSData? {
        
        get { return internalCache.objectForKey(url.absoluteString!) as? NSData }
        
        set {
            
            guard let newData = newValue
                else { internalCache.removeObjectForKey(url.absoluteString!); return }
            
            internalCache.setObject(newData, forKey: url.absoluteString!)
        }
    }
}

// MARK: - Supporting Types

public extension ImageCache {
    
    public enum Response {
        
        case Error(ErrorType)
        case NoData(NSURLResponse)
        case Data(NSData)
    }
}

public protocol ImageCacheView: class, Hashable {
    
    func loadCached(url: NSURL, placeholder: UIImage?, cache: ImageCache, completion: (ImageCache.Response -> ())?)
    
    #if os(watchOS)
    func setImage(image: UIImage?)
    #else
    var image: UIImage? { get set }
    #endif
    
    func setImageData(imageData: NSData?)
}

private var InProgressCache = [Int: NSURL]()

public extension ImageCacheView {
    
    public func loadCached(url: NSURL, placeholder: UIImage? = nil, cache: ImageCache = ImageCache.shared, completion: (ImageCache.Response -> ())? = nil) {
        
        // set placeholder
        if let placeholder = placeholder {
            
            #if os(watchOS)
            self.setImage(placeholder)
            #else
            self.image = placeholder
            #endif
        }
        
        let hash = self.hashValue
        
        InProgressCache[hash] = url
        
        // load data
        cache.load(url) { [weak self] (response) in
            
            guard let view = self else { return }
            
            // make sure image view hasnt been reused
            guard InProgressCache[hash] == url else { return }
            
            // remove from cache
            InProgressCache[hash] = nil
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                if case let .Data(data) = response {
                    
                    view.setImageData(data)
                }
                
                // forward completion block
                completion?(response)
            }
        }
    }
}

// MARK: - WatchKit Extensions

#if os(watchOS)
    
import WatchKit
    
/// The WatchKit Interface type supports image caching.

extension WKInterfaceImage: ImageCacheView { }

extension WKInterfaceGroup: ImageCacheView {
    
    public func setImage(image: UIImage?) {
        
        setBackgroundImage(image)
    }
    
    public func setImageData(imageData: NSData?) {
        
        setBackgroundImageData(imageData)
    }
}

extension WKInterfaceMovie: ImageCacheView {
    
    public func setImage(image: UIImage?) {
        
        let watchImage: WKImage?
        
        if let image = image {
            
            watchImage = WKImage(image: image)
            
        } else {
            
            watchImage = nil
        }
        
        setPosterImage(watchImage)
    }
    
    public func setImageData(imageData: NSData?) {
        
        let watchImage: WKImage?
        
        if let imageData = imageData {
            
            watchImage = WKImage(imageData: imageData)
            
        } else {
            
            watchImage = nil
        }
        
        setPosterImage(watchImage)
    }
}

#elseif os(OSX)

import AppKit

extension NSImageView: ImageCacheView {
    
    public func setImageData(imageData: NSData?) {
        
        if let data = imageData {
            
            self.image = NSImage(data: data)
            
        } else {
            
             self.image = nil
        }
    }
}

#endif
