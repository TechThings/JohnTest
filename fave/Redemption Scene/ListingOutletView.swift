//
//  ListingOutletView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ListingOutletView: View {

    // MARK:- ViewModel
    var viewModel: ListingOutletViewModel!

    // MARK:- Constant

    // MARK:- IBOutlet variable
    @IBOutlet weak var listingNameLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: KFITLabel!
    @IBOutlet weak var currentPriceLabel: UILabel!

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
        let view = NSBundle.mainBundle().loadNibNamed(literal.ListingOutletView, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
        setup()
    }

    func setup() {

    }
}

// MARK:- ViewModelBinldable
extension ListingOutletView: ViewModelBindable {
    func bind() {
        viewModel.listingName.drive(listingNameLabel.rx_text).addDisposableTo(disposeBag)

        viewModel
            .currentPrice
            .asDriver()
            .drive(currentPriceLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .originalPrice
            .asDriver()
            .map { (originalPrice) -> Bool in
                return originalPrice.isEmpty
            }.drive(self.originalPriceLabel.rx_hidden)
            .addDisposableTo(disposeBag)

        viewModel
            .originalPrice
            .asDriver()
            .drive(self.originalPriceLabel.rx_text)
            .addDisposableTo(disposeBag)
    }
}
