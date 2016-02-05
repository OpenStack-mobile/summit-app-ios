//
//  LevelListPresenter.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ILevelListPresenter {
    func viewLoad()
    func showLevelEvents(index: Int)
    func buildScheduleCell(cell: ILevelTableViewCell, index: Int)
    func getLevelCount() -> Int
}

public class LevelListPresenter: NSObject, ILevelListPresenter {
    var viewController: ILevelListViewController!
    var interactor: ILevelListInteractor!
    var wireframe: ILevelListWireframe!
    
    var scheduleFilter: ScheduleFilter!
    var levels = [String]()
    
    public func viewLoad() {
        levels = interactor.getLevels()
        if let levelSelections = scheduleFilter.selections[FilterSectionType.Level] as? [String] {
            if levelSelections.count > 0 {
                levels = levels.filter { levelSelections.contains($0) }
            }
        }
        viewController.reloadData()
    }
    
    public func buildScheduleCell(cell: ILevelTableViewCell, index: Int) {
        let level = levels[index]
        cell.name = level
    }
    
    public func getLevelCount() -> Int {
        return levels.count
    }
    
    public func showLevelEvents(index: Int) {
        let level = levels[index]
        wireframe.showLevelSchedule(level)
    }
}

