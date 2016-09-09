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
            
            let streamURL = youtubeVideo!.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ?? youtubeVideo!.streamURLs.values.first!
            
            let player = AVPlayer(URL: streamURL)
            
            player.play()
        }
    }
}