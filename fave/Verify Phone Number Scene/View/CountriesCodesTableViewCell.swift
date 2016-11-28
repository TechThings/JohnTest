//
//  CountriesCodesTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 8/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CountriesCodesTableViewCell: TableViewCell {

    // MARK:- @IBOutlet

    var viewModel: CountriesCodesTableViewCellModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlets
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!

    // @IBAction
    @IBAction func selectCountryCodeButtonDidTap(sender: UIButton) {
        viewModel.selectCountryCodeButtonDidTap.onNext(())
    }

    // MARK:- Life cycle

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable

extension CountriesCodesTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .countryName
            .drive(countryNameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .countryCallingCode
            .drive(countryCodeLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
