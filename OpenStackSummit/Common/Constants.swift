//
//  Constants.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

struct Constants {
    struct Notifications {
        static let LoggedInNotification = "kLoggedInNotification"
        static let LoggedOutNotification = "kLoggedOutNotification"
    }
    struct SessionKeys {
        static let ActiveSummitTimeZone = "kActiveSummitTimeZone"
        static let GeneralScheduleFilterSelections = "kGeneralScheduleFilterSelections"
        static let SearchTerm = "kSearchTerm"
    }
    struct Urls {
        #if DEBUG
        static let ResourceServerBaseUrl = "https://dev-resource-server"
        static let AuthServerBaseUrl = "https://dev-identity-provider"
        #else
        static let ResourceServerBaseUrl = "https://resource-server"
        static let AuthServerBaseUrl = "https://identity-provider"
        #endif
    }
    struct Auth {
        #if DEBUG
        static let ClientIdOpenID = "OpenID Client ID"
        static let SecretOpenID = "OpenID Secret"
        static let ClientIdServiceAccount = "Service Account Client ID"
        static let SecretServiceAccount = "Service Account Secret"
        #else
        static let ClientIdOpenID = "OpenID Client ID"
        static let SecretOpenID = "OpenID Secret"
        static let ClientIdServiceAccount = "Service Account Client ID"
        static let SecretServiceAccount = "Service Account Secret"
        #endif
    }
    
    static let ErrorDomain = "org.openstack.ios.summit"
}