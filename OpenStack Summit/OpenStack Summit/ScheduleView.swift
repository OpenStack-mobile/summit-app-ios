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
    @IBOutlet private(set) weak var dayPicker: AFHorizontalDayPicker!
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var noEventsLabel: UILabel!
    @IBOutlet private(set) weak var nowButton: UIButton!
    @IBOutlet private weak var nowWidthConstraint: NSLayoutConstraint!
    
    var nowButtonEnabled: Bool = true {
        
        didSet {
            
            self.nowWidthConstraint.constant = nowButtonEnabled ? 60 : 0
            self.nowButton.isHidden = nowButtonEnabled == false
            
            self.needsUpdateConstraints()
        }
    }
    
    var activeDates: [Date] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("ScheduleView", owner: self, options: nil)
        
        dayPicker.backgroundColor = UIColor(hexString: "#E5E5E5")
        
        dayPicker.dayNumberActiveColor = UIColor(hexString: "#4A4A4A")
        dayPicker.dayNumberInactiveColor = UIColor(hexString: "#9B9B9B")
        dayPicker.dayNumberSelectedColor = UIColor(hexString: "#FFFFFF")
        
        dayPicker.dayNumberActiveFont = UIFont.systemFont(ofSize: 13)
        dayPicker.dayNumberInactiveFont = UIFont.systemFont(ofSize: 13)
        dayPicker.dayNumberSelectedFont = UIFont.systemFont(ofSize: 13)
        
        dayPicker.dayNameActiveColor = UIColor(hexString: "#4A4A4A")
        dayPicker.dayNameInactiveColor = UIColor(hexString: "#9B9B9B")
        dayPicker.dayNameSelectedColor = UIColor(hexString: "#FFFFFF")
        
        dayPicker.dayNameActiveFont = UIFont.systemFont(ofSize: 13)
        dayPicker.dayNameInactiveFont = UIFont.systemFont(ofSize: 13)
        dayPicker.dayNameSelectedFont = UIFont.systemFont(ofSize: 13)
        
        dayPicker.backgroundActiveColor = UIColor(hexString: "#E5E5E5")
        dayPicker.backgroundInactiveColor = UIColor(hexString: "#E5E5E5")
        dayPicker.backgroundSelectedColor = UIColor(hexString: "#4A4A4A")
        
        addSubview(self.view)
    }
    
    func setInactiveAppearanceWithCell(_ cell: AFDayCell) {
        cell.dayNumber.font = dayPicker.dayNumberInactiveFont
        cell.dayNumber.textColor = dayPicker.dayNumberInactiveColor
        cell.dayName.font = dayPicker.dayNameInactiveFont
        cell.dayName.textColor = dayPicker.dayNameInactiveColor
        cell.contentView.backgroundColor = dayPicker.backgroundInactiveColor
        cell.isUserInteractionEnabled = false
    }
    
    func setSelectedAppearanceWithCell(_ cell: AFDayCell) {
        cell.dayNumber.font = dayPicker.dayNumberSelectedFont
        cell.dayNumber.textColor = dayPicker.dayNumberSelectedColor
        cell.dayName.font = dayPicker.dayNameSelectedFont
        cell.dayName.textColor = dayPicker.dayNameSelectedColor
        cell.contentView.backgroundColor = dayPicker.backgroundSelectedColor
        cell.isUserInteractionEnabled = true
    }
    
    func setActiveAppearanceWithCell(_ cell: AFDayCell) {
        cell.dayNumber.font = dayPicker.dayNumberActiveFont
        cell.dayNumber.textColor = dayPicker.dayNumberActiveColor
        cell.dayName.font = dayPicker.dayNameActiveFont
        cell.dayName.textColor = dayPicker.dayNameActiveColor
        cell.contentView.backgroundColor =  dayPicker.backgroundActiveColor
        cell.isUserInteractionEnabled = true
    }
    
    func horizontalDayPicker(_ picker: AFHorizontalDayPicker, widthForItemWithDate date: Date) -> CGFloat {
        let width: CGFloat = 56
        return width
    }
    
    func horizontalDayPicker(_ picker: AFHorizontalDayPicker!, requestCustomizedCellFromCell cell: AFDayCell!) -> AFDayCell! {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // configure day number (example: 23 or 1 or 45)
        let dayNumber = UILabel(frame: CGRect(x: 0.0, y: cell.contentView.frame.size.height / 3 * 2 - cell.contentView.frame.size.height / 6, width: cell.contentView.frame.size.width, height: cell.contentView.frame.size.height / 3))
        dayNumber.textAlignment = .center
        dayNumber.text = "\((cell.date as NSDate).mt_dayOfMonth())"
        cell.dayNumber = dayNumber
        cell.contentView.addSubview(dayNumber)
        
        // configure day name  (example: Thu, Чт)
        let dayName = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: cell.contentView.frame.size.width, height: cell.contentView.frame.size.height / 3 * 2))
        dayName.textAlignment = .center
        dayName.text = (cell.date as NSDate).mt_stringFromDate(withFormat: "EEE", localized: true).uppercased()
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
