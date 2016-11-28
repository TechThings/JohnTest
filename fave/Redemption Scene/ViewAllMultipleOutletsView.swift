//
//  ViewAllMultipleOutletsView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewAllMultipleOutletsView: View {

    // MARK:- ViewModel
    var viewModel: ViewAllMultipleOutletsViewModel! {
        didSet {
            bind()
        }
    }

    // MARK:- Constant

    // @IBOutlet

    // Static
    @IBOutlet weak var viewAllLocationsButton: UIButton!

    @IBAction func didTapViewAllLocationsButton(sender: AnyObject) {
        viewModel.viewAllLocationsDidTap.onNext()
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
        let view = NSBundle.mainBundle().loadNibNamed(String(ViewAllMultipleOutletsView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
        setup()
    }

    func setup() {
        viewAllLocationsButton.layer.borderWidth = 0.5
        viewAllLocationsButton.layer.borderColor = UIColor.faveBlue().CGColor
        viewAllLocationsButton.layer.cornerRadius = 3

        self.viewAllLocationsButton.setTitle(NSLocalizedString("purchase_detail_view_all_location_detail_text", comment: ""), forState: .Normal)
    }
}

extension ViewAllMultipleOutletsView: ViewModelBindable {
    func bind() {

    }
}
