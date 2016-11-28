//
//  ListingGeneralSectionFooter.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

@objc protocol ListingGeneralSectionFooterDelegate {
    func didTapSectionButton(section: Int, sender: AnyObject)
}

final class ListingGeneralSectionFooter: UIView {

    @IBOutlet weak var sectionButton: UIButton!
    weak var delegate: ListingGeneralSectionFooterDelegate!
    var section: Int = 0

    // MARK: Initilization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        load()
        self.sectionButton.setTitle(NSLocalizedString("activity_detail_view_all_text", comment: ""), forState: .Normal)

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
        self.sectionButton.setTitle(NSLocalizedString("activity_detail_view_all_text", comment: ""), forState: .Normal)

    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(literal.ListingGeneralSectionFooter, owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

    @IBAction func didTapSectionButton(sender: AnyObject) {
        if let delegate = delegate {
            delegate.didTapSectionButton(section, sender: sender)
        }
    }

}
