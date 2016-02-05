//
//  TrackListInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackListInteractor {
    func getTracks(trackGroups: [Int]?) -> [TrackDTO]
}

public class TrackListInteractor: NSObject, ITrackListInteractor {
    var trackDataStore: ITrackDataStore!
    var namedDTOAssembler: NamedDTOAssembler!
    
    public func getTracks(trackGroups: [Int]?) -> [TrackDTO] {
        var tracks: [Track] = trackDataStore.getAllLocal().sort({ $0.name < $1.name })
        
        if (trackGroups != nil && trackGroups!.count > 0) {
            tracks = tracks.filter({ (track) -> Bool in
                if let trackGroup = track.trackGroup {
                    return trackGroups!.contains(trackGroup.id)
                }
                return false
            })
        }
        
        var trackDTO: TrackDTO
        var dtos: [TrackDTO] = []
        for track in tracks {
            trackDTO = namedDTOAssembler.createDTO(track)
            dtos.append(trackDTO)
        }
        
        return dtos
    }
}
