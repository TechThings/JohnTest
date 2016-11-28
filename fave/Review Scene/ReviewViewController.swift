//
//  ReviewViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ReviewViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: ReviewTableView!

    // MARK:- ViewModel
    var viewModel: ReviewViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()

        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    deinit {
    }

    func setup() {
        let tableViewModel = ReviewTableViewModel(companyId: viewModel.companyId)
        tableViewModel.refresh()
        tableView.viewModel = tableViewModel

        self.title = NSLocalizedString("activity_detail_reviews_text", comment: "")
    }
}

// MARK:- ViewModelBinldable
extension ReviewViewController: ViewModelBindable {
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

    }
}

// MARK:- Buildable
extension ReviewViewController: Buildable {
    final class func build(builder: ReviewViewControllerViewModel) -> ReviewViewController {
        let storyboard = UIStoryboard(name: "Review", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.ReviewViewController) as! ReviewViewController
        vc.viewModel = builder
        return vc
    }
}
