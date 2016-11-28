//
//  ListingWhatYouGetTableViewCell.swift
//  FAVE
//
//  Created by Syahmi Ismail on 15/11/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingWhatYouGetTableViewCell: TableViewCell {

    @IBOutlet weak var webView: UIWebView!

    // MARK:- ViewModel
    var viewModel: ListingWhatYouGetTableViewCellModel!

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

extension ListingWhatYouGetTableViewCell: ViewModelBindable {
    func bind() {
        guard let html = viewModel.htmlText
            else {
                return
        }

        webView.loadHTMLString(html, baseURL: nil)
    }
}

extension ListingWhatYouGetTableViewCell: UIWebViewDelegate {
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
