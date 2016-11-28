//
//  ContactsViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 09/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ContactsViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var contactsTableView: ContactsTableView!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var floatingView: UIView! {
        didSet {
            floatingView.alpha = 0
        }
    }

    // MARK:- ViewModel
    var viewModel: ContactsViewControllerViewModel!

    // MARK:- Constant

    @IBAction func doneButtonDidTap(sender: AnyObject) {
        viewModel.doneButtonDidTap.onNext(())
    }

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_SELECT_FRIENDS)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setup() {
        switch viewModel.functionality.value {
        case .AddChannelParticipants(_, _):
            self.contactsTableView.viewModel = ContactsTableViewModel(searchText: searchBar.rx_text, contactsTableViewModelModelFunctionality: ContactsTableViewModelModelFunctionality.AddChannelParticipants(chatParticipants: viewModel.chatParticipantsBeingConstucted, filterChatParticipants: viewModel.chatParticipantsBeingConstucted.value))
        case .InitiateChannel(_): fallthrough
        case .InitiateChat(_, _):
            self.contactsTableView.viewModel = ContactsTableViewModel(searchText: searchBar.rx_text, contactsTableViewModelModelFunctionality: ContactsTableViewModelModelFunctionality.SetChannelParticipants(chatParticipants: viewModel.chatParticipantsBeingConstucted))
        }

        let refreshBarButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self.contactsTableView, action: #selector(ContactsTableView.reset))
        self.navigationItem.rightBarButtonItem = refreshBarButton

        self.title = NSLocalizedString("select_friends", comment: "")
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.faveBackground()
        searchBar.layer.shadowColor = UIColor.blackColor().CGColor
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        searchBar.layer.shadowOpacity = 0.15
        searchBar.layer.shadowRadius = 1.25
        searchBar.layer.shadowPath = UIBezierPath(rect:searchBar.bounds).CGPath

        floatingView.layer.shadowColor = UIColor.blackColor().CGColor
        floatingView.layer.shadowOffset = CGSize(width: 0, height: -0.4)
        floatingView.layer.shadowOpacity = 0.15
        floatingView.layer.shadowRadius = 1.25
        floatingView.layer.shadowPath = UIBezierPath(rect:floatingView.bounds).CGPath

        contactsTableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 60,right: 0)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        buttonBottomConstraint.constant = keyboardRectangle.size.height
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        buttonBottomConstraint.constant = 0
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- ViewModelBinldable
extension ContactsViewController: ViewModelBindable {
    func bind() {

        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

        viewModel
            .doneButtonSettings
            .driveNext { (enabled: Bool, text: String) in
                UIView.animateWithDuration(0.2, animations: {
                    if enabled {
                        self.floatingView.transform = CGAffineTransformMakeTranslation(0, 0)
                        self.floatingView.alpha = 1
                    } else {
                        self.floatingView.transform = CGAffineTransformMakeTranslation(0, self.floatingView.frame.size.height)
                        self.floatingView.alpha = 0
                    }
                    self.doneButton.setTitle(text, forState: .Normal)
                })
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension ContactsViewController: Buildable {
    final class func build(builder: ContactsViewControllerViewModel) -> ContactsViewController {
        let storyboard = UIStoryboard(name: "Contacts", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.ContactsViewController) as! ContactsViewController
        vc.viewModel = builder
        return vc
    }
}
