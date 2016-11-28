//
//  RedeemableReservationView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import DeviceKit

final class RedeemableReservationView: View {

    // MARK:- ViewModel
    var viewModel: RedeemableReservationViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var appIconImageView: UIImageView!
    // MARK:- @IBOutlet
    @IBOutlet weak var cardWrapView: UIView!
    @IBOutlet weak var onlineRedeemView: UIView!

    @IBOutlet weak var avatarWrapView: AvatarView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var onlineRedeemCodeLabel: UILabel!
    @IBOutlet weak var onlineRedeemWebView: UIWebView!

    @IBOutlet weak var redemtionDescriptionLabel: KFITLabel!
    @IBOutlet weak var receiptIDLabel: UILabel!
    @IBOutlet weak var swipeContainView: UIView!
    @IBOutlet weak var swipeSlider: UISlider!
    @IBOutlet weak var swipeDescriptionLabel: UILabel!

    var webViewShouldRender = true

    @IBAction func howToRedeemButton(sender: AnyObject) {
        viewModel.didTapHowToRedeemButton()
    }

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
        let view = NSBundle.mainBundle().loadNibNamed(literal.RedeemableReservationView, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
        setup()
    }

    func setup() {
        cardWrapView.layer.cornerRadius = 3
        avatarWrapView.layer.cornerRadius = 30
        avatarWrapView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarWrapView.layer.borderWidth = 2

        onlineRedeemWebView.scrollView.scrollEnabled = false
        onlineRedeemWebView.scrollView.bounces = false

        swipeContainView.backgroundColor = UIColor.faveBlue()
        swipeContainView.layer.cornerRadius = 30
        swipeSlider.setThumbImage(UIImage(named: "ic_swipe_icon"), forState: UIControlState.Normal)

        swipeSlider.addTarget(self, action: #selector(didChangedValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        swipeSlider.addTarget(self, action: #selector(swipingDidEnd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        swipeSlider.addTarget(self, action: #selector(swipingDidEnd(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
    }

    func didChangedValue(sender: UISlider) {
        swipeDescriptionLabel.alpha = CGFloat(1) - CGFloat(sender.value)
    }

    func swipingDidEnd(sender: UISlider) {
        if sender.value >= 0.9 {
            viewModel.redeemShowConfirm.onNext()
        } else {
            resetSwipeSlider()
        }
    }

    func resetSwipeSlider() {
        UIView.animateWithDuration(0.2, animations: {
            self.swipeSlider.setValue(0, animated: true)
            self.swipeDescriptionLabel.alpha = 1
        })
    }
}

// MARK:- ViewModelBinldable
extension RedeemableReservationView: ViewModelBindable {
    func bind() {

        viewModel.appImage
            .driveNext {[weak self] (image) in
                guard let stronSelf = self else { return }
                stronSelf.appIconImageView.image = image
            }.addDisposableTo(disposeBag)

        // Dynamic
        viewModel.profilePictureViewModel
            .asDriver()
            .driveNext { [weak self] (profilePictureViewModel) in
                self?.avatarWrapView.viewModel = profilePictureViewModel
            }.addDisposableTo(disposeBag)

        viewModel.userName.drive(userNameLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.receiptID.drive(receiptIDLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.quantity.drive(quantityLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.redemtionDescription.drive(redemtionDescriptionLabel.rx_text).addDisposableTo(disposeBag)

        redemtionDescriptionLabel.lineSpacing = 2.3

        viewModel
            .redeemSliderText
            .drive(swipeDescriptionLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.redeemSliderEnabled.driveNext { [weak self] (enable) in
            if enable {
                self?.swipeSlider.alpha = 1
                self?.swipeDescriptionLabel.alpha = 1
                self?.swipeSlider.userInteractionEnabled = true
            } else {
                self?.swipeSlider.alpha = 0.39
                self?.swipeDescriptionLabel.alpha = 0.39
                self?.swipeSlider.userInteractionEnabled = false
            }
        }.addDisposableTo(disposeBag)

        viewModel
            .redeemCancelRequest
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] in
                self?.resetSwipeSlider()
            }.addDisposableTo(disposeBag)

        viewModel
            .redeemConfirmRequest
            .subscribeNext { [weak self] () in
                self?.viewModel.requestRedeem()
            }.addDisposableTo(disposeBag)

        viewModel
            .redeemShowConfirm
            .subscribeNext { [weak self] () in
                self?.viewModel.lightHouseService.navigate.onNext({ (viewController) in
                    if let redemptionViewController = viewController as? RedemptionViewController {
                        redemptionViewController.viewModel.redeemShowConfirm.onNext(())
                    }
                })
            }
            .addDisposableTo(disposeBag)

        viewModel
            .onlineRedeemDescription
            .asDriver()
            .map({ (htmlContent) -> Bool in
                guard let htmlContent = htmlContent else {
                    return true
                }
                return htmlContent.isEmpty
            }).drive(onlineRedeemWebView.rx_hidden)
        .addDisposableTo(disposeBag)

        viewModel
            .onlineRedeemDescription
            .asDriver()
            .filterNil()
            .driveNext({[weak self] (html) in
                guard let strongSelf = self else { return }
                strongSelf.onlineRedeemWebView.loadHTMLString(html, baseURL: nil)
            })
        .addDisposableTo(disposeBag)

        viewModel
            .redeemCode
            .drive(onlineRedeemCodeLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .hiddenOnlineRedeemView
            .drive(onlineRedeemView.rx_hidden)
            .addDisposableTo(disposeBag)

        viewModel
            .hiddenOnlineRedeemView
            .flatMapLatest({ (hidden: Bool) -> Driver<Bool> in
                return Driver.of(!hidden)
            })
            .drive(bottomView.rx_hidden)
            .addDisposableTo(disposeBag)

    }
}

extension RedeemableReservationView : UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        UIApplication.sharedApplication().openURL(request.URL!)
        let temp = webViewShouldRender
        if webViewShouldRender { webViewShouldRender = false }
        return temp
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        var frame = webView.frame
        frame.size.height = 1
        webView.frame = frame
        let fittingSize = webView.sizeThatFits(CGSize.zero)
        frame.size = fittingSize
        webView.frame = frame

        // Update Table View
        viewModel.cellHeight.value = fittingSize.height + 350
    }
}
