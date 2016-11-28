//
//  RedeemedReservationView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class RedeemedReservationView: View {

    // MARK:- ViewModel
    var viewModel: RedeemedReservationViewModel!

    // MARK:- Constant

    // MARK:- @IBOutlet
    @IBOutlet weak var quantityStaticLabel: UILabel!
    @IBOutlet weak var avatarWrapView: AvatarView!
    @IBOutlet weak var forPartnerRefranceStaticLabel: UILabel!
    @IBOutlet weak var redeemedOnStaticLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var partnerReferenceView: UIView!
    @IBOutlet weak var redemptionDateLabel: UILabel!
    @IBOutlet weak var redemptionCodeStaticLabel: UILabel!
    @IBOutlet weak var redemptionCodeLabel: UILabel!

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
        partnerReferenceView.layer.cornerRadius = 3
        avatarWrapView.layer.cornerRadius = 30
        avatarWrapView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarWrapView.layer.borderWidth = 2
    }
}

extension RedeemedReservationView: ViewModelBindable {
    func bind() {

        // Static
        viewModel.redemptionCodeStatic.drive(redemptionCodeStaticLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.quantityStatic.drive(quantityStaticLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.redeemedOnStatic.drive(redeemedOnStaticLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.forPartnerRefranceStatic.drive(forPartnerRefranceStaticLabel.rx_text).addDisposableTo(disposeBag)

        // Dynamic
        viewModel.profilePictureViewModel
            .asDriver()
            .driveNext { [weak self] (profilePictureViewModel) in
                self?.avatarWrapView.viewModel = profilePictureViewModel
            }.addDisposableTo(disposeBag)

        viewModel.quantity.drive(quantityLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.redemptionDate.drive(redemptionDateLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.redemptionCode.drive(redemptionCodeLabel.rx_text).addDisposableTo(disposeBag)
    }
}
