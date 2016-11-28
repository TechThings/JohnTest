//
//  HomeHeaderTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeHeaderTableViewCell: TableViewCell {

    var viewModel: HomeHeaderTableViewCellViewModel! {
        didSet { bind()  }
    }

    @IBOutlet weak var searchButton: UIButton!

    @IBAction func didTapSearchButton(sender: AnyObject) {
        viewModel.didTapSearchButton.onNext(())
    }

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var appImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.layer.cornerRadius = actionButton.frame.size.height/2
        searchButton.layer.cornerRadius = 5
    }

    @IBAction func didTapActionButton(sender: AnyObject) {
        viewModel.openNotificationDidTap.onNext(())
    }

}

extension HomeHeaderTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .name
            .drive(welcomeLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .pendingNotifications
            .asDriver()
            .driveNext { [weak self](pendingNotifications: [PendingNotification]) in
                guard let pendingNotification = pendingNotifications.first else {
                    self?.actionButton.hidden = true
                    self?.messageLabel.text = NSLocalizedString("home_welcome_subtitle_text", comment: "")
                    self?.backgroundImage.image = UIImage(named: "bg_launch_1")
                    return
                }
                self?.actionButton.hidden = false
                self?.actionButton.setTitle(pendingNotification.buttonText, forState: .Normal)
                self?.messageLabel.text = NSLocalizedString("home_welcome_subtitle_text", comment: "")
                self?.backgroundImage.image = UIImage(named: "bg_launch_1")
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.appImage
        .driveNext {[weak self] (image) in
            guard let stronSelf = self else { return }
            stronSelf.appImageView.image = image
        }.addDisposableTo(rx_reusableDisposeBag)

    }
}
