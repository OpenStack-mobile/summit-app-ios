//
//  Definitions.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/15/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

struct Constants {
    struct Notifications {
        static let LoggedInNotification = "kLoggedInNotification"
        static let LoggedOutNotification = "kLoggedOutNotification"
        static let ForcedLoggedOutNotification = "kForcedLoggedOutNotification"
    }
    struct SessionKeys {
        static let ActiveSummitTimeZone = "kActiveSummitTimeZone"
        static let GeneralScheduleFilterSelections = "kGeneralScheduleFilterSelections"
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