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

@objc
public protocol IGeneralScheduleFilterViewController {
    var presenter: IGeneralScheduleFilterPresenter! { get set }
    var navigationController: UINavigationController? { get }
    var tags: NSMutableArray! { get }
    func reloadFilters()
    func addTag(tag: String)
    func removeAllTags()
}

class GeneralScheduleFilterViewController: UIViewController, IGeneralScheduleFilterViewController, UITableViewDelegate, UITableViewDataSource, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource {
    var presenter : IGeneralScheduleFilterPresenter!
    
    var tags: NSMutableArray {
        get {
            return tagListView.tags
        }
    }
    
    var cellIdentifier = "generalScheduleFilterTableViewCell"
    @IBOutlet weak var filterTable: UITableView!
    @IBOutlet weak var summitTypeTableView: UITableView!
    @IBOutlet weak var eventTypeTableView: UITableView!
    @IBOutlet weak var summitTypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagTextView: MLPAutoCompleteTextField!
    @IBOutlet weak var tagListView: AMTagListView!
    @IBOutlet weak var clearTagsButton: UIButton!
    @IBOutlet weak var tagListViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelTableView: UITableView!
    @IBOutlet weak var levelHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        summitTypeTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        eventTypeTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        levelTableView.registerNib(UINib(nibName: "GeneralScheduleFilterTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        clearTagsButton.layer.cornerRadius = 10
        tagListView.delegate = self
        AMTagView.appearance().tagColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        AMTagView.appearance().innerTagColor = UIColor(red: 53/255, green: 84/255, blue: 121/255, alpha: 1.0)
        tagTextView.autoCompleteDelegate = self
        tagTextView.autoCompleteDataSource = self
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
    
    func reloadFilters() {
        summitTypeTableView.delegate = self
        summitTypeTableView.dataSource = self
        summitTypeTableView.reloadData()
        eventTypeTableView.delegate = self
        eventTypeTableView.dataSource = self
        eventTypeTableView.reloadData()
        levelTableView.delegate = self
        levelTableView.dataSource = self
        levelTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == summitTypeTableView {
            count = presenter.getSummitTypeItemCount()
            summitTypeHeightConstraint.constant = CGFloat(45 * count)
        }
        else if tableView == eventTypeTableView {
            count = presenter.getEventTypeItemCount();
            eventTypeHeightConstraint.constant = CGFloat(45 * count)
        }
        else  if tableView == levelTableView {
            count = presenter.getLevelItemCount();
            levelHeightConstraint.constant = CGFloat(45 * count)
        }
        tableView.updateConstraints()
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GeneralScheduleFilterTableViewCell

        if tableView == summitTypeTableView {
            presenter.buildSummitTypeFilterCell(cell, index: indexPath.row)
        }
        else if tableView == eventTypeTableView {
            presenter.buildEventTypeFilterCell(cell, index: indexPath.row)
        }
        else if tableView == levelTableView {
            presenter.buildLevelFilterCell(cell, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GeneralScheduleFilterTableViewCell
        
        if tableView == summitTypeTableView {
            presenter.toggleSelectionSummitType(cell, index: indexPath.row)
        }
        else if tableView == eventTypeTableView {
            presenter.toggleSelectionEventType(cell, index: indexPath.row)
        }
        else if tableView == levelTableView {
            presenter.toggleSelectionLevel(cell, index: indexPath.row)
        }
    }
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, possibleCompletionsForString string: String!) -> [AnyObject]!  {
        return presenter.getTagsBySearchTerm(string)
    }
    
    func autoCompleteTextField(textField: MLPAutoCompleteTextField!, didSelectAutoCompleteString selectedString: String!, withAutoCompleteObject selectedObject: MLPAutoCompletionObject!, forRowAtIndexPath indexPath: NSIndexPath!) {

        if presenter.addTag(selectedString) {
            tagListView.addTag(selectedString)
            tagTextView.text = ""
            resizeTagList(tagListView.contentSize.height)
        }
    }
    
    func addTag(tag: String) {
        tagListView.addTag(tag)
        resizeTagList(tagListView.contentSize.height)
    }
    
    func removeTag(notification: NSNotification) {
        let tagView = notification.object as! AMTagView
        presenter.removeTag(tagView.tagText!)
        tagListView.removeTag(tagView)
        resizeTagList(tagListView.contentSize.height)
    }
    
    func removeAllTags() {
        tagListView.removeAllTags()
    }
    
    @IBAction func willClearAllTags(sender: AnyObject) {
        presenter.removeAllTags();
        tagListView.removeAllTags()
        resizeTagList(tagListView.contentSize.height)
        tagTextView.text = ""
    }
    
    func resizeTagList(height: CGFloat) {
        tagListViewHeightConstraint.constant = height
        tagListView.updateConstraints()
    }
}
