//
//  GeneralScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import MLPAutoCompleteTextField
import AMTagListView
import CoreSummit

protocol GeneralScheduleFilterViewControllerDelegate: class {
    
    func scheduleFilterController(controller: GeneralScheduleFilterViewController, didUpdateFilter filter: ScheduleFilter)
}

final class GeneralScheduleFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var filtersTableView: UITableView!
    @IBOutlet weak var filtersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTextView: MLPAutoCompleteTextField!
    @IBOutlet weak var tagListView: AMTagListView!
    @IBOutlet weak var clearTagsButton: UIButton!
    
    // MARK: - Private Properties
    
    private let headerHeight: CGFloat = 40
    private let cellHeight: CGFloat = 45
    private let extraPadding: CGFloat = 5
    private var filteredTags = [String]()
    
    private var activeTalksItemCount: Int { return FilterManager.shared.filter.value.filterSections[0].items.count }
    private var trackGroupItemCount: Int { return FilterManager.shared.filter.value.filterSections[1].items.count }
    private var levelItemCount: Int { return FilterManager.shared.filter.value.filterSections[2].items.count }
    private var venuesItemCount: Int { return FilterManager.shared.filter.value.filterSections[3].items.count }
    private var totalItemCount: Int { return activeTalksItemCount + trackGroupItemCount + levelItemCount + venuesItemCount }
    
    private var filterObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = filterObserver { FilterManager.shared.filter.remove(observer) }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        filtersTableView.registerNib(R.nib.generalScheduleFilterTableViewCell)

        let nib = UINib(nibName: "TableViewHeaderView", bundle: nil)
        filtersTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        // https://github.com/mac-cain13/R.swift/issues/144
        //filtersTableView.registerNibForHeaderFooterView(R.nib.tableViewHeaderView)
        
        clearTagsButton.layer.cornerRadius = 10
        tagListView.delegate = self
        AMTagView.appearance().tagColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        AMTagView.appearance().innerTagColor = UIColor(red: 53/255, green: 84/255, blue: 121/255, alpha: 1.0)
        tagTextView.autoCompleteTableBackgroundColor = UIColor.whiteColor()
        tagTextView.autoCompleteDelegate = self
        tagTextView.autoCompleteDataSource = self
        
        navigationItem.title = "FILTER"
        
        updateUI()
        
        filterObserver = FilterManager.shared.filter.observe { [weak self] _ in self?.updateUI() }
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(AMTagListView.removeTag(_:)),
            name: AMTagViewNotification,
            object: nil)
        
        FilterManager.shared.filter.value.updateSections()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func dissmisButtonPressed(sender: AnyObject) {
        
        let presentingViewController = navigationController!.presentingViewController!
        
        presentingViewController.dismissViewControllerAnimated(true) {
            self.navigationController!.setViewControllers([], animated: false)
        }
    }
    
    @IBAction func willClearAllTags(sender: AnyObject) {
        
        FilterManager.shared.filter.value.selections[FilterSectionType.Tag]?.removeAll()
        tagListView.removeAllTags()
        resizeTagList(tagListView.contentSize.height)
        tagTextView.text = ""
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        self.reloadFilters()
        
        for tag in FilterManager.shared.filter.value.selections[FilterSectionType.Tag]!.rawValue as! [String] {
            
            self.addTag(tag)
        }
    }
    
    @inline(__always)
    private func reloadFilters() {
        
        let scheduleFilter = FilterManager.shared.filter.value
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.reloadData()
        
        filtersTableViewHeightConstraint.constant = cellHeight * CGFloat(totalItemCount)
        filtersTableViewHeightConstraint.constant += headerHeight * (CGFloat(scheduleFilter.filterSections.count) - 2)
        filtersTableViewHeightConstraint.constant += extraPadding * 4 * (CGFloat(scheduleFilter.filterSections.count) - (activeTalksItemCount == 0 ? 1 : 0)) - (activeTalksItemCount == 0 ? 0 : extraPadding * 2)
    }
    
    @inline(__always)
    private func addTag(tag: String) {
        
        tagListView.addTag(tag)
        resizeTagList(tagListView.contentSize.height)
    }
    
    @inline(__always)
    private func removeAllTags() {
        
        FilterManager.shared.filter.value.selections[FilterSectionType.Tag]?.removeAll()
        tagListView.removeAllTags()
    }
    
    @inline(__always)
    private func resizeTagList(height: CGFloat) {
        
        tagListViewHeightConstraint.constant = height
        tagListView.updateConstraints()
    }
    
    private func isItemSelected(filterSectionType: FilterSectionType, id: Int) -> Bool {
        
        if let filterSelectionsForType = FilterManager.shared.filter.value.selections[filterSectionType]?.rawValue as? [Int] {
            
            for selectedId in filterSelectionsForType {
                
                if id == selectedId{
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    private func isItemSelected(filterSectionType: FilterSectionType, name: String) -> Bool {
        
        if let filterSelectionsForType = FilterManager.shared.filter.value.selections[filterSectionType]?.rawValue as? [String] {
            
            for selectedName in filterSelectionsForType {
                
                if name == selectedName {
                    
                    return true
                }
            }
        }
        return false
    }
    
    private func configure(cell cell: GeneralScheduleFilterTableViewCell, at indexPath: NSIndexPath, filterSection: FilterSection) {
        
        let index = indexPath.row
        let filterItem = filterSection.items[index]
        
        cell.name = filterItem.name
        
        if filterSection.type != FilterSectionType.Level && filterSection.type != FilterSectionType.ActiveTalks {
            
            cell.isOptionSelected = isItemSelected(filterSection.type, id: filterItem.identifier)
        }
        else {
            
            cell.isOptionSelected = isItemSelected(filterSection.type, name: filterItem.name)
        }
        
        if filterSection.type == FilterSectionType.TrackGroup {
            
            let trackGroup = try! TrackGroup.find(filterSection.items[indexPath.row].identifier, context: Store.shared.managedObjectContext)
            cell.circleColor = UIColor(hexaString: trackGroup!.color)
        }
        
        if index == 0 {
            
            cell.addTopExtraPadding()
        }
        else if index == filterSection.items.count - 1 {
            
            cell.addBottomExtraPadding()
        }
    }
    
    func toggleSelection(cell cell: GeneralScheduleFilterTableViewCell, filterSection: FilterSection, index: Int) {
        
        let filterItem = filterSection.items[index]
        
        switch filterSection.type {
            
        case .Tag, .Track, .TrackGroup, .Venue:
            
            if isItemSelected(filterSection.type, id: filterItem.identifier) {
                
                let index = FilterManager.shared.filter.value.selections[filterSection.type]!.rawValue.indexOf { $0 as! Int == filterItem.identifier }
                FilterManager.shared.filter.value.selections[filterSection.type]!.removeAtIndex(index!)
                cell.isOptionSelected = false
            }
            else {
                
                FilterManager.shared.filter.value.selections[filterSection.type]!.append(filterItem.identifier)
                cell.isOptionSelected = true
            }
            
        case .Level, .ActiveTalks:
            
            if isItemSelected(filterSection.type, name: filterItem.name) {
                
                let index = FilterManager.shared.filter.value.selections[filterSection.type]!.rawValue.indexOf { $0 as! String == filterItem.name }
                FilterManager.shared.filter.value.selections[filterSection.type]!.removeAtIndex(index!)
                cell.isOptionSelected = false
            }
            else {
                
                FilterManager.shared.filter.value.selections[filterSection.type]!.append(filterItem.name)
                cell.isOptionSelected = true
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return FilterManager.shared.filter.value.filterSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let filterSection = FilterManager.shared.filter.value.filterSections[section]
        
        switch filterSection.type {
            
        case .ActiveTalks: return activeTalksItemCount
            
        case .TrackGroup: return trackGroupItemCount
            
        case .Level: return levelItemCount
            
        case .Venue: return venuesItemCount
            
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.generalScheduleFilterTableViewCell)!
        
        let filterSection = FilterManager.shared.filter.value.filterSections[indexPath.section]
        
        configure(cell: cell, at: indexPath, filterSection: filterSection)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let filterSection = FilterManager.shared.filter.value.filterSections[section]
        
        return filterSection.type != FilterSectionType.ActiveTalks ? headerHeight : 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("TableViewHeaderView")
        
        let filterSection = FilterManager.shared.filter.value.filterSections[section]
        
        let header = cell as! TableViewHeaderView
        header.titleLabel.text = filterSection.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let filterSection = FilterManager.shared.filter.value.filterSections[indexPath.section]
        
        if indexPath.row == 0 || indexPath.row == filterSection.items.count - 1 {
            
            return cellHeight + extraPadding * 2
        }
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GeneralScheduleFilterTableViewCell
        
        let filterSection = FilterManager.shared.filter.value.filterSections[indexPath.section]
        
        toggleSelection(cell: cell, filterSection: filterSection, index: indexPath.row)
    }
    
    // MARK: - Notifications
    
    @objc private func removeTag(notification: NSNotification) {
        
        func removeTag(tag: String) {
            
            let escapedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if escapedTag == "" {
                
                return
            }
            
            let index = FilterManager.shared.filter.value.selections[FilterSectionType.Tag]!.rawValue.indexOf { $0 as! String == escapedTag }
            FilterManager.shared.filter.value.selections[FilterSectionType.Tag]!.removeAtIndex(index!)
        }
        
        let tagView = notification.object as! AMTagView
        removeTag(tagView.tagText!)
        tagListView.removeTag(tagView)
        resizeTagList(tagListView.contentSize.height)
    }
    
    // MARK: - MLPAutoCompleteTextFieldDataSource
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!) -> [AnyObject]!  {
        
        guard string.isEmpty == false else { return [] }
        
        var tags: [Tag]!
        
        dispatch_sync(dispatch_get_main_queue()) {
            
            tags = try! Tag.search(string, context: Store.shared.managedObjectContext)
        }
        
        return Array(
            Set(tags.map { $0.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }) // unique values trimming tags
            ).sort()
    }
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, didSelectAutoCompleteString selectedString: String!, withAutoCompleteObject selectedObject: MLPAutoCompletionObject!, forRowAtIndexPath indexPath: NSIndexPath!) {
        
        func addTag(tag: String) -> Bool {
            
            let escapedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (escapedTag == "" || FilterManager.shared.filter.value.selections[FilterSectionType.Tag]?.rawValue.indexOf{ $0 as! String == escapedTag } != nil) {
                
                return false
            }
            
            FilterManager.shared.filter.value.selections[FilterSectionType.Tag]!.append(escapedTag)
            
            return true
        }

        if addTag(selectedString) {
            
            tagListView.addTag(selectedString)
            tagTextView.text = ""
            resizeTagList(tagListView.contentSize.height)
        }
    }
}
