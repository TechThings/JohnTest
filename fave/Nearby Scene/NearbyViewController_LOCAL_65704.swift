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

    let header = (FilterLocationNavigationTitle.loadFromNibNamed("FilterLocationNavigationTitle") as! FilterLocationNavigationTitle).then { (filterLocationNavigationTitle) in
        filterLocationNavigationTitle.viewModel = FilterLocationNavigationTitleModel()
    }

    var viewModel: NearbyViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()

        segmentedPager.bounces = false
        segmentedPager.backgroundColor = UIColor.whiteColor()

        // Parallax Header
        segmentedPager.parallaxHeader.view = header
        segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Top
        segmentedPager.parallaxHeader.height = 70
        segmentedPager.parallaxHeader.minimumHeight = 20

        // Segmented Control customization
        segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexStringFast: "8a9aa9"), NSFontAttributeName : UIFont(name: "CircularStd-Book", size:16)!]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexStringFast: "4a4a4a")]
        segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.favePink()
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.active = true

        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_NEARBY)

        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            self.segmentedPager.reloadData()
        }
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
        viewModel.active = false
        self.navigationController?.navigationBarHidden = false
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

    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return viewModel.segments[index].controllerGenerator()
    }

    override func segmentedPager(segmentedPager: MXSegmentedPager, didSelectViewWithIndex index: Int) {
        let selectedPage = NearbyPage(rawValue: index)
        viewModel.updateViewModel(withState: NearbyViewModelState(selectedPage: selectedPage!))
    }
}

extension NearbyViewController: ViewModelBindable {
    func bind() {
        header.viewModel
            .location
            .asObservable()
            .subscribeNext { [weak self] (_) in
                self?.segmentedPager.reloadData()
            }.addDisposableTo(disposeBag)

        header.viewModel
            .location
            .asObservable()
            .bindTo(viewModel.location)
            .addDisposableTo(disposeBag)

        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.active
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

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
