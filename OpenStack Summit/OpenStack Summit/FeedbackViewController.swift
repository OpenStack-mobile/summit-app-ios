//
//  FeedbackViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 3/29/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Foundation
import CoreSummit
import Cosmos
import JGProgressHUD

final class FeedbackViewController: UIViewController, MessageEnabledViewController, ActivityViewController, UITextViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var titleLabel: UILabel!
    
    @IBOutlet private(set) weak var ratingView: CosmosView!
    
    @IBOutlet private(set) weak var reviewTextView: UITextView!
    
    @IBOutlet private(set) weak var sendButton: Button!
    
    @IBOutlet private(set) weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var completion: ((FeedbackViewController) -> ())?
    
    var event: Identifier = 0 {
        
         didSet { if isViewLoaded { configureView() } }
    }
    
    private var mode: Mode = .new
    
    private let placeHolderText = "Write a Review..."
    
    private let minimumBottomSpace: CGFloat = 100
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    // MARK: - Loading
    
    deinit {
        
        if isViewLoaded {
            
            unregisterKeyboardNotifications()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ratingView.rating = 0
        
        configureView()
        
        registerKeyboardNotifications()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        return [.portrait]
    }
    
    // MARK: - Actions
    
    @IBAction func close(_ sender: AnyObject? = nil) {
        
        completion?(self)
    }
    
    @IBAction func send(_ sender: AnyObject? = nil) {
        
        guard Reachability.connected
            else { showErrorMessage(AppError.reachability); return }
        
        // get new values
        
        let rate = Int(ratingView.rating)
        
        let review = reviewTextView.text != placeHolderText ? reviewTextView.text : ""
        
        // validate
        
        let validationErrorText: String?
        if rate == 0 {
            validationErrorText = "You must provide a rate using stars at the top"
        }
        else if (review?.characters.count)! > 500 {
            validationErrorText = "Review exceeded 500 characters limit"
        }
        else {
            validationErrorText = nil
        }
        
        if let errorMessage = validationErrorText {
            
            let error = NSError(domain: errorMessage, code: 7001, userInfo: nil)
            showErrorMessage(error)
            return
        }
        
        guard let _ = Store.shared.authenticatedMember
            else { return } // FIXME: handle user not logged in?
        
        // send request
        
        showActivityIndicator()
        
        let summit = SummitManager.shared.summit.value
                
        switch mode {
            
        case .new:
            
            Store.shared.addFeedback(summit, event: event, rate: rate, review: review!) { [weak self] (response) in
                
                OperationQueue.main.addOperation {
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    switch response {
                        
                    case let .error(error):
                        
                        controller.showErrorMessage(error)
                        
                    case .value:
                        
                        controller.close()
                    }
                }
            }
            
        case .edit:
            
            Store.shared.editFeedback(summit, event: event, rate: rate, review: review!)  { [weak self] (error) in
                
                OperationQueue.main.addOperation {
                    
                    guard let controller = self else { return }
                    
                    controller.dismissActivityIndicator()
                    
                    switch error {
                        
                    case let .some(error):
                        
                        controller.showErrorMessage(error)
                        
                    case .none:
                        
                        controller.close()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        if let feedbackManagedObject = Store.shared.authenticatedMember?.feedback(for: self.event) {
            
            mode = .edit
            
            let feedback = Feedback(managedObject: feedbackManagedObject)
            
            let event = Event(managedObject: feedbackManagedObject.event)
            
            configureView(with: event, feedback: feedback)
            
        } else {
            
            mode = .new
            
            guard let eventManagedObject = try! EventManagedObject.find(self.event, context: Store.shared.managedObjectContext)
                else { fatalError("Invalid event \(self.event)") }
            
            let event = Event(managedObject: eventManagedObject)
            
            configureView(with: event)
        }
    }
    
    private func configureView(with event: Event, feedback: Feedback? = nil) {
        
        self.titleLabel.text = event.name
        
        self.ratingView.rating = Double(feedback?.rate ?? 0)
        
        self.reviewTextView.text = feedback?.review ?? placeHolderText
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        reviewTextView.textColor = UIColor.black
        
        if reviewTextView.text == placeHolderText  {
            reviewTextView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if reviewTextView.text == "" {
            reviewTextView.text = placeHolderText
            reviewTextView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 1 {
            if let _ = text.rangeOfCharacter(from: .newlines, options: .backwards) {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
    
    // MARK: - Notifications
    
    @objc private func registerKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardDidShow),
                                                         name: NSNotification.Name.UIKeyboardDidShow,
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardWillHide),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
    }
    
    @objc private func unregisterKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardDidShow(_ notification: Foundation.Notification) {
        
        let userInfo: [String: AnyObject] = notification.userInfo as! [String : AnyObject]
        var keyboardRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardRect = view.convert(keyboardRect, from: nil)
        
        let visibleHeight = self.view.frame.size.height - keyboardRect.size.height
        bottomViewHeightConstraint.constant = visibleHeight
        view.updateConstraints()
    }
    
    @objc private func keyboardWillHide(_ notification: Foundation.Notification) {
        
        bottomViewHeightConstraint.constant = minimumBottomSpace
        view.updateConstraints()
    }
}

// MARK: - Supporting Files

extension FeedbackViewController {
    
    enum Mode {
        
        case new
        case edit
    }
}
