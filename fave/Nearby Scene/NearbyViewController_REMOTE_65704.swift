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

class NearbyViewController: MXSegmentedPagerController, MXParallaxHeaderProtocol {

    var disposeBag = DisposeBag()

    let header = MyFaveHeaderView.instanceFromNib()

    var viewModel: NearbyViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()

        segmentedPager.bounces = false
        segmentedPager.backgroundColor = UIColor.whiteColor()

        // Parallax Header
        segmentedPager.parallaxHeader.view = header
        segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        segmentedPager.parallaxHeader.height = 64
        segmentedPager.parallaxHeader.minimumHeight = 20

        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexStringFast: "4a4a4a"), NSFontAttributeName: UIFont.systemFontOfSize(14)]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexStringFast: "33a8d1")]
        segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = UIColor(hexStringFast: "33a8d1")
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        header.top.constant = 40
        segmentedPager.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        segmentedPager.reloadData()

        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func setCurrentPage(page: NearbyPage) {
        viewModel.updateViewModel(withState: NearbyViewModelState(selectedPage: page))
        segmentedPager.pager.showPageAtIndex(page.rawValue, animated: true)
    }
}

// MARK- MXSegmentedPagerDataSource
extension NearbyViewController {
    override func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager) -> Int {
        return viewModel.segments.count
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return viewModel.segments[index].title
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, didScrollWithParallaxHeader parallaxHeader: MXParallaxHeader) {
        if segmentedPager.bounces || parallaxHeader.progress <= 0 {
            header.top.constant = 40 + parallaxHeader.progress * parallaxHeader.height
        }
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return viewModel.segments[index].controllerGenerator()
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, didSelectViewWithIndex index: Int) {
//        let selectedPage = index == 0 ? NearbyPage.Favourite : NearbyPage.Reservation
//        viewModel.updateViewModel(withState: NearbyViewModelState(selectedPage: selectedPage))
    }
}

extension NearbyViewController: ViewModelBindable {
    func bind() {
        segmentedPager.segmentedControl.selectedSegmentIndex = viewModel.state.value.selectedPage.rawValue
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
