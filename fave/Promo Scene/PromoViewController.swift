//
//  PromoViewController.swift
//  KFIT
//
//  Created by Nazih Shoura on 08/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

final class PromoViewController: ViewController {

    // MARK: ViewModel
    var viewModel: PromoViewModel!

    // MARK: @IBOutlet Private
    @IBOutlet weak private var promosTableView: UITableView!

    // MARK: @IBOutlet Private
    @IBOutlet weak private var noActivePromosView: NoActivePromosView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        endEditingWhenTapOnBackground(true)
        self.title = NSLocalizedString("more_promo_code_title_text", comment: "")
        bind()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PROMOTION)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setupUI() {
        promosTableView.delegate = self
        promosTableView.dataSource = self

        promosTableView.registerNib(UINib(nibName:String(PromoHeaderTableViewCell), bundle: nil), forCellReuseIdentifier: String(PromoHeaderTableViewCell))
        promosTableView.registerNib(UINib(nibName:String(PromoTableViewCell), bundle: nil), forCellReuseIdentifier: String(PromoTableViewCell))
        promosTableView.registerNib(UINib(nibName:String(ActivePromoCountCell), bundle: nil), forCellReuseIdentifier: String(ActivePromoCountCell))

        promosTableView.rowHeight =  UITableViewAutomaticDimension
        promosTableView.estimatedRowHeight = 175

        promosTableView.tableFooterView = UIView(frame: CGRect.zero)
        promosTableView.tableFooterView?.backgroundColor = UIColor.clearColor()
    }

    func updateUI() {
        if viewModel.promos.value.count > 0 {
            noActivePromosView.hidden = true
            promosTableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        } else {
            noActivePromosView.hidden = false
            promosTableView.backgroundColor = UIColor.clearColor()
        }
        promosTableView.reloadData()
    }
}

extension PromoViewController: PromoHeaderTableViewCellDelegate {
    func promoDidApplyCode(code: String) {
        viewModel.addPromoCode(code)
    }
}

extension PromoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        // If there's no promos, we don't want to show the ActivePromoCountCell. Hence returning 0 instead of just promos.count + 1

        return viewModel.promos.value.count != 0 ? viewModel.promos.value.count + 1 : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(PromoHeaderTableViewCell), forIndexPath: indexPath) as! PromoHeaderTableViewCell
            cell.delegate = self
            return cell
        }

        if indexPath.row == 0 {
            let activePromoCountCell = tableView.dequeueReusableCellWithIdentifier(String(ActivePromoCountCell), forIndexPath: indexPath) as! ActivePromoCountCell
            activePromoCountCell.activePromoCountView.activePromoCount = viewModel.promos.value.count
            return activePromoCountCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(PromoTableViewCell), forIndexPath: indexPath) as! PromoTableViewCell
            let promo = viewModel.promos.value[indexPath.row - 1]
            let cellViewModel = PromoTableViewCellViewModel(promo: promo)
            cell.viewModel = cellViewModel
            cell.bind()
            //cell.delegate = self
            return cell
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

extension PromoViewController: ViewModelBindable {
    func bind() {
        viewModel.promos.asObservable().observeOn(MainScheduler.instance).subscribeNext { [weak self] _ in
            self?.updateUI()
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
    }
}

extension PromoViewController: Buildable {
    final class func build(builder: PromoViewModel) -> PromoViewController {
        let storyboard = UIStoryboard(name: "Promo", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(PromoViewController)) as! PromoViewController
        vc.viewModel = builder
        builder.refresh()
        return vc
    }
}

extension PromoViewController: DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> PromoViewController? {
        return build(PromoViewModel())
    }
}
