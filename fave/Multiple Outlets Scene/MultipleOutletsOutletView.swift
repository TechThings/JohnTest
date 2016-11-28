//
//  MultipleOutletsOutletView.swift
//  FAVE
//
//  Created by Syahmi Ismail on 19/10/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class MultipleOutletsOutletView: View {

    // MARK:- ViewModel
    var viewModel: MultipleOutletsOutletViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var outletLocationLabel: KFITLabel!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var favesView: UIView!
    @IBOutlet weak var favesLabel: UILabel!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerLabel: UILabel!

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

        outletLocationLabel.lineSpacing = 2.3
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(literal.MultipleOutletsOutletView, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
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
        favesView.layer.cornerRadius = 2
        favesView.layer.cornerRadius = 2
    }

    func tappedFaveButton(sender: UIButton) {
        if viewModel.favoritedId.value > 0 {
            let image = UIImage(named: "ic_outlet_favourited_pink")
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
extension MultipleOutletsOutletView: ViewModelBindable {
    func bind() {
        viewModel.outletName.drive(outletNameLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.outletLocation.drive(outletLocationLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.favesString.drive(favesLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.favesHidden.drive(favesView.rx_hidden).addDisposableTo(disposeBag)
        viewModel.offerString.drive(offerLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.offerHidden.drive(offerView.rx_hidden).addDisposableTo(disposeBag)

        viewModel
            .favoritedButtonImage
            .asDriver()
            .driveNext { [weak self](image) in
                self?.favouriteButton.setImage(image, forState: .Normal)
            }.addDisposableTo(disposeBag)

    }
}

// MARK:- Refreshable
extension MultipleOutletsOutletView: Refreshable {
    func refresh() {
    }
}
