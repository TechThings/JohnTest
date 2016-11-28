//
//  ChannelsViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MoEngage_iOS_SDK

final class ChannelsViewController: ViewController {

    // MARK:- ViewModel
    var viewModel: ChannelsViewControllerViewModel!

    // MARK:- IBOutlet
    @IBOutlet weak var channelsTableView: ChannelsTableView!
    @IBOutlet weak var createChannelButtonContainerView: UIView!
    @IBOutlet weak var createChannelButton: UIButton!

    @IBOutlet weak var emptyChannelsViewControllerContainerView: UIView! {
        didSet {

            // TODO : Pass credits text here. This we get from the backend
            let vc = EmptyChannelsViewController.build(EmptyChannelsViewControllerViewModel())
            self.addChildViewController(vc)
            vc.view.frame = emptyChannelsViewControllerContainerView.bounds
            emptyChannelsViewControllerContainerView.addSubview(vc.view)
            vc.didMoveToParentViewController(self)
        }
    }
    // MARK:- IBAction
    @IBAction func createChannelButtonDidTap(sender: UIButton) {
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "new_chat", screenName: screenName.SCREEN_CHAT_HOME)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

        viewModel.createChannelButtonDidTap.onNext()
    }

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
        track()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()

        // CC: HACK. Doing this so that we know we are not actively in any Chat Screen
        // This is important to make sure Unread Count is correct
        viewModel.updateActiveChannel()

        MoEngage.sharedInstance().handleInAppMessage()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func track() {
        viewModel
            .emptyChannelsViewControllerContainerViewHidden
            .asObservable()
            .skip(1) // skip the initial value. Take the updated value after refreshing channels
            .subscribeNext({ [weak self](hidden: Bool) in

                guard let strongSelf = self else {return}
                if !hidden {
                    let localyticsEvent = LocalyticsEvent.createScreenEvent(screenName: screenName.SCREEN_CHAT_HOME)
                    localyticsEvent.addProperty("empty", value: true)
                    strongSelf.viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)
                }

            }).addDisposableTo(disposeBag)

    }

    func setup() {
        let channelsTableViewModel = ChannelsTableViewModel()
        channelsTableViewModel.refresh()
        channelsTableView.viewModel = channelsTableViewModel
        createChannelButtonContainerView.layer.cornerRadius = 25

        createChannelButtonContainerView.layer.shadowColor = UIColor.blackColor().CGColor
        createChannelButtonContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        createChannelButtonContainerView.layer.shadowOpacity = 0.25
        createChannelButtonContainerView.layer.shadowRadius = 1.45

        createChannelButtonContainerView.layer.shadowPath = UIBezierPath(roundedRect: createChannelButtonContainerView.bounds, cornerRadius: createChannelButtonContainerView.frame.size.width/2).CGPath
    }

    deinit {
        print("ChannelsViewController deinit")
    }
}

// MARK:- ViewModelBinldable
extension ChannelsViewController: ViewModelBindable {
    func bind() {
        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

        viewModel
            .emptyChannelsViewControllerContainerViewHidden
            .driveNext { (hidden: Bool) in
                UIView.animateWithDuration(0.3, animations: {
                    self.emptyChannelsViewControllerContainerView.alpha = hidden ? 0 : 1
                    self.emptyChannelsViewControllerContainerView.hidden = hidden
                })
        }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable
extension ChannelsViewController: Buildable {
    final class func build(builder: ChannelsViewControllerViewModel) -> ChannelsViewController {
        let storyboard = UIStoryboard(name: "Channels", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(ChannelsViewController)) as! ChannelsViewController
        vc.viewModel = builder
        return vc
    }
}
