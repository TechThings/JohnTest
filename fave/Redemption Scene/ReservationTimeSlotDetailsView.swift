//
//  ReservationTimeSlotDetailsView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ReservationTimeSlotDetailsView: View {

    // MARK:- ViewModel
    var viewModel: ReservationTimeSlotDetailsViewModel!

    // MARK:- @IBOutlet
    // Static
    @IBOutlet weak var locationStaticLabel: UILabel!
    @IBOutlet weak var dateStaticLabel: UILabel!

    // Variable
    @IBOutlet weak var reservationDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!

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
    }
}

// MARK:- ViewModelBinldable
extension ReservationTimeSlotDetailsView: ViewModelBindable {
    func bind() {
        // Static
        viewModel.dateStatic.drive(dateStaticLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.locationStatic.drive(locationStaticLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.reservationDate.drive(reservationDateLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.location.drive(locationLabel.rx_text).addDisposableTo(disposeBag)
        viewModel.companyName.drive(companyNameLabel.rx_text).addDisposableTo(disposeBag)
    }
}
