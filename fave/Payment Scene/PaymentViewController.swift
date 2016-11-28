//
//  PaymentViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PaymentViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: PaymentViewModel!
    var isEmptyPaymentHistory = false

    // MARK:- Variables
    var spinner: UIActivityIndicatorView!

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("more_payment_title_text", comment: "")
        setup()
        bind()
    }

    var  paymentAddCreditCardViewModel: PaymentAddCreditCardViewModel!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PAYMENTS)
        viewModel.setAsActive()
    }

    func setup() {
        registerTableCells()
        tableView.dataSource = self
        tableView.delegate = self
        configureSpinner()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func registerTableCells() {
        self.tableView.registerNib(UINib(nibName: String(PaymentAddCreditCardTableViewCell), bundle: nil), forCellReuseIdentifier: String(PaymentAddCreditCardTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(UserCreditsTableViewCell), bundle: nil), forCellReuseIdentifier: String(UserCreditsTableViewCell))
        self.tableView.registerNib(UINib(nibName: String(PaymentHistoryTableViewCell), bundle: nil), forCellReuseIdentifier: String(PaymentHistoryTableViewCell))
        self.tableView.registerNib(UINib(nibName: "PaymentHistoryEmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentHistoryEmptyTableViewCell")
    }

    private func configureSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.frame = CGRectMake(0, 0, tableView.frame.size.width, 50)
        tableView.tableFooterView = spinner

        networkActivityIndicator
            .drive(spinner.rx_animating)
            .addDisposableTo(disposeBag)
    }
}

extension PaymentViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if viewModel.settingsProvider.settings.value.appCompany == AppCompany.groupon {
                return 50
            }
            return 180
        } else if indexPath.section == 1 {
            return isEmptyPaymentHistory ? 100 : 85
        } else {
            return 0
        }
    }
}

extension PaymentViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 1} else if section == 1 {return isEmptyPaymentHistory ? 1 : viewModel.paymentHistory.value.count} else {return 0}
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(PaymentAddCreditCardTableViewCell), forIndexPath: indexPath) as! PaymentAddCreditCardTableViewCell
            let cellViewModel: PaymentAddCreditCardViewModel
            if (self.paymentAddCreditCardViewModel == nil) {
                cellViewModel = self.paymentAddCreditCardViewModel
            } else {
                cellViewModel = PaymentAddCreditCardViewModel (primaryPaymentMethod: viewModel.primaryPaymentMethod.value)
            }
            cellViewModel.delegate = self
            cell.viewModel = cellViewModel
            cell.bind()
            return cell
        } else if indexPath.section == 1 {
            if isEmptyPaymentHistory {
                let cell = tableView.dequeueReusableCellWithIdentifier("PaymentHistoryEmptyTableViewCell", forIndexPath: indexPath)
                return cell
            } else {
                let item = viewModel.paymentHistory.value[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier(String(PaymentHistoryTableViewCell), forIndexPath: indexPath) as! PaymentHistoryTableViewCell
                let cellViewModel = PaymentHistoryTableViewCellViewModel(paymentReceipt: item)
                cell.viewModel = cellViewModel
                cell.bind()
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
}

extension PaymentViewController: PaymentAddCreditCardViewModelDelegate {
    func presentPaymentViewController(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_ADD_CARD_DETAILS)
    }
}

// MARK:- ViewModelBinldable

extension PaymentViewController: ViewModelBindable {
    func bind() {

        viewModel
            .primaryPaymentMethod
            .asObservable()
            .subscribeNext { [weak self] (paymentMethod: PaymentMethod?) in
                self?.paymentAddCreditCardViewModel = PaymentAddCreditCardViewModel(primaryPaymentMethod: paymentMethod)
            }.addDisposableTo(disposeBag)

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

        self.viewModel.primaryPaymentMethod
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
            }.addDisposableTo(disposeBag)

        self.viewModel.paymentHistory
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.isEmptyPaymentHistory = $0.count == 0
                self?.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Build

extension PaymentViewController: Buildable {
    final class func build(builder: PaymentViewModel) -> PaymentViewController {
        let storyboard = UIStoryboard(name: "Payment", bundle: nil)
        let paymentViewController = storyboard.instantiateViewControllerWithIdentifier(String(PaymentViewController)) as! PaymentViewController
        paymentViewController.viewModel = builder
        builder.refresh()
        return paymentViewController
    }
}

extension PaymentViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> PaymentViewController? {
        return build(PaymentViewModel())
    }
}
