//
//  OutletContactView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OutletContactView: View {

    // MARK:- ViewModel
    var viewModel: OutletContactViewModel!

    // MARK:- Constant

    // @IBOutlet

    // Static
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var callOutletButton: UIButton!

    // @IBAction
    @IBAction func getDirectionButtonDidTap(sender: UIButton) {
        viewModel.getOutletDirectionsButtonDidTap.onNext(())
    }

    @IBAction func callOutletButtonDidTap(sender: UIButton) {
        viewModel.callOutletButtonDidTap.onNext(())
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
        let view = NSBundle.mainBundle().loadNibNamed(String(OutletContactView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
        setup()
    }

    func setup() {
        getDirectionButton.layer.borderWidth = 0.5
        getDirectionButton.layer.borderColor = UIColor.faveBlue().CGColor
        getDirectionButton.layer.cornerRadius = 3

        callOutletButton.layer.borderWidth = 0.5
        callOutletButton.layer.borderColor = UIColor.faveBlue().CGColor
        callOutletButton.layer.cornerRadius = 3

        self.getDirectionButton.setTitle(NSLocalizedString("purchase_detail_direction_text", comment: ""), forState: .Normal)

        self.callOutletButton.setTitle(NSLocalizedString("purchase_detail_call_text", comment: ""), forState: .Normal)

    }
}

extension OutletContactView: ViewModelBindable {
    func bind() {
//        viewModel.getDirectionsStatic.drive(getDirectionLabel.rx_text).addDisposableTo(disposeBag)
//        viewModel.callOutletStatic.drive(callOutletLabel.rx_text).addDisposableTo(disposeBag)
    }
}
