//
//  ListingsLocationNavigationTitle.swift
//  FAVE
//
//  Created by Thanh KFit on 8/10/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsLocationNavigationTitle: View {

    // MARK:- ViewModel
    var viewModel: ListingsLocationNavigationTitleModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var titleOverlayButton: UIButton!

    @IBAction func titleOverlayButtonDidTap(sender: AnyObject) {
        viewModel.titleOverlayButtonDidTap.onNext(())
    }
    // MARK:- Constant

    // MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        super.updateConstraints()
    }

    private func setup() {

    }

    @IBAction func didTapCurrentLocationButton(sender: AnyObject) {
        viewModel.resetLocation()
    }

}

// MARK:- ViewModelBinldable
extension ListingsLocationNavigationTitle: ViewModelBindable {
    func bind() {
        viewModel
            .locationName
            .asDriver()
            .drive(locationNameLabel.rx_text)
            .addDisposableTo(disposeBag)
    }
}
