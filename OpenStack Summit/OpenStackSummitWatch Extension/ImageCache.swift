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
    
    private let internalCache = NSCache<NSString, NSData>()
    
    public var urlSession = URLSession.shared
    
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
    
    public func load(_ url: URL, completion: @escaping (Response) -> ()) {
        
        // attempt to get from cache first
        if let cachedImageData = self[url] {
            
            completion(.data(cachedImageData))
            return
        }
        
        let task = urlSession.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                
                completion(.error(error!))
                return
            }
            
            guard let data = data else {
                
                completion(.noData(response!))
                return
            }
            
            // cache
            self[url] = data
            
            // success!
            completion(.data(data))
        }) 
        
        task.resume()
    }
    
    // MARK: - Subscripting
    
    public subscript (url: URL) -> Data? {
        
        get { return internalCache.object(forKey: url.absoluteString as NSString) as Data? }
        
        set {
            
            let key = url.absoluteString as NSString
            
            guard let newData = newValue
                else { internalCache.removeObject(forKey: key); return }
            
            internalCache.setObject(newData as NSData, forKey: key)
        }
    }
}

// MARK: - Supporting Types

public extension ImageCache {
    
    public enum Response {
        
        case error(Swift.Error)
        case noData(URLResponse)
        case data(Foundation.Data)
    }
}

public protocol ImageCacheView: class, Hashable {
    
    func loadCached(_ url: URL, placeholder: UIImage?, cache: ImageCache, completion: ((ImageCache.Response) -> ())?)
    
    #if os(watchOS)
    func setImage(_ image: UIImage?)
    #else
    var image: UIImage? { get set }
    #endif
    
    func setImageData(_ imageData: Data?)
}

private var InProgressCache = [Int: URL]()

public extension ImageCacheView {
    
    public func loadCached(_ url: URL, placeholder: UIImage? = nil, cache: ImageCache = ImageCache.shared, completion: ((ImageCache.Response) -> ())? = nil) {
        
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
            
            OperationQueue.main.addOperation {
                
                if case let .data(data) = response {
                    
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
    
    public func setImage(_ image: UIImage?) {
        
        setBackgroundImage(image)
    }
    
    public func setImageData(_ imageData: Data?) {
        
        setBackgroundImageData(imageData)
    }
}

extension WKInterfaceMovie: ImageCacheView {
    
    public func setImage(_ image: UIImage?) {
        
        let watchImage: WKImage?
        
        if let image = image {
            
            watchImage = WKImage(image: image)
            
        } else {
            
            watchImage = nil
        }
        
        setPosterImage(watchImage)
    }
    
    public func setImageData(_ imageData: Data?) {
        
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
    
    public func setImageData(_ imageData: Data?) {
        
        if let data = imageData {
            
            self.image = NSImage(data: data)
            
        } else {
            
             self.image = nil
        }
    }
}

#endif
