//
//  NearbyViewController.swift
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

final class NearbyViewController: MXSegmentedPagerController, MXParallaxHeaderProtocol, Scrollable {

    var disposeBag = DisposeBag()

    let header = (ListingsLocationNavigationTitle.loadFromNibNamed("ListingsLocationNavigationTitle") as! ListingsLocationNavigationTitle)

    var viewModel: NearbyViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        header.viewModel = ListingsLocationNavigationTitleModel()

        bind()
        setup()
    }

    func setup() {
        segmentedPager.bounces = false
        segmentedPager.backgroundColor = UIColor.whiteColor()

        // Parallax Header
        segmentedPager.parallaxHeader.view = header
        segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Top
        segmentedPager.parallaxHeader.height = 70
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
        viewModel.setAsActive()
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_NEARBY)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

        dispatch_async(dispatch_get_main_queue()) {
            self.segmentedPager.pager.showPageAtIndex(self.viewModel.state.value.selectedPage, animated: true)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
    }

    func setCurrentPage(page: Int) {
        viewModel.updateViewModel(withState: NearbyViewModelState(selectedPage: page))
        segmentedPager.pager.showPageAtIndex(page, animated: true)
    }

    func scrollToTop() {
        if let currentViewController = getCurrentPage() {
            currentViewController.tableView.setContentOffset(CGPoint.zero, animated:true)
        }
    }

    func getCurrentPage() -> ListingsViewController? {
        let currentPage = viewModel.state.value.selectedPage
        return viewModel.segments.value[safe: currentPage]?.controllerGenerator as? ListingsViewController
    }
}

// MARK- MXSegmentedPagerDataSource
extension NearbyViewController {
    override func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager) -> Int {
        return viewModel.segments.value.count
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return viewModel.segments.value[index].title
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return viewModel.segments.value[index].controllerGenerator
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, didSelectViewWithIndex index: Int) {
        viewModel.updateViewModel(withState: NearbyViewModelState(selectedPage: index))
    }
}

extension NearbyViewController: ViewModelBindable {
    func bind() {

        header.viewModel
            .location
            .asObservable()
            .bindTo(viewModel.location)
            .addDisposableTo(disposeBag)

        segmentedPager.segmentedControl.selectedSegmentIndex = viewModel.state.value.selectedPage

        viewModel.segments
            .asDriver()
            .driveNext { [weak self] (_) in
                self?.segmentedPager.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Build
extension NearbyViewController: Buildable {
    static func build(builder: NearbyViewModel) -> NearbyViewController {
        let storyboard = UIStoryboard(name: "Nearby", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(literal.NearbyViewController) as! NearbyViewController
        viewController.viewModel = builder
        return viewController
    }
}
