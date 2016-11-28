//
//  OutletsGGMapsSearchCell.swift
//  FAVE
//
//  Created by Thanh KFit on 6/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import Kingfisher

protocol OutletGGMapsSearchCellDelegate {
    func didTapFaveButton(id: String)
}

final class OutletsGGMapsSearchCell: TableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var faveButton: UIButton!

    var delegate: OutletGGMapsSearchCellDelegate!
    var viewModel: OutletsGGMapsSearchCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func didTapFaveButton(sender: UIButton) {
        if sender.selected {
            sender.selected = false
            let image = UIImage(named: "ic_outlet_favourited_pink")
            faveButton.setImage(image, forState: UIControlState.Normal)
        } else {
            sender.selected = true
            let image = UIImage(named: "ic_outlet_favourited_fill")
            faveButton.setImage(image, forState: UIControlState.Normal)
            viewModel.addCrowdSourceOutlet()
        }
    }
}

extension OutletsGGMapsSearchCell : ViewModelBindable {
    func bind() {

        self.faveButton.selected = false

        viewModel.partnerName
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self](partnerName) in
                self!.partnerNameLabel.text = partnerName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.outletName
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self](outletName) in
                self!.outletNameLabel.text = outletName
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.profileImageURL
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self](url) in
                self!.profileImageView.kf_setImageWithURL(
                    url!,
                    placeholderImage: UIImage(named: "image-placeholder"),
                    optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
            }.addDisposableTo(rx_reusableDisposeBag)

    }
}
