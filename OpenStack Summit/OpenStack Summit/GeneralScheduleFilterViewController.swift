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

final class GeneralScheduleFilterViewController: UIViewController, FilteredScheduleViewController, UITableViewDelegate, UITableViewDataSource, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var summitTypeTableView: UITableView!
    @IBOutlet weak var trackGroupTableView: UITableView!
    @IBOutlet weak var eventTypeTableView: UITableView!
    @IBOutlet weak var levelTableView: UITableView!
    @IBOutlet weak var summitTypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trackGroupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagListViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTextView: MLPAutoCompleteTextField!
    @IBOutlet weak var tagListView: AMTagListView!
    @IBOutlet weak var clearTagsButton: UIButton!
    
    // MARK: - Properties
    
    var scheduleFilter = ScheduleFilter()
    
    // MARK: - Private Properties
    
    private let cellHeight: CGFloat = 50
    private let extraPadding: CGFloat = 12
    private var filteredTags = [String]()
    
    private var summitTypeItemCount: Int { return scheduleFilter.filterSections[0].items.count }
    private var trackGroupItemCount: Int { return scheduleFilter.filterSections[1].items.count }
    private var eventTypeItemCount: Int { return scheduleFilter.filterSections[2].items.count }
    private var levelItemCount: Int { return scheduleFilter.filterSections[3].items.count }
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summitTypeTableView.registerNib(R.nib.generalScheduleFilterTableViewCell)
        trackGroupTableView.registerNib(R.nib.generalScheduleFilterTableViewCell)
        eventTypeTableView.registerNib(R.nib.generalScheduleFilterTableViewCell)
        levelTableView.registerNib(R.nib.generalScheduleFilterTableViewCell)
        clearTagsButton.layer.cornerRadius = 10
        tagListView.delegate = self
        AMTagView.appearance().tagColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        AMTagView.appearance().innerTagColor = UIColor(red: 53/255, green: 84/255, blue: 121/255, alpha: 1.0)
        tagTextView.autoCompleteDelegate = self
        tagTextView.autoCompleteDataSource = self
        
        navigationItem.title = "FILTER"
        
        updateUI()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(AMTagListView.removeTag(_:)),
            name: AMTagViewNotification,
            object: nil)
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
        
        scheduleFilter.selections[FilterSectionType.Tag]?.removeAll()
        tagListView.removeAllTags()
        resizeTagList(tagListView.contentSize.height)
        tagTextView.text = ""
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        scheduleFilter.hasToRefreshSchedule = true
        
        if (scheduleFilter.filterSections.count == 0) {
            let summitTypes = SummitType.from(realm: Store.shared.realm.objects(RealmSummitType).sort({ $0.name < $1.name }))
            let eventTypes = EventType.from(realm: Store.shared.realm.objects(RealmEventType).sort({ $0.name < $1.name }))
            let summitTracks = Track.from(realm: Store.shared.realm.objects(RealmTrack).sort({ $0.name < $1.name }))
            let summitTrackGroups = TrackGroup.from(realm: Store.shared.realm.objects(RealmTrackGroup).sort({ $0.name < $1.name }))
            let levels = Array(Set(Store.shared.realm.objects(RealmPresentation).map({ $0.level }))).sort()
            
            scheduleFilter.selections[FilterSectionType.SummitType] = [Int]()
            var filterSection = FilterSection()
            filterSection.type = FilterSectionType.SummitType
            filterSection.name = "Credentials"
            var filterSectionItem: FilterSectionItem
            for summitType in summitTypes {
                filterSectionItem = createSectionItem(summitType.identifier, name: summitType.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
                
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.TrackGroup] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.TrackGroup
            filterSection.name = "Track Group"
            for trackGroup in summitTrackGroups {
                filterSectionItem = createSectionItem(trackGroup.identifier, name: trackGroup.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.EventType] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.EventType
            filterSection.name = "Event Type"
            for eventType in eventTypes {
                filterSectionItem = createSectionItem(eventType.identifier, name: eventType.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.Level] = [String]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.Level
            filterSection.name = "Levels"
            for level in levels {
                filterSectionItem = createSectionItem(0, name: level, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.Track] = [Int]()
            filterSection = FilterSection()
            filterSection.type = FilterSectionType.Track
            filterSection.name = "Track"
            for track in summitTracks {
                filterSectionItem = createSectionItem(track.identifier, name: track.name, type: filterSection.type)
                filterSection.items.append(filterSectionItem)
            }
            scheduleFilter.filterSections.append(filterSection)
            
            scheduleFilter.selections[FilterSectionType.Tag] = [Int]()
        }
        
        self.reloadFilters()
        
        self.removeAllTags()
        for tag in scheduleFilter.selections[FilterSectionType.Tag]! {
            self.addTag(tag as! String)
        }
    }
    
    private func reloadFilters() {
        summitTypeTableView.delegate = self
        summitTypeTableView.dataSource = self
        summitTypeTableView.reloadData()
        trackGroupTableView.delegate = self
        trackGroupTableView.dataSource = self
        trackGroupTableView.reloadData()
        eventTypeTableView.delegate = self
        eventTypeTableView.dataSource = self
        eventTypeTableView.reloadData()
        levelTableView.delegate = self
        levelTableView.dataSource = self
        levelTableView.reloadData()
    }
    
    @inline(__always)
    private func addTag(tag: String) {
        
        tagListView.addTag(tag)
        resizeTagList(tagListView.contentSize.height)
    }
    
    @inline(__always)
    private func removeAllTags() {
        
        scheduleFilter.selections[FilterSectionType.Tag]?.removeAll()
        tagListView.removeAllTags()
    }
    
    @inline(__always)
    private func resizeTagList(height: CGFloat) {
        
        tagListViewHeightConstraint.constant = height
        tagListView.updateConstraints()
    }
    
    private func createSectionItem(id: Int, name: String, type: FilterSectionType) -> FilterSectionItem {
        let filterSectionItem = FilterSectionItem()
        filterSectionItem.id = id
        filterSectionItem.name = name
        return filterSectionItem
    }
    
    private func isItemSelected(filterSectionType: FilterSectionType, id: Int) -> Bool {
        if let filterSelectionsForType = scheduleFilter.selections[filterSectionType] {
            for selectedId in filterSelectionsForType {
                if (id == selectedId as! Int) {
                    return true
                }
            }
        }
        return false
    }
    
    private func isItemSelected(filterSectionType: FilterSectionType, name: String) -> Bool {
        if let filterSelectionsForType = scheduleFilter.selections[filterSectionType] {
            for selectedName in filterSelectionsForType {
                if (name == selectedName as! String) {
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
        cell.isOptionSelected = isItemSelected(filterSection.type, id: filterItem.id)
        
        if index == 0 {
            cell.addTopExtraPadding()
        }
        else if index == filterSection.items.count - 1 {
            cell.addBottomExtraPadding()
        }
    }
    
    func toggleSelection(cell cell: GeneralScheduleFilterTableViewCell, filterSection: FilterSection, index: Int) {
        let filterItem = filterSection.items[index]
        
        if (isItemSelected(filterSection.type, id: filterItem.id)) {
            let index = scheduleFilter.selections[filterSection.type]!.indexOf { $0 as! Int == filterItem.id }
            scheduleFilter.selections[filterSection.type]!.removeAtIndex(index!)
            cell.isOptionSelected = false
        }
        else {
            scheduleFilter.selections[filterSection.type]!.append(filterItem.id)
            cell.isOptionSelected = true
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == summitTypeTableView {
            count = summitTypeItemCount
            summitTypeHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        else if tableView == trackGroupTableView {
            count = trackGroupItemCount
            trackGroupHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        else if tableView == eventTypeTableView {
            count = eventTypeItemCount
            eventTypeHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        else if tableView == levelTableView {
            count = levelItemCount
            levelHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.generalScheduleFilterTableViewCell)!

        if tableView == summitTypeTableView {
            configure(cell: cell, at: indexPath, filterSection: scheduleFilter.filterSections[0])
        }
        else if tableView == trackGroupTableView {
            
            let filterSection = scheduleFilter.filterSections[1]
            
            let trackGroup = RealmTrackGroup.find(filterSection.items[indexPath.row].id, realm: Store.shared.realm)
            cell.circleColor = UIColor(hexaString: trackGroup!.color)
            configure(cell: cell, at: indexPath, filterSection: filterSection)
        }
        else if tableView == eventTypeTableView {
            
            configure(cell: cell, at: indexPath, filterSection: scheduleFilter.filterSections[2])
        }
        else if tableView == levelTableView {
            
            let index = indexPath.row
            let filterSection = scheduleFilter.filterSections[3]
            let filterItem = filterSection.items[index]
            
            configure(cell: cell, at: indexPath, filterSection: filterSection)
            
            cell.name = filterItem.name
            cell.isOptionSelected = isItemSelected(filterSection.type, name: filterItem.name)
            
            if index == 0 {
                cell.addTopExtraPadding()
            }
            else if index == filterSection.items.count - 1 {
                cell.addBottomExtraPadding()
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return cellHeight + extraPadding
        }
        else if tableView == summitTypeTableView && indexPath.row == summitTypeItemCount - 1 {
            return cellHeight + extraPadding
        }
        else if tableView == trackGroupTableView && indexPath.row == trackGroupItemCount - 1 {
            return cellHeight + extraPadding
        }
        else if tableView == eventTypeTableView && indexPath.row == eventTypeItemCount - 1 {
            return cellHeight + extraPadding
        }
        else if tableView == levelTableView && indexPath.row == levelItemCount - 1 {
            return cellHeight + extraPadding
        }
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GeneralScheduleFilterTableViewCell
        
        if tableView == summitTypeTableView {
            let filterSection = scheduleFilter.filterSections[0]
            toggleSelection(cell: cell, filterSection: filterSection, index: indexPath.row)
        }
        else if tableView == trackGroupTableView {
            let filterSection = scheduleFilter.filterSections[1]
            toggleSelection(cell: cell, filterSection: filterSection, index: indexPath.row)
        }
        else if tableView == eventTypeTableView {
            let filterSection = scheduleFilter.filterSections[2]
            toggleSelection(cell: cell, filterSection: filterSection, index: indexPath.row)
        }
        else if tableView == levelTableView {
            let filterSection = scheduleFilter.filterSections[3]
            let filterItem = filterSection.items[indexPath.row]
            
            if (isItemSelected(filterSection.type, name: filterItem.name)) {
                let index = scheduleFilter.selections[filterSection.type]!.indexOf { $0 as! String == filterItem.name }
                scheduleFilter.selections[filterSection.type]!.removeAtIndex(index!)
                cell.isOptionSelected = false
            }
            else {
                scheduleFilter.selections[filterSection.type]!.append(filterItem.name)
                cell.isOptionSelected = true
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc private func removeTag(notification: NSNotification) {
        
        func removeTag(tag: String) {
            let escapedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (escapedTag == "") {
                return
            }
            
            let index = scheduleFilter.selections[FilterSectionType.Tag]!.indexOf { $0 as! String == escapedTag }
            scheduleFilter.selections[FilterSectionType.Tag]!.removeAtIndex(index!)
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
            
            tags = Tag.by(searchTerm: string)
        }
        
        return Array(
            Set(tags.map { $0.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }) // unique values trimming tags
            ).sort()
    }
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, didSelectAutoCompleteString selectedString: String!, withAutoCompleteObject selectedObject: MLPAutoCompletionObject!, forRowAtIndexPath indexPath: NSIndexPath!) {
        
        func addTag(tag: String) -> Bool {
            let escapedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (escapedTag == "" || scheduleFilter.selections[FilterSectionType.Tag]?.indexOf{ $0 as! String == escapedTag } != nil) {
                return false
            }
            
            scheduleFilter.selections[FilterSectionType.Tag]!.append(escapedTag)
            return true
        }

        if addTag(selectedString) {
            tagListView.addTag(selectedString)
            tagTextView.text = ""
            resizeTagList(tagListView.contentSize.height)
        }
    }
}
