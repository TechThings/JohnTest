//
//  HomeListingView.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeListingView: View {

    // MARK:- ViewModel
    var viewModel: HomeListingViewViewModel! {
        didSet {
            bind()
        }
    }

    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalOutletLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var officialPriceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var faveRatingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var faveRatingView: UIView!
    @IBOutlet weak var faveDistanceView: UIView!
    //    @IBOutlet weak var distanceWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var companyLabel: UILabel!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        originalPriceLabel.strikeThrough = true
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func prepareForReuse() {
        faveRatingView.hidden = false
    }

    func setup() {
        self.favouriteButton
            .rx_tap
            .asObservable()
            .subscribeNext { [weak self] in
                if let strongSelf = self {
                    strongSelf.tappedFaveButton(strongSelf.favouriteButton)
                }
            }.addDisposableTo(disposeBag)
        faveRatingView.layer.cornerRadius = 2
        faveDistanceView.layer.cornerRadius = 2
    }

    func tappedFaveButton(sender: UIButton) {
        if viewModel.favoritedId.value > 0 {
            let image = UIImage(named: "ic_outlet_favourited_white")
            favouriteButton.setImage(image, forState: UIControlState.Normal)
            viewModel.didTapDeleteFavoriteOutlet()
        } else {
            let image = UIImage(named: "ic_outlet_favourited_fill")
            favouriteButton.setImage(image, forState: UIControlState.Normal)
            viewModel.didTapAddFavoriteOutlet()
        }
    }
}

// MARK:- ViewModelBinldable
extension HomeListingView: ViewModelBindable {
    func bind() {
        viewModel.distanceHidden.drive(faveDistanceView.rx_hidden).addDisposableTo(disposeBag)

        viewModel
            .favoritedButtonImage
            .asDriver()
            .driveNext { [weak self](image) in
                self?.favouriteButton.setImage(image, forState: .Normal)
            }.addDisposableTo(disposeBag)

        viewModel.activityName.drive(titleLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.companyName.drive(companyLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.totalOutlet.drive(totalOutletLabel.rx_text).addDisposableTo(disposeBag)

        viewModel
            .averageRating
            .drive(faveRatingLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .averageRatingViewHidden
            .drive(faveRatingView.rx_hidden)
            .addDisposableTo(disposeBag)

        viewModel
            .distance
            .drive(distanceLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .originalPrice
            .drive(originalPriceLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .officialPrice
            .drive(officialPriceLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.activityImage
            .asDriver()
            .driveNext({ [weak self] (url) in
                if let url = url {
                    self?.contentImage.kf_setImageWithURL(
                        url,
                        placeholderImage: UIImage(named: "image-placeholder"),
                        optionsInfo: [.Transition(ImageTransition.Fade(0.5))],
                        progressBlock: nil,
                        completionHandler: nil)
                } else {
                    self?.contentImage.image = UIImage(named: "image-placeholder")
                }
                }).addDisposableTo(disposeBag)

        viewModel.listenToFavoriteChange()
    }
}
