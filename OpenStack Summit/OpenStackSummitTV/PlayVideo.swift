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
    
    func playVideo(video: Video) {
        
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video.youtube) { [weak self] (youtubeVideo, error) in
            
            guard let controller = self else { return }
            
            guard error == nil else {
                
                controller.showErrorAlert(error!.localizedDescription)
                return
            }
            
            guard let streamURL = youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue as NSNumber]
                ?? youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue as NSNumber]
                ?? youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.Small240.rawValue as NSNumber]
                else { controller.showErrorAlert("YouTube API Error"); return }
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = AVPlayer(URL: streamURL)
            controller.presentViewController(playerViewController, animated: true) { playerViewController.player?.play() }
        }
    }
}