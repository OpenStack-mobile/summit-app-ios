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
        static let ResourceServerBaseUrl = "https://testresource-server.openstack.org"
        static let AuthServerBaseUrl = "https://testopenstackid.openstack.org"
        #else
        static let ResourceServerBaseUrl = "https://openstackid-resources.openstack.org"
        static let AuthServerBaseUrl = "https://openstackid.org"
        #endif
    }
    struct Auth {
        struct Module {
            static let ErrorDomain = "OpenStackOAuth2Module"
            static let SessionLost = 8
        }
        
        #if DEBUG
        static let ClientIdOpenID = "ugSc.5IJB7MOpVHOs4anxyZi~PJsIfJJ.openstack.client"
        static let SecretOpenID = "NvEAT3ScN5c5p9yPS67GeoBo2M_8YLFezeAdALF~dsD-pxXmBU6JRL0ZOyNpGEhM"
        static let ClientIdServiceAccount = "m22i15-mlfb9pa7_xE9awfGchL0emthA.openstack.client"
        static let SecretServiceAccount = "NWqDnFMdQrR.KNUfjPu-4SZUrABnHsM1SbwSsvOV4uk0jGI7X7DPC~WCsMSVH4Ci"
        #else
        static let ClientIdOpenID = "KaRO.TUwmVDL3uAislT2.BeLgRjnKtri.openstack.client"
        static let SecretOpenID = "b-p0jKvn.ZgxmLtv1VYMP-QGI~OgOfSmvfX-MY2wtu5AWmnvvIekVENZcTmEvidf"
        static let ClientIdServiceAccount = "wgRvPleVDbKUN3HSetZtcIenRACAMnkA.openstack.client"
        static let SecretServiceAccount = "0x.9MK7kw0cTzFKltDgrC.TJhSLVqXimstQGl21XhKcbGgxSpD~e7fHr1QeVck2l"
        #endif
    }
    
    static let ErrorDomain = "org.openstack.ios.summit"
}