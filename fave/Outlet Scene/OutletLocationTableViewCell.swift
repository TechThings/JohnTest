//
//  OutletLocationTableViewCell.swift
//  FAVE
//
//  Created by Michael Cheah on 7/13/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OutletLocationTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: OutletContactViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var outletAddress: KFITLabel!
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    // @IBAction
    @IBAction func getDirectionButtonDidTap(sender: UIButton) {
        viewModel.getOutletDirectionsButtonDidTap.onNext(())
    }

    @IBAction func callOutletButtonDidTap(sender: UIButton) {
        viewModel.callOutletButtonDidTap.onNext(())
    }

    // MARK:- Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        getDirectionButton.layer.cornerRadius = 3
        getDirectionButton.layer.borderColor = UIColor.faveBlue().CGColor
        getDirectionButton.layer.borderWidth = 0.5

        callButton.layer.cornerRadius = 3
        callButton.layer.borderColor = UIColor.faveBlue().CGColor
        callButton.layer.borderWidth = 0.5
        self.getDirectionButton.setTitle(NSLocalizedString("purchase_detail_direction_text", comment: ""), forState: .Normal)

        self.callButton.setTitle(NSLocalizedString("call", comment: ""), forState: .Normal)

    }
}

// MARK:- ViewModelBinldable

extension OutletLocationTableViewCell: ViewModelBindable {
    func bind() {
        self.outletAddress.text = viewModel.outlet.address!
        self.outletAddress.lineSpacing = 2.2
        self.outletAddress.textAlignment = .Left
    }
}
