//
//  ListingsGroupedOutletTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 10/28/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsGroupedOutletTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ListingsGroupedOutletTableViewCellViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!

    @IBOutlet weak var faveCountLabel: UILabel!
    @IBOutlet weak var faveCountView: UIView!

    @IBOutlet weak var outletDistanceLabel: UILabel!
    @IBOutlet weak var outletDistanceView: UIView!

    @IBOutlet weak var faveButton: UIButton!

    let didTapCell = PublishSubject<()>()

    override func awakeFromNib() {
        super.awakeFromNib()

        ratingView.layer.cornerRadius = 3
    }

    @IBAction func didTapFaveButton(sender: AnyObject) {
        if viewModel.favoritedId.value > 0 {
            let image = UIImage(named: "ic_outlet_favourited_pink")
            faveButton.setImage(image, forState: UIControlState.Normal)
            viewModel.deleteFavoriteOutlet()
        } else {
            let image = UIImage(named: "ic_outlet_favourited_fill")
            faveButton.setImage(image, forState: UIControlState.Normal)
            viewModel.didTapAddFavoriteOutlet()
        }
    }

}

extension ListingsGroupedOutletTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .partnerName
            .drive(partnerNameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outletName
            .drive(outletNameLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outletDistance
            .drive(outletDistanceLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .ratingText
            .drive(ratingLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .ratingHidden
            .drive(ratingView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .favoritedCountText
            .drive(faveCountLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .favoritedCountHidden
            .drive(faveCountView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outletDistanceHidden
            .drive(outletDistanceView.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel.favoritedId
            .asDriver()
            .driveNext({ [weak self] (favoriteId: Int) in
                var image: UIImage

                if favoriteId > 0 {
                    image = UIImage(named: "ic_outlet_favourited_fill")!
                } else {
                    image = UIImage(named: "ic_outlet_favourited_pink")!
                }

                self?.faveButton.setImage(image, forState: UIControlState.Normal)
                })
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
