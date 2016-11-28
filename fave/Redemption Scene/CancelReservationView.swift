//
//  CancelReservationView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CancelReservationView: View {

    // MARK:- ViewModel
    var viewModel: CancelReservationViewModel!

    @IBOutlet weak var cancelLabel: UILabel!

    // MARK:- @IBOutlet
    @IBOutlet weak var cancelButton: UIButton!

    // MARK:- @IBAction
    @IBAction func cancelButtonDidTab(sender: UIButton) {
        viewModel.cancelButtonDidTap.onNext(())
    }

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
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
        setup()
    }

    func setup() {
        cancelButton.layer.borderWidth = 0.5
        cancelButton.layer.borderColor = UIColor.faveRed().CGColor
        cancelButton.layer.cornerRadius = 3
        self.cancelButton.setTitle(NSLocalizedString("cancel_this_purchase", comment: ""), forState: .Normal)

    }
}

// MARK:- ViewModelBinldable
extension CancelReservationView: ViewModelBindable {
    func bind() {

        viewModel.cancelLabel.drive(cancelLabel.rx_text).addDisposableTo(disposeBag)

        viewModel
            .cancelButtonText
            .driveNext { [weak self] (cancelButtonText: String) in
            self?.cancelButton.titleLabel?.text = cancelButtonText
        }.addDisposableTo(disposeBag)

        viewModel.cancelButtonEnabled.drive(cancelButton.rx_enabled).addDisposableTo(disposeBag)
    }
}
