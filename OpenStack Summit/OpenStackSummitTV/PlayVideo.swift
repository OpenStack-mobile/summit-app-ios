//
//  PlayVideo.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/9/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit
import AVKit
import XCDYouTubeKit

extension UIViewController {
    
    func play(video: Video) {
        
        // add to recently played
        
        Preferences.shared.addRecentlyPlayed(video.identifier)
        
        // load video
        
        XCDYouTubeClient.default().getVideoWithIdentifier(video.youtube) { [weak self] (youtubeVideo, error) in
            
            guard let controller = self else { return }
            
            guard error == nil
                else { controller.showErrorAlert(error!.localizedDescription); return }
            
            guard let streamURL = youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue as NSNumber]
                ?? youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue as NSNumber]
                ?? youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.small240.rawValue as NSNumber]
                else { controller.showErrorAlert("YouTube API Error"); return }
            
            let asset = AVAsset(url: streamURL)
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.externalMetadata = {
                
                var metadata = [AVMutableMetadataItem]()
               
                let titleItem = AVMutableMetadataItem()
                titleItem.identifier = AVMetadataCommonIdentifierTitle
                titleItem.value = video.name as NSCopying & NSObjectProtocol
                titleItem.extendedLanguageTag = "und"
                metadata.append(titleItem)
                
                if let data = video.descriptionText?.data(using: String.Encoding.utf8),
                    let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                    
                    let descriptionItem = AVMutableMetadataItem()
                    descriptionItem.identifier = AVMetadataCommonIdentifierDescription
                    descriptionItem.value = attributedString.string as NSCopying & NSObjectProtocol
                    descriptionItem.extendedLanguageTag = "und"
                    metadata.append(descriptionItem)
                }
                
                if let thumbnailURL = URL(youtubeThumbnail: video.youtube),
                    let data = NSData(contentsOf: thumbnailURL) {
                    
                    let item = AVMutableMetadataItem()
                    item.identifier = AVMetadataCommonIdentifierArtwork
                    item.dataType = kCMMetadataBaseDataType_PNG as String
                    item.value = data
                    item.extendedLanguageTag = "und"
                    metadata.append(item)
                }
                
                return metadata
            }()
            
            let playerViewController = AVPlayerViewController()
            let player = AVPlayer(playerItem: playerItem)
            playerViewController.player = player
            
            controller.present(playerViewController, animated: true) { player.play() }
        }
    }
}
