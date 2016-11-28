//
//  AboutViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 10/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AboutUsViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var faveDescriptionLabel: UILabel!

    @IBOutlet weak var logoImageView: UIImageView!

    // MARK:- IBAction
    @IBAction func facebookButtonDidTap(sender: UIButton) {
        guard let facebookURLDeeplink = NSURL(string: viewModel.app.keys.facebookURLDeeplink) else { return }
        if UIApplication.sharedApplication().canOpenURL(facebookURLDeeplink) {
            UIApplication.sharedApplication().openURL(facebookURLDeeplink)
        } else {
            guard let facebookURL = NSURL(string: viewModel.app.keys.facebookURL) else { return }
            UIApplication.sharedApplication().openURL(facebookURL)
        }
    }

    @IBAction func instegramButtonDidTap(sender: UIButton) {
        let instegramURLDeeplink = NSURL(string: viewModel.app.keys.instagramURLDeeplink)!
        if UIApplication.sharedApplication().canOpenURL(instegramURLDeeplink) {
            UIApplication.sharedApplication().openURL(instegramURLDeeplink)
        } else {
            guard let instegramURL = NSURL(string: viewModel.app.keys.instagramURL) else { return }
            UIApplication.sharedApplication().openURL(instegramURL)
        }
    }

    // MARK:- ViewModel
    var viewModel: AboutUsViewControllerViewModel!

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.title = NSLocalizedString("more_about_title_text", comment:"")
        setup()
    }

    func setup() {
        versionLabel.text = "version ".stringByAppendingString(viewModel.app.appVersion)
        faveDescriptionLabel.text = assetProviderDefault.textAssest.value.aboutText
    }
}

// MARK:- ViewModelBinldable
extension AboutUsViewController: ViewModelBindable {
    func bind() {
        viewModel.logoImage
            .drive(logoImageView.rx_image)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension AboutUsViewController: Buildable {
    final class func build(builder: AboutUsViewControllerViewModel) -> AboutUsViewController {
        let storyboard = UIStoryboard(name: "AboutUs", bundle: nil)
        let aboutUsViewController = storyboard.instantiateViewControllerWithIdentifier(literal.AboutUsViewController) as! AboutUsViewController
        aboutUsViewController.viewModel = builder
        return aboutUsViewController
    }
}
