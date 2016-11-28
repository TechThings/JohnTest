//
//  RatingView.swift
//  FAVE
//
//  Created by Thanh KFit on 8/16/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable

final class RatingView: View {

    // MARK:- ViewModel
    var viewModel: RatingViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var bg0: UIView!
    @IBOutlet weak var bg1: UIView!
    @IBOutlet weak var bg2: UIView!
    @IBOutlet weak var bg3: UIView!
    @IBOutlet weak var bg4: UIView!
    @IBOutlet weak var bg5: UIView!
    @IBOutlet weak var bg6: UIView!
    @IBOutlet weak var bg7: UIView!
    @IBOutlet weak var bg8: UIView!
    @IBOutlet weak var bg9: UIView!

    @IBOutlet weak var tapSlideSlider: TapSlideUISlider!
    var sliderView: [UIView] = []

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
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(literal.RatingView, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)

        self.viewModel = RatingViewModel()

        sliderView = [bg0, bg1, bg2, bg3, bg4, bg5, bg6, bg7, bg8, bg9]
        for index in 0...9 {
            sliderView[index].hidden = false
        }
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func setup() {
    }

    @IBAction func sliderDidChangeValue(sender: TapSlideUISlider) {
        let current = min(9, Int(floor(sender.value)))
        for index in 0...9 {
            if index <= current {
                sliderView[index].hidden = true
            } else {
                sliderView[index].hidden = false
            }
        }

        viewModel.rating.value = Float(current + 1) * 0.5
    }
}

// MARK:- ViewModelBinldable
extension RatingView: ViewModelBindable {
    func bind() {
    }
}
