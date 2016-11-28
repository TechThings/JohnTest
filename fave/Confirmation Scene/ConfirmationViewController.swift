//
//  ConfirmationViewController.swift
//  fave
//
//  Created by Michael Cheah on 7/8/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import DeviceKit

final class ConfirmationViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reservationButtonDidTap: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var confirmationDetailsHeightConstaint: NSLayoutConstraint!
    @IBOutlet var cvcView: UIView!
    var cvcContainerView: UIView?
    @IBOutlet var cvcTextField: UITextField!
    @IBOutlet var cvcCardDescription: UILabel!
    // MARK:- IBAction

    @IBAction func reservationButtonDidTap(sender: AnyObject) {
        viewModel.reservationButtonDidTap.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: ConfirmationViewModel!

    // MARK:- Input

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setAsActive()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PHONE_VERIFICATION_ENTER_NUMBER)

        topView.backgroundColor = UIColor.whiteColor()
        topView.layer.shadowColor = UIColor.blackColor().CGColor
        topView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        topView.layer.shadowOpacity = 0.25
        topView.layer.shadowRadius = 0
        topView.layer.shadowPath = UIBezierPath(rect:topView.bounds).CGPath
        topView.layer.shouldRasterize = true
        topView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setup() {
        registerTableCells()
    }

    func registerTableCells() {
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationPromoEmptyTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationPromoEmptyTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationPromoTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationPromoTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationFinalPriceTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationFinalPriceTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationTitleTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationTitleTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationPriceTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationPriceTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationDetailsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationDetailsTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationTimeTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationTimeTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationQuantityTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationQuantityTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.ConfirmationCreditTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ConfirmationCreditTableViewCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 40,right: 0)
    }

    @IBAction func didSelectExit(sender: AnyObject) {
        let analyticsModel = ConfirmationViewAnalyticsModel(listing: viewModel.listingDetails.value)
        analyticsModel.closeClicked.sendToMoEngage()

        viewModel
        .lightHouseService
        .navigate
        .onNext { (viewController) in
            viewController.dismissViewControllerAnimated(true, completion: nil)
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func showCVCView(payment: PaymentMethod) {
        self.cvcContainerView = UIView(frame: self.view.bounds)
        self.cvcContainerView?.backgroundColor = UIColor.blackColor().alpha(0.3) // GG swift

        self.cvcTextField.delegate = self

        // center the dialog 
        self.cvcView.frame = CGRectMake(self.view.frame.width / 2 - self.cvcView.frame.width / 2, 170, self.cvcView.frame.width, self.cvcView.frame.height)

        self.cvcContainerView!.addSubview(self.cvcView)
        self.view.addSubview(self.cvcContainerView!) // this force unwrap
        // since we're in the CVC part, then the kind is definitely not nil, it's only nil in paypal case, and that will never get us here.

        var paymentKind = ""
        if let kind = payment.kind { paymentKind = " \(kind)," }

        self.cvcCardDescription.text = "Enter the CVC for \(paymentKind) •••• \(payment.identifier)"
        self.cvcTextField.becomeFirstResponder()

        self.viewModel.cvc.value = nil
    }

    private func hideCVCView() {
        self.cvcView.removeFromSuperview()
        self.cvcContainerView?.removeFromSuperview()
        self.cvcContainerView = nil

    }

    @IBAction func cvcConfirmButtonPressed(sender: AnyObject) {
        self.viewModel.cvc.value = self.cvcTextField.text

        self.hideCVCView()
    }

    @IBAction func cvcCancelButtonPressed(sender: AnyObject) {

        self.viewModel.cvc.value = nil

        self.hideCVCView()
    }
}

extension ConfirmationViewController: UITextFieldDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count
        return numberOfChars <= 4
    }
}

extension ConfirmationViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let model = viewModel.confirmationItems[indexPath.row]
        return model.cellHeight
    }
}

extension ConfirmationViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.confirmationItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = viewModel.confirmationItems[indexPath.row]

        switch model {
        case .Title:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationTitleTableViewCell, forIndexPath: indexPath) as! ConfirmationTitleTableViewCell
            let cellViewModel = ConfirmationTitleViewModel(listing: viewModel.listingDetails.value, classSession: viewModel.classSession)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case .Quantity:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationQuantityTableViewCell, forIndexPath: indexPath) as! ConfirmationQuantityTableViewCell
            let cellViewModel = ConfirmationQuantityViewModel(currentSlot: viewModel.currentSlot, maxQuantity: viewModel.maxQuantity)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case .Credit:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationCreditTableViewCell, forIndexPath: indexPath) as! ConfirmationCreditTableViewCell
            let cellViewModel = ConfirmationCreditViewModel(listing: viewModel.listingDetails.value, currentSlot: viewModel.currentSlot)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case .Price:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationPriceTableViewCell, forIndexPath: indexPath) as! ConfirmationPriceTableViewCell
            let cellViewModel = ConfirmationPriceViewModel(listing: viewModel.listingDetails.value, currentSlot: viewModel.currentSlot)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case .Promo:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationPromoTableViewCell, forIndexPath: indexPath) as! ConfirmationPromoTableViewCell
            let cellViewModel = ConfirmationPromoViewModel(listing: viewModel.listingDetails.value, currentSlot: viewModel.currentSlot)
            cellViewModel.delegate = self
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case .PromoEmpty:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationPromoEmptyTableViewCell, forIndexPath: indexPath) as! ConfirmationPromoEmptyTableViewCell
            let cellViewModel = ConfirmationPromoViewModel(listing: viewModel.listingDetails.value, currentSlot: viewModel.currentSlot)
            cellViewModel.delegate = self
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case .FinalPrice:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ConfirmationFinalPriceTableViewCell, forIndexPath: indexPath) as! ConfirmationFinalPriceTableViewCell
            let cellViewModel = ConfirmationFinalPriceViewModel(listing: viewModel.listingDetails.value, currentSlot: viewModel.currentSlot)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell
        }
    }
}

// MARK:- ViewModelBinldable

extension ConfirmationViewController: ViewModelBindable {
    func bind() {
        self.tableView.reloadData()

        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure) in
                if let strongSelf = self {
                    navigationClosure(viewController: strongSelf)
                }
            }.addDisposableTo(disposeBag)

        var tableViewHeightAdjustment = CGFloat()
        // CC Need Smaller Table View in 4S
        let device = Device()
        if viewModel.confirmationItems.count > 5 && (device == .iPhone4s || device == .iPhone4
            || device == .Simulator(.iPhone4s) || device == .Simulator(.iPhone4)) {
            tableViewHeightAdjustment += 100
        }

        confirmationDetailsHeightConstaint.constant -= tableViewHeightAdjustment

        viewModel
            .listingDetails
            .asDriver()
            .driveNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable

extension ConfirmationViewController: ConfirmationPromoDidChangePromoCode {
    func confirmationPromoDidChangePromoCode() {
        viewModel.refresh()
    }
}

extension ConfirmationViewController: Buildable {
    final class func build(builder: ConfirmationViewModel) -> ConfirmationViewController {
        let storyboard = UIStoryboard(name: "Confirmation", bundle: nil)
        let confirmationViewController = storyboard.instantiateViewControllerWithIdentifier(literal.ConfirmationViewController) as! ConfirmationViewController
        confirmationViewController.viewModel = builder
        return confirmationViewController
    }
}

enum ConfirmationViewControllerError: DescribableError {
    case PaymentFailed

    var description: String {
        switch self {
        case .PaymentFailed:
            return "Payment Failed"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .PaymentFailed:
            return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }
}
