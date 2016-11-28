//
//  ListingCancellationTableViewCell.swift
//  FAVE
//
//  Created by Gaddafi Rusli on 17/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingCancellationTableViewCell: TableViewCell {
    @IBOutlet weak var cancellationView: UIView!
    @IBOutlet weak var cancellationLabel: KFITLabel!
    @IBOutlet weak var listWrapView: UIView!
    @IBOutlet weak var promiseView: UIView!

    var viewModel: ListingCancellationTableViewCellViewModel!

    override func awakeFromNib() {
        listWrapView.layer.cornerRadius = 3
        cancellationLabel.lineSpacing = 2.3
        cancellationLabel.textAlignment = .Left
    }

}

extension ListingCancellationTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.cancellationPolicy.drive(cancellationLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)

        viewModel.hideCancelPolicy.drive(cancellationView.rx_hidden).addDisposableTo(rx_reusableDisposeBag)

        viewModel.hideFavePromise.drive(promiseView.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
    }
}
