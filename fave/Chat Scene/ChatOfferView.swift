//
//  ChatOfferView.swift
//  FAVE
//
//  Created by Michael Cheah on 8/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ChatOfferView: View {

    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var buyButton: Button!
    @IBOutlet weak var listingNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var offerDetailsStackView: UIStackView!
    @IBOutlet weak var partnerStackView: UIStackView!
    @IBOutlet weak var featuredImageWidthConstraint: NSLayoutConstraint!
    // MARK:- ViewModel
    var viewModel: ChatOfferViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(ChatOfferView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        bind()
        setup()
        super.updateConstraints()
    }

    private func setup() {

    }

    @IBAction func onBuyButtonTap(sender: AnyObject) {
        viewModel.onBuyButtonTap()
    }
}

// MARK:- ViewModelBinldable
extension ChatOfferView: ViewModelBindable {
    func bind() {
        if let featureImage = viewModel.featureImage {
            self.featuredImageView.kf_setImageWithURL(
                    featureImage,
                    placeholderImage: UIImage(named: "image-placeholder"),
                    optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
                    progressBlock: nil,
                    completionHandler: nil)
        } else {
            self.featuredImageView.image = UIImage(named: "image-placeholder")
        }

        self.listingNameLabel.text = viewModel.activityName
        self.finalPriceLabel.text = viewModel.finalPriceUserVisible

        if let originPrice = viewModel.originalPriceUserVisible {
            self.originalPriceLabel.text = originPrice
        } else {
            self.originalPriceLabel.hidden = true
        }

        self.companyNameLabel.text = viewModel.companyName
        self.outletNameLabel.text = viewModel.outletName
    }
}
