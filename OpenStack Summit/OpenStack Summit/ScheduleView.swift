//
//  ScheduleView.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AFHorizontalDayPicker

final class ScheduleView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var dayPicker: AFHorizontalDayPicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var nowButton: UIButton!
    @IBOutlet private weak var nowWidthConstraint: NSLayoutConstraint!
    
    var nowButtonEnabled: Bool = true {
        
        didSet {
            
            self.nowWidthConstraint.constant = nowButtonEnabled ? 60 : 0
            self.nowButton.hidden = nowButtonEnabled == false
            
            self.needsUpdateConstraints()
        }
    }
    
    var activeDates: [NSDate] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSBundle.mainBundle().loadNibNamed("ScheduleView", owner: self, options: nil)
        
        dayPicker.backgroundColor = UIColor(hexaString: "#E5E5E5")
        
        dayPicker.dayNumberActiveColor = UIColor(hexaString: "#4A4A4A")
        dayPicker.dayNumberInactiveColor = UIColor(hexaString: "#9B9B9B")
        dayPicker.dayNumberSelectedColor = UIColor(hexaString: "#FFFFFF")
        
        dayPicker.dayNumberActiveFont = UIFont.systemFontOfSize(13)
        dayPicker.dayNumberInactiveFont = UIFont.systemFontOfSize(13)
        dayPicker.dayNumberSelectedFont = UIFont.systemFontOfSize(13)
        
        dayPicker.dayNameActiveColor = UIColor(hexaString: "#4A4A4A")
        dayPicker.dayNameInactiveColor = UIColor(hexaString: "#9B9B9B")
        dayPicker.dayNameSelectedColor = UIColor(hexaString: "#FFFFFF")
        
        dayPicker.dayNameActiveFont = UIFont.systemFontOfSize(13)
        dayPicker.dayNameInactiveFont = UIFont.systemFontOfSize(13)
        dayPicker.dayNameSelectedFont = UIFont.systemFontOfSize(13)
        
        dayPicker.backgroundActiveColor = UIColor(hexaString: "#E5E5E5")
        dayPicker.backgroundInactiveColor = UIColor(hexaString: "#E5E5E5")
        dayPicker.backgroundSelectedColor = UIColor(hexaString: "#4A4A4A")
        
        addSubview(self.view)
    }
    
    func setInactiveAppearanceWithCell(cell: AFDayCell) {
        cell.dayNumber.font = dayPicker.dayNumberInactiveFont
        cell.dayNumber.textColor = dayPicker.dayNumberInactiveColor
        cell.dayName.font = dayPicker.dayNameInactiveFont
        cell.dayName.textColor = dayPicker.dayNameInactiveColor
        cell.contentView.backgroundColor = dayPicker.backgroundInactiveColor
        cell.userInteractionEnabled = false
    }
    
    func setSelectedAppearanceWithCell(cell: AFDayCell) {
        cell.dayNumber.font = dayPicker.dayNumberSelectedFont
        cell.dayNumber.textColor = dayPicker.dayNumberSelectedColor
        cell.dayName.font = dayPicker.dayNameSelectedFont
        cell.dayName.textColor = dayPicker.dayNameSelectedColor
        cell.contentView.backgroundColor = dayPicker.backgroundSelectedColor
        cell.userInteractionEnabled = true
    }
    
    func setActiveAppearanceWithCell(cell: AFDayCell) {
        cell.dayNumber.font = dayPicker.dayNumberActiveFont
        cell.dayNumber.textColor = dayPicker.dayNumberActiveColor
        cell.dayName.font = dayPicker.dayNameActiveFont
        cell.dayName.textColor = dayPicker.dayNameActiveColor
        cell.contentView.backgroundColor =  dayPicker.backgroundActiveColor
        cell.userInteractionEnabled = true
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker, widthForItemWithDate date: NSDate) -> CGFloat {
        let width: CGFloat = 56
        return width
    }
    
    func horizontalDayPicker(picker: AFHorizontalDayPicker!, requestCustomizedCellFromCell cell: AFDayCell!) -> AFDayCell! {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // configure day number (example: 23 or 1 or 45)
        let dayNumber = UILabel(frame: CGRectMake(0.0, cell.contentView.frame.size.height / 3 * 2 - cell.contentView.frame.size.height / 6, cell.contentView.frame.size.width, cell.contentView.frame.size.height / 3))
        dayNumber.textAlignment = .Center
        dayNumber.text = "\(cell.date.mt_dayOfMonth())"
        cell.dayNumber = dayNumber
        cell.contentView.addSubview(dayNumber)
        
        // configure day name  (example: Thu, Чт)
        let dayName = UILabel(frame: CGRectMake(0.0, 0.0, cell.contentView.frame.size.width, cell.contentView.frame.size.height / 3 * 2))
        dayName.textAlignment = .Center
        dayName.text = cell.date.mt_stringFromDateWithFormat("EEE", localized: true).uppercaseString
        cell.dayName = dayName
        cell.contentView.addSubview(dayName)
        
        if !cell.active || !activeDates.contains(cell.date) {
            self.setInactiveAppearanceWithCell(cell)
        }
        else {
            if cell.wasSelected {
                self.setSelectedAppearanceWithCell(cell)
            }
            else {
                self.setActiveAppearanceWithCell(cell)
            }
        }
        
        return cell
    }
}
