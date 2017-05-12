//
//  ShowVideo.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import XCDYouTubeKit
import MediaPlayer
import CoreSummit

extension UIViewController {
    
    func play(video: Video) {
        
        let videoPlayer = XCDYouTubeVideoPlayerViewController(videoIdentifier: video.youtube)
        self.presentMoviePlayerViewControllerAnimated(videoPlayer)
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.view.rawValue)
        
        userActivity.webpageURL = URL(string: "https://www.youtube.com/watch?v=" + video.youtube)
        
        userActivity.userInfo = [AppActivityUserInfo.type.rawValue: AppActivitySummitDataType.video.rawValue, AppActivityUserInfo.identifier.rawValue: video.identifier]
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.type.rawValue, AppActivityUserInfo.identifier.rawValue]
        
        userActivity.becomeCurrent()
        userActivity.needsSave = true
        
        // listen to when the video stops playing
        var observer: AnyObject!
        observer = NotificationCenter.default.addObserver(forName: Notification.Name.MPMoviePlayerPlaybackDidFinish, object: videoPlayer.moviePlayer, queue: nil) { (notification) in
            
            userActivity.invalidate()
            
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
