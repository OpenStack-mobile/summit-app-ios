//
//  TabStripViewController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 12/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XLPagerTabStrip

class TabStripViewController: XLPagerTabStripViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var buttonBarView: XLButtonBarView!
    
    var shouldUpdateButtonBarView: Bool = true
    
    var changeCurrentIndexProgressiveBlock: ((oldCell: XLButtonBarViewCell!, newCell: XLButtonBarViewCell!, progressPercentage: CGFloat, indexWasChanged: Bool, fromCellRowAtIndex: Bool) -> Void)?
    var changeCurrentIndexBlock: ((oldCell: XLButtonBarViewCell!, newCell: XLButtonBarViewCell!, animated: Bool) -> Void)?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if buttonBarView == nil {
            let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            flowLayout.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35)
            buttonBarView = XLButtonBarView(frame: CGRectMake(0, 0, view.frame.size.width, 44.0), collectionViewLayout: flowLayout)
            buttonBarView.backgroundColor = UIColor.orangeColor()
            buttonBarView.selectedBar.backgroundColor = UIColor.blackColor()
            buttonBarView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        }
        
        if buttonBarView.superview == nil {
            view.addSubview(buttonBarView)
        }
        
        if buttonBarView.delegate == nil {
            buttonBarView.delegate = self
        }
        
        if buttonBarView.dataSource == nil {
            buttonBarView.dataSource = self
        }
        
        buttonBarView.labelFont = UIFont.boldSystemFontOfSize(18.0)
        buttonBarView.leftRightMargin = 8
        buttonBarView.scrollsToTop = false
        
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        buttonBarView.showsHorizontalScrollIndicator = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
        buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: XLPagerTabStripDirection.None, pagerScroll: (isProgressiveIndicator ? XLPagerScroll.YES : XLPagerScroll.OnlyIfOutOfScreen))
    }
    
    override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        
        if isViewLoaded() {
            buttonBarView.reloadData()
            buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: XLPagerTabStripDirection.None, pagerScroll: XLPagerScroll.YES)
        }
    }
    
    override func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
        
        if shouldUpdateButtonBarView {
            var direction = XLPagerTabStripDirection.Left
            if toIndex < fromIndex {
                direction = XLPagerTabStripDirection.Right
            }
            
            buttonBarView.moveToIndex(UInt(toIndex), animated: true, swipeDirection: direction, pagerScroll: XLPagerScroll.YES)
            
            if changeCurrentIndexBlock != nil {
                let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: Int(currentIndex) != fromIndex ? fromIndex : toIndex, inSection: 0)) as! XLButtonBarViewCell
                let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: Int(currentIndex), inSection: 0)) as! XLButtonBarViewCell
                changeCurrentIndexBlock!(oldCell: oldCell, newCell: newCell, animated: true)
            }
        }
        
    }
    
    override func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        
        if shouldUpdateButtonBarView {
            buttonBarView.moveFromIndex(fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, pagerScroll: XLPagerScroll.YES)
            
            if changeCurrentIndexProgressiveBlock != nil {
                let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: Int(currentIndex) != fromIndex ? fromIndex : toIndex, inSection: 0)) as! XLButtonBarViewCell
                let newCell: XLButtonBarViewCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: Int(currentIndex), inSection: 0)) as! XLButtonBarViewCell
                changeCurrentIndexProgressiveBlock!(oldCell: oldCell, newCell: newCell, progressPercentage: progressPercentage, indexWasChanged: indexWasChanged, fromCellRowAtIndex: true)
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = buttonBarView.labelFont
        
        let childController = pagerTabStripChildViewControllers[indexPath.item]
        if let _ = childController as? protocol<XLPagerTabStripChildItem> {
            label.text = childController.titleForPagerTabStripViewController(self)
        }
        let labelSize: CGSize = label.intrinsicContentSize()
        
        return CGSizeMake(labelSize.width + CGFloat(buttonBarView.leftRightMargin * 2), collectionView.frame.size.height)
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if UInt(indexPath.item) == currentIndex {
            return
        }
        
        buttonBarView.moveToIndex(UInt(indexPath.item), animated: true, swipeDirection: XLPagerTabStripDirection.None, pagerScroll: XLPagerScroll.OnlyIfOutOfScreen)
        
        shouldUpdateButtonBarView = false
        
        let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: Int(currentIndex), inSection: 0)) as! XLButtonBarViewCell
        let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: indexPath.item, inSection: 0)) as! XLButtonBarViewCell
        
        if isProgressiveIndicator {
            if changeCurrentIndexProgressiveBlock != nil {
                changeCurrentIndexProgressiveBlock!(oldCell: oldCell, newCell: newCell, progressPercentage: 1, indexWasChanged: true, fromCellRowAtIndex: true)
            }
        }
        else {
            if changeCurrentIndexBlock != nil {
                changeCurrentIndexBlock!(oldCell: oldCell, newCell: newCell, animated: true)
            }
        }
        
        moveToViewControllerAtIndex(UInt(indexPath.item))
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pagerTabStripChildViewControllers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! XLButtonBarViewCell
        
        //NSAssert(cell.isKindOfClass(XLButtonBarViewCell), "UICollectionViewCell should be or extend XLButtonBarViewCell")
        let buttonBarCell = cell
        
        let childController = pagerTabStripChildViewControllers[indexPath.item]
        if let _ = childController as? protocol<XLPagerTabStripChildItem> {
            buttonBarCell.label.text = childController.titleForPagerTabStripViewController(self)
        }
        
        if isProgressiveIndicator {
            if changeCurrentIndexProgressiveBlock != nil {
                changeCurrentIndexProgressiveBlock!(oldCell: currentIndex == UInt(indexPath.item) ? nil : cell, newCell: currentIndex == UInt(indexPath.item) ? cell : nil, progressPercentage: 1, indexWasChanged: true, fromCellRowAtIndex: false)
            }
        }
        else {
            if changeCurrentIndexBlock != nil {
                changeCurrentIndexBlock!(oldCell: currentIndex == UInt(indexPath.item) ? nil : cell, newCell: currentIndex == UInt(indexPath.item) ? cell : nil, animated: false)
            }
        }
        
        return buttonBarCell
        
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        if scrollView == containerView {
            shouldUpdateButtonBarView = true
        }
    }
}