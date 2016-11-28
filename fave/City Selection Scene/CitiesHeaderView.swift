//
//  CitiesHeaderView.swift
//  FAVE
//
//  Created by Nazih Shoura on 07/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol CitiesHeaderViewDelegate: class {
    func didTapButton()
}

final class CitiesHeaderView: View {

    // MARK:- ViewModel

    // MARK:- IBOutlet
    @IBOutlet weak var enableLocationButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: IBActiont
    @IBAction func enabledidTap(sender: AnyObject) {
        if let delegate = delegate {
            delegate.didTapButton()
        }
    }

    // MARK:- Delegate
    weak var delegate: CitiesHeaderViewDelegate!

    // MARK:- Constant

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
        let view = NSBundle.mainBundle().loadNibNamed(literal.CitiesHeaderView, owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()
    }

    func setup() {

    }

}
