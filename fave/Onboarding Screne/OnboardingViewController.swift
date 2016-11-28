//
//  OnboardingViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 6/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentCollectionView: UICollectionView!

    @IBOutlet weak var skipArrowImageView: UIImageView!
    @IBOutlet weak var loginAsGuestButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func loginButtonDidTap(sender: AnyObject) {
        viewModel.loginButtonDidTap.onNext(())

        let onBoardingAnalyticsModel = OnboardingAnalyticsModel()
        onBoardingAnalyticsModel.goLoginEvent.sendToMoEngage()
    }

    @IBAction func pageControlTapped(sender: AnyObject) {
        if self.pageControl.currentPage >= 0 && self.pageControl.currentPage < self.viewModel.dataSource.value.count {
            self.contentCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: self.pageControl.currentPage, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
        }
    }

    @IBAction func loginAsGuestButtonDidTap(sender: AnyObject) {
        // Send Analytics
        let analyticsModel = OnboardingAnalyticsModel()
        analyticsModel.guestBrowsingEvent.sendToMoEngage()

        if viewModel.app.isRegisteredForRemoteNotifications() == false {
            if viewModel.app.isCompletedRequestEnableNotification == false {
                let vc = NotificationPermissionViewController.build(NotificationPermissionViewModel())
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }

        if (viewModel.locationService.isAllowedLocationPermission.value == false) {
            if viewModel.app.isCompletedRequestEnableLocation == false {
                let vc = LocationPermissionViewController.build(LocationPermissionViewModel())
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }

        guard viewModel.cityProvider.currentCity.value != nil else {
            let vc = CitiesViewController.build(CitiesViewModel())
            navigationController?.pushViewController(vc, animated: true)
            return
        }

        guard navigationController?.presentingViewController == nil else {
            navigationController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }

        let rootTabBarController = RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
        navigationController?.presentViewController(rootTabBarController, animated: true, completion: nil)
    }

    // MARK:- ViewModel
    var viewModel: OnboardingViewModel!

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 3
        let arrow = UIImage(named: "ic_disclosure_arrow")!.imageWithRenderingMode(.AlwaysTemplate)
        self.loginButton.setTitle(NSLocalizedString("splash_sign_up_text", comment: ""), forState: UIControlState.Normal)
        skipArrowImageView.image = arrow
        skipArrowImageView.tintColor = UIColor.faveBlue()
        configureContentCollectionView()
        contentCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        #if DEBUG
        configureSignUpButton()
        #endif

        bind()
    }

    func configureSignUpButton() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.loginButton.addGestureRecognizer(longPress)
    }
    func longPress(guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizerState.Began {
            let vm = ChangeStagingViewControllerViewModel()
            let vc = ChangeStagingViewController.build(vm)
            self.presentViewController(vc, animated: true, completion: nil)
        }
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
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_SPLASH)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func configureContentCollectionView() {
        contentCollectionView.registerNib(UINib(nibName: String(OnboardingContentCell), bundle: nil), forCellWithReuseIdentifier: String(OnboardingContentCell))
    }
}

extension OnboardingViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource.value.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(OnboardingContentCell), forIndexPath: indexPath) as! OnboardingContentCell
        cell.viewModel = viewModel.dataSource.value[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(UIScreen.mainScreen().bounds.size.width)
    }
}

extension OnboardingViewController: ViewModelBindable {
    func bind() {
        pageControl.numberOfPages = viewModel.dataSource.value.count

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
            .dataSource
            .asObservable()
            .subscribeNext {[weak self] (_) in
                guard let strongSelf = self else {return}
                strongSelf.contentCollectionView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

extension OnboardingViewController: Buildable {
    static func build(builder: OnboardingViewModel) -> OnboardingViewController {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let onboardingViewController = storyboard.instantiateViewControllerWithIdentifier(String(OnboardingViewController)) as! OnboardingViewController
        onboardingViewController.viewModel = builder
        return onboardingViewController
    }
}
