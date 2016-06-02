//
//  RealmTrackGroup.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmTrackGroup: RealmNamed {
    
    public dynamic var color = ""
    public dynamic var trackGroupDescription = ""
    public let tracks = List<RealmTrack>()
}