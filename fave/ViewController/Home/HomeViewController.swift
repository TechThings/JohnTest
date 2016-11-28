//
//  HomeViewController.swift
//  FAVE
//
//  Created by Kevin Mun on 05/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var parallaxHeaderView: KFITParallaxHeaderView!
    weak var headerView: HomeHeaderView!
    weak var refreshControl: UIRefreshControl!

    private var adapter: FaveListingAdapter?

    //injectables
    private weak var cityProvider: CityProvider?
    private weak var viewControllerAssembler: IViewControllerAssembler?
    private weak var locationProvider: ILocationProvider?
    private weak var faveActivityProvider: FaveActivityProvider?
    private weak var partnerProvider: PartnerProvider?
    private weak var favoriteProvider: FavoriteProvider?
    private weak var memberProvider: MemberProvider?

    //constants
    private let tableHeaderViewHeight: CGFloat = 150

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeaderView()
        configureRefreshControl()

        if let _ = adapter {
            registerAdapter()
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func setAdapter(adapter: FaveListingAdapter) {
        self.adapter = adapter
        if let _ = tableView {
            registerAdapter()
        }
    }

    private func registerAdapter() {
        tableView.delegate = self.adapter
        tableView.dataSource = self.adapter
        self.adapter?.registerTableView(tableView)
        adapter?.getFaveActivities(1)
    }

    func configureHeaderView() {
        let headerView = HomeHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: tableHeaderViewHeight))
        let parallaxHeaderView = KFITParallaxHeaderView.parallaxHeaderViewWithSubView(headerView) as! KFITParallaxHeaderView
        if let member = memberProvider?.getCachedMember() {
            headerView.welcomeLabel.text = "Welcome back, \(member.memberName) !"
        } else {
            headerView.welcomeLabel.text = "Welcome !"
        }
        tableView.tableHeaderView = parallaxHeaderView
        self.parallaxHeaderView = parallaxHeaderView
        self.headerView = headerView
    }

    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clearColor()
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
    }

    //MARK:- custom Refresh controls
    func refresh() {
        //change the icon
        startAnimateImage()
        adapter?.refresh()
    }

    func startAnimateImage() {
        UIView.animateWithDuration(
            Double(0.8),
            delay: Double(0.0),
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                //rotate the imageview by a little
                self.headerView.iconImage.transform = CGAffineTransformRotate(self.headerView.iconImage.transform, CGFloat(M_PI_2))
            },
            completion: {[weak self] finished in
                // If still refreshing, keep spinning, else reset
                guard let strongSelf = self else {
                    return
                }
                if (strongSelf.refreshControl.refreshing) {
                    strongSelf.startAnimateImage()
                } else {
                    strongSelf.resetAnimation()
                }
            }
        )
    }

    func resetAnimation() {
        self.headerView.iconImage.transform = CGAffineTransformIdentity
    }
}

extension HomeViewController: ControllerAssemblerInjectable {
    func injectAssembler(viewControllerAssembler: IViewControllerAssembler) {
        self.viewControllerAssembler = viewControllerAssembler
    }
}

extension HomeViewController: CityProviderInjectable {
    func injectCityProvider(cityProvider: CityProvider) {
        self.cityProvider = cityProvider
    }
}

extension HomeViewController: FavoriteProviderInjectable {
    func injectFavoriteProvider(favoriteProvider: FavoriteProvider) {
        self.favoriteProvider = favoriteProvider
    }
}

extension HomeViewController: LocationProviderInjectable {
    func injectLocationProvider(locationProvider: ILocationProvider) {
        self.locationProvider = locationProvider
    }
}

extension HomeViewController: FaveActivityProviderInjectable {
    func injectFaveActivityProvider(faveActivityProvider: FaveActivityProvider) {
        self.faveActivityProvider = faveActivityProvider
    }
}

extension HomeViewController: MemberProviderInjectable {
    func injectMemberProvider(memberProvider: MemberProvider) {
        self.memberProvider = memberProvider
    }
}

extension HomeViewController: PartnerProviderInjectable {
    func injectPartnerProvider(partnerProvider: PartnerProvider) {
        self.partnerProvider = partnerProvider
    }
}
