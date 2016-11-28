//
//  CountriesCodesViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/31/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CountriesCodesViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var countriesCodesTableView: CountriesCodesTableView!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK:- ViewModel
    var viewModel: CountriesCodesViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    private func setup() {
        let countriesCodesTableViewModel = CountriesCodesTableViewModel(searchText: searchBar.rx_text, selectedCountryCode: viewModel.selectedCountryCode)
        countriesCodesTableView.viewModel = countriesCodesTableViewModel
    }

    @IBAction func doneButtonDidTap(sender: AnyObject) {
        viewModel.doneButtonDidTap.onNext(())
    }
}

// MARK:- ViewModelBinldable
extension CountriesCodesViewController: ViewModelBindable {
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
extension CountriesCodesViewController: Buildable {
    final class func build(builder: CountriesCodesViewControllerViewModel) -> CountriesCodesViewController {
        let storyboard = UIStoryboard(name: "CountriesCodes", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.CountriesCodesViewController) as! CountriesCodesViewController
        vc.viewModel = builder
        return vc
    }
}
