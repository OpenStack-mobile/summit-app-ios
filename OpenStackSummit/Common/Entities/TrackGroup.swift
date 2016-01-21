//
//  TrackGroup.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/18/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift

public class TrackGroup: NamedEntity {
    public dynamic var color = ""
    public dynamic var trackGroupDescription = ""
    public let tracks = List<Track>()
}