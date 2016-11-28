//
//  ListingThingsToKnowFooter.swift
//  FAVE
//
//  Created by Gaddafi Rusli on 17/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ListingThingsToKnowFooter: View {
    @IBOutlet weak var redeemLabel: KFITLabel!
    @IBAction func didTapHowToRedeemButton(sender: AnyObject) {
        viewModel.didTapHowToRedeemButton.onNext()
    }

    // MARK: ViewModel
    var viewModel: ListingThingsToKnowFooterViewModel!

    // MARK: Initilization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        redeemLabel.lineSpacing = 2.3
        redeemLabel.textAlignment = .Left
    }

}

