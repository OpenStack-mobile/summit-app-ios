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
    var Levels = [String]()
    
    public func viewLoad() {
        Levels = interactor.getLevels()
        viewController.reloadData()
    }
    
    public func buildScheduleCell(cell: ILevelTableViewCell, index: Int) {
        let level = Levels[index]
        cell.name = level
    }
    
    public func getLevelCount() -> Int {
        return Levels.count
    }
    
    public func showLevelEvents(index: Int) {
        let level = Levels[index]
        wireframe.showLevelSchedule(level)
    }
}

