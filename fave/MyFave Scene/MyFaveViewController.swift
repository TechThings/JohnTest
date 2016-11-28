//
//  MyFaveViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 7/7/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import MXSegmentedPager
import RxSwift
import RxCocoa
import Kingfisher

final class MyFaveViewController: MXSegmentedPagerController, MXParallaxHeaderProtocol, Scrollable {

    var disposeBag = DisposeBag()

    let header = MyFaveHeaderView.instanceFromNib()

    var viewModel: MyFaveViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()

        segmentedPager.bounces = false
        segmentedPager.backgroundColor = UIColor.whiteColor()

        // Parallax Header
        segmentedPager.parallaxHeader.view = header
        segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        segmentedPager.parallaxHeader.height = 160
        segmentedPager.parallaxHeader.minimumHeight = 20

        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.Down
        segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()

        let descriptor = UIFontDescriptor(name: "CircularStd-Book", size: 15.0)
        segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexStringFast: "8a9aa9"), NSFontAttributeName : UIFont(descriptor: descriptor, size:15)]

        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexStringFast: "4a4a4a")]
        segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyle.FullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.favePink()
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        // Do any additional setup after loading the view.

        checkForScrollViewInView(view)
    }

    func checkForScrollViewInView(view: UIView) {

        for subview in view.subviews as [UIView] {

            if subview.isKindOfClass(UITextView) {
                (subview as! UITextView).scrollsToTop = false
            }

            if subview.isKindOfClass(UIScrollView) {
                (subview as! UIScrollView).scrollsToTop = false
            }

            if subview.isKindOfClass(UITableView) {
                (subview as! UITableView).scrollsToTop = false
            }

            if (subview.subviews.count > 0) {
                self.checkForScrollViewInView(subview)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        header.top.constant = 40
        segmentedPager.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

        dispatch_async(dispatch_get_main_queue()) {
            self.segmentedPager.pager.showPageAtIndex(self.viewModel.state.value.selectedPage.rawValue, animated: true)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        header.top.constant = 40

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBarHidden = false
    }

    func setCurrentPage(page: MyFavePage) {
        viewModel.updateViewModel(withState: MyFaveViewModelState(selectedPage: page))
        segmentedPager.pager.showPageAtIndex(page.rawValue, animated: true)
    }

    func scrollToTop() {
        let currentPage = viewModel.state.value.selectedPage.rawValue
        if let currentViewController = viewModel.segments[currentPage].controllerGenerator() as? Scrollable {
            currentViewController.scrollToTop()
        }
    }
}

// MARK- MXSegmentedPagerDataSource
extension MyFaveViewController {
    override func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager) -> Int {
        return viewModel.segments.count
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return viewModel.segments[index].title
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, didScrollWithParallaxHeader parallaxHeader: MXParallaxHeader) {
        if segmentedPager.bounces || parallaxHeader.progress <= 0 {
//            header.top.constant = 40 + parallaxHeader.progress * parallaxHeader.height
        }
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return viewModel.segments[index].controllerGenerator()
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, didSelectViewWithIndex index: Int) {
        let selectedPage = index == 0 ? MyFavePage.Favourite : MyFavePage.Reservation
        viewModel.updateViewModel(withState: MyFaveViewModelState(selectedPage: selectedPage))
    }
}

extension MyFaveViewController: ViewModelBindable {
    func bind() {
        viewModel.user
        .asDriver()
        .driveNext { [weak self](user) in
            let avatarViewModel = AvatarViewModel(initial: user.name, profileImageURL: user.profileImageURL)
            self?.header.avatarView.viewModel = avatarViewModel
            self?.header.nameLabel.text = user.name
            }
            .addDisposableTo(disposeBag)

        viewModel
            .state
            .asDriver()
            .map { (state: MyFaveViewModelState) -> Int in state.selectedPage.rawValue }
            .filter { [weak self] (selectedPage: Int) -> Bool in
                return selectedPage != self?.segmentedPager.segmentedControl.selectedSegmentIndex
            }
            .driveNext { [weak self] (selectedPage: Int) in
                self?.segmentedPager.segmentedControl.selectedSegmentIndex = selectedPage
            }
            .addDisposableTo(disposeBag)
    }
}

extension MyFaveViewController: Refreshable {
    func refresh() {
        if let refreshable = viewModel.segments[MyFavePage.Reservation.rawValue].controllerGenerator() as? Refreshable { refreshable.refresh()}
        if let refreshable = viewModel.segments[MyFavePage.Favourite.rawValue].controllerGenerator() as? Refreshable { refreshable.refresh()}
    }
}

// MARK:- Build
extension MyFaveViewController: Buildable {
    static func build(builder: MyFaveViewModel) -> MyFaveViewController {
        let storyboard = UIStoryboard(name: "MyFave", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(String(MyFaveViewController)) as! MyFaveViewController
        viewController.viewModel = builder
        return viewController
    }
}
