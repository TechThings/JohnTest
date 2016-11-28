//
//  PromoAddedViewController.swift
//  KFIT
//
//  Created by Nazih Shoura on 12/04/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class PromoAddedViewController: UIViewController {

    // MARK: @IBOutlet internal
    @IBOutlet weak var promoAddedView: PromoAddedView!
    @IBOutlet weak var containerView: UIView!

    var viewModel: ViewModel!
    var promo: Promo!

    var addingPromo: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = self.view.frame.size.height
        animation.toValue = 0
        animation.duration = 0.30
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.containerView.layer.addAnimation(animation, forKey: "transform.translation.y")
        configurePromoAddedView()
    }

    func configurePromoAddedView() {

        promoAddedView.delegate = self

        promoAddedView.promoAmoutLabel.text = promo?.discountUserVisible

        if promo.isForFirstPurchaseOnly {
            promoAddedView.promoConditionLabel.text = NSLocalizedString("promo_code_first_time_text", comment: "")
        } else {
            promoAddedView.promoConditionLabel.text = .None
            promoAddedView.removePromoConditionLabel()
        }

        if let promoDateString = promo.expiryDatetime?.PromoDateString {
            promoAddedView.promoExpiryDateLabel.text =  promoDateString
            promoAddedView.promoExpiryDateWithAmountLabel.text = promoDateString
        } else {
            promoAddedView.promoExpiryDateLabel.text = "∞"
            promoAddedView.promoExpiryDateWithAmountLabel.text = "∞"
        }

        promoAddedView.promoCodeLabel.text = promo.code
        promoAddedView.promoAmoutLabel.text = promo.discountUserVisible

        if !addingPromo {
            promoAddedView.promoCodeSuccessfullyAddedViewHieghtConstraint.constant = 0
        }

        if promo.discountUserVisible == "" {
            promoAddedView.removeAmount()
        } else {
            promoAddedView.promoDescriptionLabel.text = promo.discountDescriptionUserVisible
        }

        if let promoMarketingDescription = promo.marketingDescriptionUserVisible {
            promoAddedView.promoMarketingDescriptionLabel.text = promoMarketingDescription
        } else {
            promoAddedView.promoMarketingDescriptionLabel.text = .None
        }

        if let promoDiscountDescription = promo.discountDescriptionUserVisible {
            promoAddedView.promoDescriptionLabel.text = promoDiscountDescription
        } else {
            promoAddedView.promoDescriptionLabel.text = .None
        }

    }
}

extension PromoAddedViewController: PromoAddedViewDelegate {
    func promoAddedViewDismissButtonDidTab(promoAddedView: PromoAddedView) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PromoAddedViewController: Buildable {
    static func build(builder: ViewModel) -> PromoAddedViewController {
        let storyboard = UIStoryboard(name: "Promo", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(PromoAddedViewController)) as! PromoAddedViewController
//        vc.viewModel = builder
//        builder.refresh()
        return vc
    }
}
