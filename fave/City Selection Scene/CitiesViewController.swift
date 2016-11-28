//
//  CitiesViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 07/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CitiesViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: CitiesViewModel!

    // MARK:- Constant
    private let tableHeaderViewHeight: CGFloat = 240
    private let tableViewCellHeight: CGFloat = 50

    // MARK:- Variable
    var cities = [City]()

    #if DEBUG
    // MARK:- backdoor
    var backdoor = false
    #endif

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didFinishChangingLocationPermission), name: UIApplicationDidBecomeActiveNotification, object: nil)
        setup()
        bind()

        #if DEBUG
            configureLongPressButton()
        #endif

    }

    #if DEBUG
    private func configureLongPressButton() {
        let button = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        button.backgroundColor = .clearColor()
        button.setTitle("", forState: .Normal)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        button.addGestureRecognizer(longPress)
        view.addSubview(button)
    }
    @objc private func longPress(guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizerState.Began {
            backdoor = true
        }
    }
    #endif

    func didFinishChangingLocationPermission() {
        viewModel.cityProvider.refresh()
    }

    func setup() {
        configureHeaderView()
        registerTableCells()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.hidden = true
    }

    func registerTableCells() {
        tableView.registerNib(UINib(nibName:literal.CitiesTableViewCell, bundle: nil), forCellReuseIdentifier: literal.CitiesTableViewCell)
    }

    func configureHeaderView() {
        let headerView = CitiesHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: tableHeaderViewHeight))
        headerView.delegate = self
        tableView.tableHeaderView = headerView
    }

}

extension CitiesViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = cities[indexPath.row]
        viewModel.cityProvider.userSelectionDeducedCity.value = city
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let city = self.cities[row]
        let tableViewCell = tableView.dequeueReusableCellWithIdentifier(literal.CitiesTableViewCell, forIndexPath: indexPath) as! CitiesTableViewCell
        tableViewCell.contentLabel.text = city.name
        tableViewCell.separatorInset = UIEdgeInsets(top: 0,left: 15,bottom: 0,right: 0)
        return tableViewCell
    }

}

extension CitiesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewCellHeight
    }

    // workaround to hide separator lines when empty
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}

extension CitiesViewController: CitiesHeaderViewDelegate {
    func didTapButton() {
        if viewModel.locationService.locationPermission.value == .NotDetermined {
            viewModel.locationService.requestLocationPermission(.WhenInUse)
        } else if !(self.viewModel.locationService.locationPermission.value == .AuthorizedAlways
            || self.viewModel.locationService.locationPermission.value == .AuthorizedWhenInUse) {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        } else {
            self.viewModel.cityProvider.refresh()
        }
    }
}

// MARK:- ViewModelBinldable
extension CitiesViewController: ViewModelBindable {
    func bind() {
        viewModel.cities.driveNext { [weak self] (cities) in
            self?.cities = cities
            self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        // Present the tab bar if the a location deduced city was obtained
        viewModel
            .cityProvider
            .currentCity
            .asObservable()
            .observeOn(MainScheduler.instance)
            .filterNil() // Whenever we capture the city.
            .subscribeNext { [weak self] _ in
                guard let strongSelf = self else { return }

                #if DEBUG
                    if strongSelf.backdoor {
                        let vc = RegisterViewController.build(RegisterViewModel())
                        strongSelf.navigationController?.setViewControllers([vc], animated: true)
                        return
                    }
                #endif

                guard strongSelf.viewModel.userProvider.currentUser.value.userStatus == UserStatus.Registered
                    || strongSelf.viewModel.userProvider.currentUser.value.userStatus == UserStatus.Guest else {
                        let vc = RegisterViewController.build(RegisterViewModel())
                        strongSelf.navigationController?.setViewControllers([vc], animated: true)
                        return
                }
                guard strongSelf.navigationController?.presentingViewController == nil else {
                    strongSelf.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    return
                }
                let rootTabBarController = RootTabBarController.build(RootTabBarViewModel(setAsRoot: true))
                strongSelf.navigationController?.presentViewController(rootTabBarController, animated: true, completion: nil)
        }.addDisposableTo(disposeBag)
    }
}

// MARK:- Build
extension CitiesViewController: Buildable {
    final class func build(builder: CitiesViewModel) -> CitiesViewController {
        let storyboard = UIStoryboard(name: "CitySelection", bundle: nil)
        let citiesViewController = storyboard.instantiateViewControllerWithIdentifier(literal.CitiesViewController) as! CitiesViewController
        citiesViewController.viewModel = builder
        return citiesViewController
    }
}
