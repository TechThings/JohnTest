//
//  ChannelCreditsTableViewCell.swift
//  FAVE
//
//  Created by Gautam on 28/09/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelCreditsTableViewCell: TableViewCell {

    @IBAction func learnMoreButtonTapped(sender: AnyObject) {
        viewModel.learnMoreButtonDidTap.onNext()
    }

    @IBOutlet weak var creditsLabel: UILabel?

    var viewModel: ChannelCreditsCellViewModel! {
        didSet { bind() }
    }

   override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension ChannelCreditsTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .creditsText
            .driveNext({ [weak self](text) in
                self?.setupCreditsText(text)
            }).addDisposableTo(rx_reusableDisposeBag)
    }
}

extension ChannelCreditsTableViewCell {
    func setupCreditsText(string: String) {
        self.creditsLabel?.text = string
        // Length 9 is for Learn More
        let attributedString = NSMutableAttributedString(string: string)
        let learnMoreLength = NSLocalizedString("learn_more", comment: "").characters.count
        attributedString.addAttribute(NSLinkAttributeName, value: "https://go.myfave.com", range: NSRange(location: string.characters.count-learnMoreLength, length: learnMoreLength))

        self.creditsLabel?.attributedText = attributedString
    }
}
