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

final class GeneralScheduleFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource {
    
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
    
    // MARK: - Private Properties
    
    private let cellHeight: CGFloat = 50
    private let extraPadding: CGFloat = 12
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        summitTypeTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        trackGroupTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        eventTypeTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        levelTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        clearTagsButton.layer.cornerRadius = 10
        tagListView.delegate = self
        AMTagView.appearance().tagColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        AMTagView.appearance().innerTagColor = UIColor(red: 53/255, green: 84/255, blue: 121/255, alpha: 1.0)
        tagTextView.autoCompleteDelegate = self
        tagTextView.autoCompleteDataSource = self
        
        navigationItem.title = "FILTER"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "removeTag:",
            name: AMTagViewNotification,
            object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func dissmisButtonPressed(sender: AnyObject) {
        
        presenter.dismissViewController()
    }
    
    @IBAction func willClearAllTags(sender: AnyObject) {
        presenter.removeAllTags();
        tagListView.removeAllTags()
        resizeTagList(tagListView.contentSize.height)
        tagTextView.text = ""
    }
    
    // MARK: - Private Methods
    
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
    
    private func addTag(tag: String) {
        tagListView.addTag(tag)
        resizeTagList(tagListView.contentSize.height)
    }
    
    private func removeTag(notification: NSNotification) {
        let tagView = notification.object as! AMTagView
        presenter.removeTag(tagView.tagText!)
        tagListView.removeTag(tagView)
        resizeTagList(tagListView.contentSize.height)
    }
    
    private func removeAllTags() {
        //tagListView.removeAllTags()
    }
    
    private func resizeTagList(height: CGFloat) {
        
        tagListViewHeightConstraint.constant = height
        tagListView.updateConstraints()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return cellHeight + extraPadding
        }
        else if tableView == summitTypeTableView && indexPath.row == presenter.getSummitTypeItemCount() - 1 {
            return cellHeight + extraPadding
        }
        else if tableView == trackGroupTableView && indexPath.row == presenter.getTrackGroupItemCount() - 1 {
            return cellHeight + extraPadding
        }
        else if tableView == eventTypeTableView && indexPath.row == presenter.getEventTypeItemCount() - 1 {
            return cellHeight + extraPadding
        }
        else if tableView == levelTableView && indexPath.row == presenter.getLevelItemCount() - 1 {
            return cellHeight + extraPadding
        }
        return cellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == summitTypeTableView {
            count = presenter.getSummitTypeItemCount()
            summitTypeHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        else if tableView == trackGroupTableView {
            count = presenter.getTrackGroupItemCount();
            trackGroupHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        else if tableView == eventTypeTableView {
            count = presenter.getEventTypeItemCount();
            eventTypeHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        else if tableView == levelTableView {
            count = presenter.getLevelItemCount();
            levelHeightConstraint.constant = cellHeight * CGFloat(count) + extraPadding * 2
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GeneralScheduleFilterTableViewCell

        if tableView == summitTypeTableView {
            presenter.buildSummitTypeFilterCell(cell, index: indexPath.row)
        }
        else if tableView == trackGroupTableView {
            presenter.buildTrackGroupFilterCell(cell, index: indexPath.row)
        }
        else if tableView == eventTypeTableView {
            presenter.buildEventTypeFilterCell(cell, index: indexPath.row)
        }
        else if tableView == levelTableView {
            presenter.buildLevelFilterCell(cell, index: indexPath.row)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GeneralScheduleFilterTableViewCell
        
        if tableView == summitTypeTableView {
            presenter.toggleSelectionSummitType(cell, index: indexPath.row)
        }
        else if tableView == trackGroupTableView {
            presenter.toggleSelectionTrackGroup(cell, index: indexPath.row)
        }
        else if tableView == eventTypeTableView {
            presenter.toggleSelectionEventType(cell, index: indexPath.row)
        }
        else if tableView == levelTableView {
            presenter.toggleSelectionLevel(cell, index: indexPath.row)
        }
    }
    
    // MARK: - MLPAutoCompleteTextFieldDataSource
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!) -> [AnyObject]!  {
        //return presenter.getTagsBySearchTerm(string)
        
        guard searchTerm.isEmpty == false else { return [] }
        
        let tags = Tag.by(searchTerm: string)
        
        return Array(
            Set(entities.map { $0.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }) // unique values trimming tags
            ).sort()
    }
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, didSelectAutoCompleteString selectedString: String!, withAutoCompleteObject selectedObject: MLPAutoCompletionObject!, forRowAtIndexPath indexPath: NSIndexPath!) {

        if presenter.addTag(selectedString) {
            tagListView.addTag(selectedString)
            tagTextView.text = ""
            resizeTagList(tagListView.contentSize.height)
        }
    }
}
