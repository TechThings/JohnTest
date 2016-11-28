//
//  OutletCalloutView.swift
//  KFIT
//
//  Created by Nazih Shoura on 17/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit
import Kingfisher

final class OutletCalloutView: View {
    var viewModel: OutletCalloutViewModel!

    @IBOutlet weak var partnerNameLabel: KFITLabel!
    @IBOutlet weak var outletNameLabel: KFITLabel!
    //@IBOutlet weak var distanceLabel: KFITLabel!
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var backgroundButton: UIButton!

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
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        setup()
    }

    func setup() {
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.cornerRadius = 3
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowRadius = 3

    }
}

extension OutletCalloutView: ViewModelBindable {
    func bind() {

        viewModel.partnerName
            .asObservable()
            .subscribeNext { [weak self]  (value) in
                self?.partnerNameLabel.text = value
                self?.partnerNameLabel.letterSpacing = 0.3
            }.addDisposableTo(disposeBag)

        viewModel.outletName
            .asObservable()
            .subscribeNext { [weak self]  (value) in
                self?.outletNameLabel.text = value
                self?.outletNameLabel.letterSpacing = 0.3
            }.addDisposableTo(disposeBag)

        viewModel.partnerProfileImageURL
            .asObservable()
            .subscribeNext { [weak self] (value) in
                if let value = value {
                    self?.partnerImageView.kf_setImageWithURL(
                        value
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.partnerImageView.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(disposeBag)
    }
}
