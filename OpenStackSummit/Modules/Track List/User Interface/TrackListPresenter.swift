//
//  TrackListPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol ITrackListPresenterProtocol {
    func viewLoad()
    func showTrackEvents(index: Int)
    func buildScheduleCell(cell: TrackTableViewCell, index: Int)
    func getTrackCount() -> Int
}

public class TrackListPresenter: ITrackListPresenterProtocol {
    var viewController: TrackListViewController!
    var interactor: ITrackListInteractor!
    var wireframe: TrackListWireframe!
    
    var scheduleFilter: ScheduleFilter!
    var tracks = [Track]()
    
    public func viewLoad() {
        let trackGroupSelections = scheduleFilter.selections[FilterSectionType.TrackGroup] as? [Int]
        tracks = interactor.getTracks(trackGroupSelections)
        viewController.reloadData()
    }
    
    public func buildScheduleCell(cell: TrackTableViewCell, index: Int) {
        let track = tracks[index]
        cell.name = track.name
    }
    
    public func getTrackCount() -> Int {
        return tracks.count
    }
    
    public func showTrackEvents(index: Int) {
        let track = tracks[index]
        wireframe.showTrackSchedule(track)
    }
}
