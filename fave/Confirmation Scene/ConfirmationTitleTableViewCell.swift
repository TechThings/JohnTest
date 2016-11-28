//
//  ReservationActionTitleTableViewCell.swift
//  KFIT
//
//  Created by Kevin Mun on 19/03/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ConfirmationTitleTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: ConfirmationTitleViewModel!

    @IBOutlet weak var promiseView: UIView!
    @IBOutlet weak var multipleOutletView: UIView!
    // MARK:- IBOutlets
    @IBOutlet weak var activityTitle: KFITLabel!
    @IBOutlet weak var companyTitle: UILabel!
    @IBOutlet weak var cancellationLabel: KFITLabel!
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var outletTitle: KFITLabel!
    @IBOutlet weak var redeemTimeLabel: UILabel!
    @IBOutlet weak var redeemTimeTitleLabel: UILabel!
    @IBOutlet weak var multipleOutletLabel: KFITLabel!
    @IBOutlet weak var viewAllMultipleOutletsButton: UIButton!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()

        self.activityTitle.lineSpacing = 2.3
        self.activityTitle.textAlignment = .Left
        self.cancellationLabel.lineSpacing = 2.3
        self.cancellationLabel.textAlignment = .Left
        // Initialization code
    }

    @IBAction func didTapViewAllMultipleOutletsButton(sender: AnyObject) {
        viewModel.didTapViewAllMultipleOutletsButton.onNext()
    }
}

// MARK:- ViewModelBinldable

extension ConfirmationTitleTableViewCell: ViewModelBindable {
    func bind() {

        viewModel.featuredImage.driveNext { [weak self](url: NSURL?) in
            if let url = url {
                self?.activityImage.kf_setImageWithURL(
                    url,
                    placeholderImage: UIImage(named: "image-placeholder"),
                    progressBlock: nil,
                    completionHandler: nil)
            } else {
                self?.activityImage.image = UIImage(named: "image-placeholder")
            }
        }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.activityName.drive(activityTitle.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.companyName.drive(companyTitle.rx_text).addDisposableTo(rx_reusableDisposeBag)

        viewModel.cancellationPolicy.drive(cancellationLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.outletName.drive(outletTitle.rx_text).addDisposableTo(rx_reusableDisposeBag)

        outletTitle.lineSpacing = 2.2
        outletTitle.textAlignment = .Left

        viewModel.redeemTime.drive(redeemTimeLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.redeemTimeTitle.drive(redeemTimeTitleLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)

        viewModel.favePromiseHidden.drive(promiseView.rx_hidden).addDisposableTo(rx_reusableDisposeBag)

        viewModel.multipleOutletsTitle.drive(multipleOutletLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.multipleOutletsHidden.drive(multipleOutletView.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
        viewModel.multipleOutletsHidden.driveNext {[weak self] (hidden: Bool) in
            self?.outletTitle.hidden = !hidden
        }.addDisposableTo(rx_reusableDisposeBag)
        viewModel.multipleOutletsHidden.drive(viewAllMultipleOutletsButton.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
    }
}
