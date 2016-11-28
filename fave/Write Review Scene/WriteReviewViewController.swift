//
//  WriteReviewViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 8/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class WriteReviewViewController: ViewController {

    // MARK:- IBOutlet

    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewGuideLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottom: NSLayoutConstraint!

    // MARK:- ViewModel
    var viewModel: WriteReviewViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        scrollView.alwaysBounceVertical = true
        endEditingWhenTapOnBackground(true)
        registerKeyboardNotification()
    }

    func registerKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriteReviewViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriteReviewViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.animateWithDuration(0.1, animations: { () -> Void in
            let bottomContinueButton = UIScreen.mainScreen().bounds.size.height - (self.submitButton.frame.origin.y + self.submitButton.frame.size.height + 40)
            self.bottom.constant = keyboardFrame.size.height - bottomContinueButton
        })
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottom.constant = 0
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_PARTNER_RATING)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    deinit {
    }

    @IBAction func didTapSubmitButton(sender: AnyObject) {
        viewModel.didTapSubmit()
    }
}

// MARK:- ViewModelBinldable
extension WriteReviewViewController: ViewModelBindable {
    func bind() {

        viewModel
            .activityPhoto
            .asDriver()
            .driveNext { [weak self] (url: NSURL?) in
                guard let url = url else {
                    self?.activityImageView.image = UIImage(named: "place-holder")
                    return
                }
                self?.activityImageView.kf_setImageWithURL(url, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
            }.addDisposableTo(disposeBag)

        ratingView.viewModel.rating.asObservable().bindTo(viewModel.rating).addDisposableTo(disposeBag)

        viewModel.listingName.drive(activityNameLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.companyName.drive(companyNameLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.outletName.drive(outletNameLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.ratingText.asDriver().driveNext { [weak self](rating: String) in
            self?.ratingLabel.text = rating
            }.addDisposableTo(disposeBag)

        viewModel.reviewGuideText.asDriver().drive(reviewGuideLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.reviewViewHidden.asDriver().driveNext { [weak self] (hidden: Bool) in
            self?.reviewView.hidden = hidden
            }.addDisposableTo(disposeBag)

        viewModel.submitButtonHidden.asDriver().driveNext { [weak self] (hidden: Bool) in
            self?.submitButton.hidden = hidden
            }.addDisposableTo(disposeBag)

        commentTextView.rx_text
            .bindTo(viewModel.comment)
            .addDisposableTo(disposeBag)

    }
}

// MARK:- Buildable
extension WriteReviewViewController: Buildable {
    final class func build(builder: WriteReviewViewControllerViewModel) -> WriteReviewViewController {
        let storyboard = UIStoryboard(name: "WriteReview", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.WriteReviewViewController) as! WriteReviewViewController
        vc.viewModel = builder
        return vc
    }
}
