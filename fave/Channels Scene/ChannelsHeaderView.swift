//
//  ChannelsHeaderView.swift
//  FAVE
//
//  Created by Nazih Shoura on 11/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ChannelsHeaderView: View {

    // MARK:- ViewModel
    var viewModel: ChannelsHeaderViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var subTitleLable: UILabel!

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
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        super.updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ChannelsHeaderView: ViewModelBindable {
    func bind() {
        viewModel
            .title
            .drive(titleLable.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .subTitle
            .drive(subTitleLable.rx_text)
            .addDisposableTo(disposeBag)
    }
}
