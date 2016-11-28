//
//  EmptyChannelsViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EmptyChannelsViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var chatCreditsView: UIView!
    @IBOutlet weak var createChannelButton: UIButton!
    @IBOutlet weak var createChannelDescription: KFITLabel!

    @IBOutlet weak var loadingBackgroundImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var creditsLabel: UILabel?

    @IBAction func knowMoreChatCreditsTapped(sender: AnyObject) {
        let alertController = UIAlertController.alertController(forTitle: NSLocalizedString("chat_cashback_dialog_title", comment: ""), message: NSLocalizedString("chat_fave_credit_friends_redeemed_offer", comment: ""))

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK:- IBAction
    @IBAction func createChannelButtonDidTap(sender: UIButton) {

        viewModel.createChannelButtonDidTap.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: EmptyChannelsViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

        createChannelButton.layer.cornerRadius = 3
        createChannelDescription.lineSpacing = 2.3

        let screenWidth = UIScreen.mainWidth
        if screenWidth == 320 {
            loadingBackgroundImageView.image = UIImage(named: "fakechat-i5")
        } else {
            loadingBackgroundImageView.image = UIImage(named: "fakechat-i6")
        }
    }

    func setupCreditsText(string: String) {

        self.creditsLabel?.text = string

        // Length 9 is for But Wait!
        let attributedString = NSMutableAttributedString(string: string)
        let learnMoreLength = NSLocalizedString("learn_more", comment: "").characters.count
        attributedString.addAttribute(NSLinkAttributeName, value: "https://go.myfave.com", range: NSRange(location: string.characters.count-learnMoreLength, length: learnMoreLength))

        self.creditsLabel?.attributedText = attributedString
    }
}

// MARK:- ViewModelBinldable
extension EmptyChannelsViewController: ViewModelBindable {
    func bind() {
        viewModel
            .isLoading
            .drive(contentView.rx_hidden)
            .addDisposableTo(disposeBag)

        viewModel
            .showCashback
            .driveNext { [weak self] (show) in
                guard let strongSelf = self else {return}
                strongSelf.chatCreditsView.hidden = !show

        }.addDisposableTo(disposeBag)

            viewModel
                .creditsText
                .driveNext { [weak self] (text) in
                    if (text.characters.count < 2) {return}
                    guard let strongSelf = self else {return}
                    strongSelf.setupCreditsText(text)
                }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension EmptyChannelsViewController: Buildable {
    final class func build(builder: EmptyChannelsViewControllerViewModel) -> EmptyChannelsViewController {
        let storyboard = UIStoryboard(name: "EmptyChannels", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.EmptyChannelsViewController) as! EmptyChannelsViewController
        vc.viewModel = builder
        return vc
    }
}
