//
//  AddPaymentMethodViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddPaymentMethodViewController: ViewController {

    // MARK:- IBOutlet    
    @IBOutlet weak var addPaymentMethodTableView: AddPaymentMethodTableView! {
        didSet { addPaymentMethodTableView.viewModel = AddPaymentMethodTableViewModel(resultSubject: viewModel.resultSubject, adyenPayment: viewModel.adyenPayment) }
    }
    // MARK:- ViewModel
    var viewModel: AddPaymentMethodViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }

    func setup() {

        self.title = NSLocalizedString("receipt_detail_payment_method_text", comment: "")

        self.navigationItem.leftBarButtonItem = BlockBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, actionHandler: { [weak self] _ in
            self?.viewModel.cancelButtonDidTap.onNext(())
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

// MARK:- ViewModelBinldable
extension AddPaymentMethodViewController: ViewModelBindable {
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
extension AddPaymentMethodViewController: Buildable {
    final class func build(builder: AddPaymentMethodViewControllerViewModel) -> AddPaymentMethodViewController {
        let storyboard = UIStoryboard(name: "AddPaymentMethod", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.AddPaymentMethodViewController) as! AddPaymentMethodViewController
        vc.viewModel = builder
        return vc
    }
}
