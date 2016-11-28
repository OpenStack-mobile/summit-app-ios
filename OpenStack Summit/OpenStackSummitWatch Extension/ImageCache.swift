//
//  ImageCache.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import WatchKit

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

// MARK: - WatchKit Extensions

/// The WatchKit Interface type supports image caching.
public protocol ImageCacheInterface: class {
    
    func loadCached(url: NSURL, placeholder: UIImage?, cache: ImageCache, completion: (ImageCache.Response -> ())?)
    
    func setImage(image: UIImage?)
    
    func setImageData(imageData: NSData?)
}

public extension ImageCacheInterface {
    
    public func loadCached(url: NSURL, placeholder: UIImage? = nil, cache: ImageCache = ImageCache.shared, completion: (ImageCache.Response -> ())? = nil) {
        
        // set placeholder
        if let placeholder = placeholder {
            
            setImage(placeholder)
        }
        
        // load data
        cache.load(url) { [weak self] (response) in
            
            guard let interface = self else { return }
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                if case let .Data(data) = response {
                    
                    interface.setImageData(data)
                }
                
                // forward completion block
                completion?(response)
            }
        }
    }
}

extension WKInterfaceImage: ImageCacheInterface { }

extension WKInterfaceGroup: ImageCacheInterface {
    
    public func setImage(image: UIImage?) {
        
        setBackgroundImage(image)
    }
    
    public func setImageData(imageData: NSData?) {
        
        setBackgroundImageData(imageData)
    }
}

extension WKInterfaceMovie: ImageCacheInterface {
    
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
