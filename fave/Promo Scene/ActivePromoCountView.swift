//
//  ActivePromoCountView.swift
//  KFIT
//
//  Created by Nazih Shoura on 11/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ActivePromoCountView: UIView {

    // MARK: @IBOutlet internal
    @IBOutlet weak var activePromoCountViewHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var activePromoCountLabel: UILabel!
    // MARK: Properties internal
    var activePromoCount: Int! {
        didSet {
            activePromoCountLabel.text = String(format: NSLocalizedString("active_promo_codes_count", comment: ""), String(activePromoCount))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(literal.ActivePromoCountView, owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()
    }

    private func setup() {
    }

}
