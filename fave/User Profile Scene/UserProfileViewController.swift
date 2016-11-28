//
//  UserProfileViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RSKImageCropper

final class UserProfileViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePickerBottomConstraint: NSLayoutConstraint!

    // MARK:- ViewModel
    var viewModel: UserProfileViewControllerViewModel!
    var userProfileItem = [UserProfileItem]()

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("more_profile_title_text", comment: "")
        setup()
        bind()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setup() {
        registerTableCells()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.delegate = self
        tableView.dataSource = self
        overlayView.hidden = true
        overlayView.alpha = 0
    }

    func registerTableCells() {
        self.tableView.registerNib(UINib(nibName: String(UserDetailTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserDetailTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(UserProfileHeaderTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserProfileHeaderTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(UserGenderTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserGenderTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(UserBirthdayTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserBirthdayTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(UserHeaderSectionTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserHeaderSectionTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(UserSwitchTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserSwitchTableViewCell))
    }

    func logout() {
        viewModel.logout() // Clear Cache

        let vm = OnboardingViewModel()
        let vc = OnboardingViewController.build(vm)

        // Clean up Tab bar controller
        RootTabBarController.shareInstance!.removeFromParentViewController()
        RootTabBarController.shareInstance = nil

        let nvc = RootNavigationController.build(RootNavigationViewModel(setAsRoot: true))
        nvc.setViewControllers([vc], animated: true)
        self.view.window?.rootViewController = nvc
    }
}

extension UserProfileViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let model = userProfileItem[indexPath.row]

        switch model.itemType {
        case .Separator:
            return 20
        case .Header:
            return UITableViewAutomaticDimension
        default:
            return 50
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = userProfileItem[indexPath.row]

        switch model.itemType {
        case .Logout:
            logout()
            return
        default:
            // Do Nothing
            return
        }
    }
}

extension UserProfileViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userProfileItem.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = userProfileItem[indexPath.row]

        switch model.itemType {
        case .Header:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserProfileHeaderTableViewCell), forIndexPath: indexPath) as! UserProfileHeaderTableViewCell
            let cellViewModel = model.item as? UserProfileHeaderViewModel
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case .Detail:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserDetailTableViewCell), forIndexPath: indexPath) as! UserDetailTableViewCell
            let cellViewModel = model.item as? UserDetailViewModel
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case .Gender:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserGenderTableViewCell), forIndexPath: indexPath) as! UserGenderTableViewCell
            let cellViewModel = model.item as? UserGenderViewModel
            cell.detailsLabel.text = cellViewModel?.details
            cell.editButton.rx_tap.asObservable().subscribeNext({ [weak self] in
                self?.updateGender()
                }).addDisposableTo(disposeBag)
            return cell

        case .Birthday:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserBirthdayTableViewCell), forIndexPath: indexPath) as! UserBirthdayTableViewCell
            let cellViewModel = model.item as? UserBirthdayViewModel
            cell.detailsLabel.text = cellViewModel?.details
            cell.editButton.rx_tap.asObservable().subscribeNext({ [weak self] in
                self?.updateBirthday()
                }).addDisposableTo(disposeBag)
            return cell

        case .HeaderSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserHeaderSectionTableViewCell), forIndexPath: indexPath) as! UserHeaderSectionTableViewCell
            let cellViewModel = model.item as? String
            cell.titleLabel.text = cellViewModel
            return cell

        case .Purchases:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserSwitchTableViewCell), forIndexPath: indexPath) as! UserSwitchTableViewCell
            let cellViewModel = model.item as? UserSwitchViewModel
            cell.viewModel = cellViewModel
            cell.bind()
            cell.switchControl.rx_value.asObservable().skip(1).subscribeNext({ [weak self] in
                self?.updatePurchases($0)
                }).addDisposableTo(disposeBag)
            return cell

        case .Recommendations:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(UserSwitchTableViewCell), forIndexPath: indexPath) as! UserSwitchTableViewCell
            let cellViewModel = model.item as? UserSwitchViewModel
            cell.viewModel = cellViewModel
            cell.bind()
            cell.switchControl.rx_value.asObservable().skip(1).subscribeNext({ [weak self] in
                self?.updateRecommend($0)
                }).addDisposableTo(disposeBag)
            return cell

        case .Logout:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserProfileLogoutTableViewCell", forIndexPath: indexPath)
            return cell

        case .Separator:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserProfileSeparatorTableViewCell", forIndexPath: indexPath)
            return cell
        }
    }
}

// MARK:- ViewModelBinldable

extension UserProfileViewController: ViewModelBindable {
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

        viewModel.userProfileItems
            .driveNext {
                [weak self] (items) in
                self?.userProfileItem = items
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

extension UserProfileViewController {

    @IBAction func updateBirthdayDone(sender: AnyObject) {
        datePickerBottomConstraint.constant = -self.datePickerView.height
        overlayView.hidden = true
        UIView.animateWithDuration(0.2) {
            self.overlayView.alpha = 0
            self.view.layoutIfNeeded()
        }
        viewModel.updateBirthday(datePicker.date)
    }

    func updateBirthday() {
        overlayView.hidden = false
        datePickerBottomConstraint.constant = 0
        UIView.animateWithDuration(0.25) {
            self.overlayView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    func updateGender() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("profile_setting_gender_text", comment: ""), message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)

        settingsActionSheet.addAction(UIAlertAction(title:Gender.Male.rawValue, style:UIAlertActionStyle.Default, handler: { action in
            self.viewModel.updateGender(Gender.Male)
        }))
        settingsActionSheet.addAction(UIAlertAction(title:Gender.Female.rawValue, style:UIAlertActionStyle.Default, handler: { action in
            self.viewModel.updateGender(Gender.Female)
        }))
        //        settingsActionSheet.addAction(UIAlertAction(title:Gender.NotSpecify.rawValue, style:UIAlertActionStyle.Default, handler:{ action in
        //            self.viewModel.updateGender(Gender.NotSpecify)
        //        }))
        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("cancel", comment: ""), style:UIAlertActionStyle.Cancel, handler:nil))

        presentViewController(settingsActionSheet, animated:true, completion:nil)
    }

    func updatePurchases(value: Bool) {
        self.viewModel.updatePurchasesNotification(value)
    }

    func updateRecommend(value: Bool) {
        self.viewModel.updateRecommendNotification(value)
    }
}

// MARK:- Buildable

extension UserProfileViewController: Buildable {
    final class func build(builder: UserProfileViewControllerViewModel) -> UserProfileViewController {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(UserProfileViewController)) as! UserProfileViewController
        let vcvm = UserProfileViewControllerViewModel()
        vc.viewModel = vcvm
        return vc
    }
}

extension UserProfileViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> UserProfileViewController? {
        return build(UserProfileViewControllerViewModel())
    }
}
