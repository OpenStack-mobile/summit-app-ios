//
//  PresentationCategory.swift
//  
//
//  Created by Claudio on 8/12/15.
//
//

import Foundation
import RealmSwift

public class Track: NamedEntity {

    public var trackGroup: TrackGroup? {
        return linkingObjects(TrackGroup.self, forProperty: "tracks").first
    }
}
