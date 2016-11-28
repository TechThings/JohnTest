//
//  ChatTitleView.swift
//  FAVE
//
//  Created by Gaddafi Rusli on 23/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ChatTitleView: View {

    // MARK:- ViewModel
    var viewModel: ChatTitleViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlet
    @IBOutlet weak var chatTitleLabel: UILabel!

    // MARK:- Constant

    // MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        bind()
        super.updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ChatTitleView: ViewModelBindable {
    func bind() {
        viewModel
        .chatTitle.drive(self.chatTitleLabel.rx_text)
        .addDisposableTo(disposeBag)
    }
}
