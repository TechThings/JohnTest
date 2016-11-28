//
//  MultipleOutletsOfferView.swift
//  FAVE
//
//  Created by Syahmi Ismail on 19/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class MultipleOutletsOfferView: View {

    // MARK:- ViewModel
    var viewModel: MultipleOutletsOfferViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var offerNameLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var totalOutletLabel: UILabel!

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

        offerImageView.layer.cornerRadius = 2
        ratingView.layer.cornerRadius = 2
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(literal.MultipleOutletsOfferView, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func setup() {

    }
}

// MARK:- ViewModelBinldable
extension MultipleOutletsOfferView: ViewModelBindable {
    func bind() {
        viewModel
            .offerImage
            .driveNext { [weak self] (url: NSURL?) in
                guard let url = url else {self?.offerImageView.image = UIImage(named: "image-placeholder"); return}

                self?.offerImageView.kf_setImageWithURL(
                    url
                    , placeholderImage: UIImage(named: "image-placeholder")
                    , optionsInfo: [.Transition(ImageTransition.Fade(0.5))]
                )
            }.addDisposableTo(disposeBag)

        viewModel.offerName.drive(offerNameLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.ratingString.drive(ratingLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.totalOutlet.drive(totalOutletLabel.rx_text).addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension MultipleOutletsOfferView: Refreshable {
    func refresh() {
    }
}
