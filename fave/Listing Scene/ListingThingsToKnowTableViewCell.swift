//
//  ListingThingsToKnowTableViewCell.swift
//  fave
//
//  Created by Michael Cheah on 7/16/16.
//  Copyright (c) 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingThingsToKnowTableViewCell: TableViewCell {

    @IBOutlet weak var webView: UIWebView!

    // MARK:- ViewModel
    var viewModel: ListingThingsToKnowTableViewCellViewModel!

    // MARK:- Constant

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
    }
}

// MARK:- ViewModelBinldable

extension ListingThingsToKnowTableViewCell: ViewModelBindable {
    func bind() {
        guard let html = viewModel.htmlText
        else {
            return
        }

        webView.loadHTMLString(html, baseURL: nil)
    }
}

extension ListingThingsToKnowTableViewCell: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 1
        webView.frame = frame
        let fittingSize = webView.sizeThatFits(CGSize.zero)
        frame.size = fittingSize
        webView.frame = frame

        // Update Table View
        viewModel.cellHeight.value = fittingSize.height
    }
}
