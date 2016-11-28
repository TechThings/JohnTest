//
//  ActivityIndicatorView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

@IBDesignable

final class ActivityIndicatorView: UIView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var loadingImageVIew: UIImageView!

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
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(String(ActivityIndicatorView), owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    func startAnimation() {
        activityIndicator.startAnimating()
    }

    func loadingViewDidAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = Int(0)
        rotation.toValue = Int((2 * M_PI))
        rotation.duration = 0.7
        rotation.repeatCount = Float.infinity
        loadingImageVIew.layer.addAnimation(rotation, forKey: "Spin")
    }
}
