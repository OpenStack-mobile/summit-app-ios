//
//  PushNotificationManager.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/15/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit
import Parse

public final class PushNotificationsManager {
    
    public static func subscribeToPushChannelsUsingContext(completionBlock: (succeeded: Bool, error: NSError?) -> Void) {
        
        assert(PFInstallation.currentInstallation() != nil)
        
        var channels = [String]()
        
        // TODO: Observe summit manager and authenticated member
        
        let context = Store.shared.managedObjectContext
        let summitID = SummitManager.shared.summit.value
        guard let summit = try! SummitManagedObject.find(summitID, context: context)
            else { return }
        
        channels.append("su_\(summit.identifier)")
        
        if let member = Store.shared.authenticatedMember {
            
            channels.append("me_\(member.id)")
            
            if member.attendeeRole != nil {
                channels.append("attendees")
            }
            
            if member.speakerRole != nil {
                channels.append("speakers")
            }
        }
        
        PFInstallation.currentInstallation()!.channels = channels
        PFInstallation.currentInstallation()!.saveEventually(completionBlock)
    }
    
    public static func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> ()) {
        
        var channels = [String]()
        
        let context = Store.shared.managedObjectContext
        let summitID = SummitManager.shared.summit.value
        guard let summit = try! SummitManagedObject.find(summitID, context: context)
            else { return }
        
        channels.append("su_\(summit.identifier)")
        
        PFInstallation.currentInstallation()!.channels = channels
        PFInstallation.currentInstallation()!.saveEventually(completionBlock)
    }
}
