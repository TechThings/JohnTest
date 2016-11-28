//
//  OnboardingViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 6/30/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var contentCollectionView: UICollectionView!
    private var launchScreenTextOptimizelyKeys = [OptimizelyVariableKey]()
    private var dataSource = [[String:String]]()

    func setupDataSource() {
        let launchScreenText0OptimizelyKey = OptimizelyVariableKey.optimizelyKeyWithKey(OptimizelyKey.LaunchScreenText0.rawValue, defaultNSString: OptimizelyKey.LaunchScreenText0.defaultValue)
        let launchScreenText1OptimizelyKey = OptimizelyVariableKey.optimizelyKeyWithKey(OptimizelyKey.LaunchScreenText1.rawValue, defaultNSString: OptimizelyKey.LaunchScreenText1.defaultValue)
        let launchScreenText2OptimizelyKey = OptimizelyVariableKey.optimizelyKeyWithKey(OptimizelyKey.LaunchScreenText2.rawValue, defaultNSString: OptimizelyKey.LaunchScreenText2.defaultValue)
        let launchScreenText3OptimizelyKey = OptimizelyVariableKey.optimizelyKeyWithKey(OptimizelyKey.LaunchScreenText3.rawValue, defaultNSString: OptimizelyKey.LaunchScreenText3.defaultValue)

        dataSource = [
            ["text" : Optimizely.stringForKey(launchScreenText0OptimizelyKey), "image" : "bg_launch_1"],
            ["text" : Optimizely.stringForKey(launchScreenText1OptimizelyKey), "image" : "bg_launch_1"],
            ["text" : Optimizely.stringForKey(launchScreenText2OptimizelyKey), "image" : "bg_launch_1"],
            ["text" : Optimizely.stringForKey(launchScreenText3OptimizelyKey), "image" : "bg_launch_1"]
        ]

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        configureContentCollectionView()
    }

    func configureContentCollectionView() {
        contentCollectionView.registerNib(UINib(nibName: String(OnboardingContentCell), bundle: nil), forCellWithReuseIdentifier: String(OnboardingContentCell))

        pageControl.numberOfPages = dataSource.count
    }
}

extension OnboardingViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(OnboardingContentCell), forIndexPath: indexPath) as! OnboardingContentCell
        cell.viewModel = dataSource[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension OnboardingViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(UIScreen.mainScreen().bounds.size.width)
    }
}
