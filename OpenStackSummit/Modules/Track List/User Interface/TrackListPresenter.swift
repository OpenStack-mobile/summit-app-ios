//
//  TrackListPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ITrackListPresenter {
    func viewLoad()
    func showTrackEvents(index: Int)
    func buildScheduleCell(cell: ITrackTableViewCell, index: Int)
    func getTrackCount() -> Int
}

public class TrackListPresenter: NSObject, ITrackListPresenter {
    var viewController: ITrackListViewController!
    var interactor: ITrackListInteractor!
    var wireframe: ITrackListWireframe!
    var tracks = [TrackDTO]()
    
    public func viewLoad() {
        tracks = interactor.getTracks()
        viewController.reloadData()
    }
    
    public func buildScheduleCell(cell: ITrackTableViewCell, index: Int) {
        let track = tracks[index]
        cell.name = track.name
    }
    
    public func getTrackCount() -> Int {
        return tracks.count
    }
    
    public func showTrackEvents(index: Int) {
        let track = tracks[index]
        wireframe.showTrackSchedule(track.id)
    }
}
