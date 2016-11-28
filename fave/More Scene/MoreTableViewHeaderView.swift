//
//  MoreTableViewHeaderView.swift
//  FAVE
//
//  Created by Nazih Shoura on 11/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class MoreTableViewHeaderView: UIView {

    // MARK:- Constant

    @IBOutlet weak var headerImage: UIImageView!

    // MARK: Initilization
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
        let view = NSBundle.mainBundle().loadNibNamed(String(MoreTableViewHeaderView), owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()
    }

    private func setup() {
    }
}
