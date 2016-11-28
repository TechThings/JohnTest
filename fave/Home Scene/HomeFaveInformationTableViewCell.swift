//
//  HomeFaveInformationTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 9/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeFaveInformationTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: HomeFaveInformationTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var stagingMode: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTapChangeButton(sender: AnyObject) {
        viewModel.goToOnBoarding()
    }

}

extension HomeFaveInformationTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.version.asDriver().drive(version.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.stagingMode.asDriver().drive(stagingMode.rx_text).addDisposableTo(rx_reusableDisposeBag)
    }
}
