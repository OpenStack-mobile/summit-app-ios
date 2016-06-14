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
        var tracks = trackDataStore.getAllLocal().sort({ $0.name < $1.name })
        var filteredTracks: [Track] = []
        
        if trackGroups != nil && trackGroups!.count > 0 {
            for track in tracks {
                if trackMathFilter(track, trackGroupIds: trackGroups!) {
                    filteredTracks.append(track)
                }
            }
            tracks = filteredTracks
        }
        
        var trackDTO: TrackDTO
        var dtos: [TrackDTO] = []
        for track in tracks {
            trackDTO = namedDTOAssembler.createDTO(track)
            dtos.append(trackDTO)
        }
        
        return dtos
    }
    
    func trackMathFilter(track: Track, trackGroupIds: [Int]) -> Bool {
        if track.trackGroups.count > 0 {
            for trackGroup in track.trackGroups {
                if trackGroupIds.contains(trackGroup.id) {
                    return true
                }
            }
        }
        return false
    }
}
