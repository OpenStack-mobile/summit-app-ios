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
    func getTracks() -> [TrackDTO]
}

public class TrackListInteractor: NSObject, ITrackListInteractor {
    var genericDataStore: GenericDataStore!
    var namedDTOAssembler: NamedDTOAssembler!
    
    public func getTracks() -> [TrackDTO] {
        let tracks: [Track] = genericDataStore.getAllLocal()
        
        var trackDTO: TrackDTO
        var dtos: [TrackDTO] = []
        for track in tracks {
            trackDTO = namedDTOAssembler.createDTO(track)
            dtos.append(trackDTO)
        }
        
        return dtos
    }
}
