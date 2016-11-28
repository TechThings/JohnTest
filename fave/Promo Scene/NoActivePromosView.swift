//
//  NoActivePromosView.swift
//  KFIT
//
//  Created by Nazih Shoura on 12/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class NoActivePromosView: UIView {

    @IBOutlet weak var NoActivePromosLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }

    func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(NoActivePromosView), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        configurePrivateLabelsText()
    }

    func configurePrivateLabelsText() {
        NoActivePromosLabel.text = NSLocalizedString("no_active_promo_codes", comment: "")
    }
}
