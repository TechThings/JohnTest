//
//  ListingsCollectionsViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 01/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ListingsCollectionsViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var listingsCollectionsTableView: ListingsCollectionsTableView!

    // MARK:- ViewModel
    var viewModel: ListingsCollectionsViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()

        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()

        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_COLLECTION_WISE_OFFERS)
    }

    func setup() {
        let listingsCollectionsTableViewModel = ListingsCollectionsTableViewModel()
        listingsCollectionsTableViewModel.refresh()
        listingsCollectionsTableView.viewModel = listingsCollectionsTableViewModel
    }
}

// MARK:- ViewModelBinldable
extension ListingsCollectionsViewController: ViewModelBindable {
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

    }
}

// MARK:- Buildable
extension ListingsCollectionsViewController: Buildable {
    final class func build(builder: ListingsCollectionsViewControllerViewModel) -> ListingsCollectionsViewController {
        let storyboard = UIStoryboard(name: "ListingsCollections", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(ListingsCollectionsViewController)) as! ListingsCollectionsViewController
        vc.viewModel = builder
        return vc
    }
}

extension ListingsCollectionsViewController : DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> ListingsCollectionsViewController? {
        return build (ListingsCollectionsViewControllerViewModel())
    }
}
