//
//  Notification.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// Notifications used internally by OpenStack Summit.
enum Notification: String {
    
    /// The user signed in.
    case loggedIn
    
    /// The user logged out.
    case loggedOut
    
    /// The user was forceably logged out (e.g. expired token). 
    case forcedLoggedOut
}