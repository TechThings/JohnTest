//
//  CreateChannelViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 05/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CreateChannelViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var createChannelbgButton: UIButton!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var offerInfoLabel: UILabel!
    @IBOutlet weak var whatToYouWantToDoLabel: UILabel!
    @IBOutlet weak var startNewChatLabel: UILabel!
    @IBOutlet weak var startNewChatDescriptionLabel: UILabel!
    @IBOutlet weak var letDoItLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    // MARK:- IBAction
    @IBAction func createChannelbgButtonDidTap(sender: UIButton) {
        viewModel.createChannelButtonDidTap.onNext()
    }

    @IBAction func dismissButtonDidTap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func selectOfferButtonDidTap(sender: AnyObject) {
        guard let filter = selectedFilter else {
            return
        }
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "select_offer", screenName: screenName.SCREEN_CHAT_NEW_CHAT)
        viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

        let vc = ListingsViewController.build(ListingsViewModel(category: filter, functionality: Variable(ListingsViewModelFunctionality.InitiateFromChat(channelListing: viewModel.channelListing))))
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func selectParticipantsButtonDidTap(sender: AnyObject) {
        viewModel.selectParticipantsButtonDidTap.onNext(())
    }

    // MARK:- ViewModel
    var viewModel: CreateChannelViewControllerViewModel!

    // MARK:- Constant

    // MARK:- Outlet
    var selectedFilter: Category?

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_CHAT_NEW_CHAT)
        viewModel.setAsActive()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setup() {
        self.whatToYouWantToDoLabel.text = NSLocalizedString("home_welcome_subtitle_text", comment: "")
        collectionViewHeight.constant = HomeFiltersTableViewCellViewModel.heightForFilterSection(numberOfCategories: viewModel.filters.value.count)

        collectionView.registerNib(UINib(nibName: String(CreateChannelFilterCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(CreateChannelFilterCollectionViewCell))

        viewModel
            .filters
            .asDriver()
            .filter { $0 != nil  }
            .driveNext {
                [weak self] (filters: [Category]) in
                self?.selectedFilter = self?.viewModel.filters.value[safe: 0]
                self?.collectionView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- ViewModelBinldable

extension CreateChannelViewController: ViewModelBindable {
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
            .lightHouseService
            .setViewControllerClosure
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (setViewControllerClosure: SetViewControllerClosure) in
                guard let strongSelf = self else {return}
                setViewControllerClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

        viewModel
            .startNewChat
            .drive(startNewChatLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel
            .createChannelButtonEnabled
            .driveNext { (enabled: Bool) in
                if enabled {
                    self.createChannelbgButton.backgroundColor = UIColor.favePink()
                } else {
                    self.createChannelbgButton.backgroundColor = UIColor(hexString: "#e0e5e8")
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .participants
            .drive(participantsLabel.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.offerInfo.drive(offerInfoLabel.rx_text).addDisposableTo(disposeBag)

        viewModel.offerInfoColor.driveNext { (offerInfoColor: UIColor) in self.offerInfoLabel.textColor = offerInfoColor}.addDisposableTo(disposeBag)

        viewModel.participantsColor.driveNext { (participantsColor: UIColor) in self.participantsLabel.textColor = participantsColor }.addDisposableTo(disposeBag)

    }
}

// MARK:- Buildable

extension CreateChannelViewController: Buildable {
    final class func build(builder: CreateChannelViewControllerViewModel) -> CreateChannelViewController {
        let storyboard = UIStoryboard(name: "CreateChannel", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.CreateChannelViewController) as! CreateChannelViewController
        vc.viewModel = builder
        return vc
    }
}

extension CreateChannelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filters.value.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let filter = viewModel.filters.value[indexPath.row]
        let cellViewModel = CreateChannelFilterCollectionViewModel(item: filter)

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(CreateChannelFilterCollectionViewCell), forIndexPath: indexPath) as! CreateChannelFilterCollectionViewCell
        cell.setSelectedState(filter.name == self.selectedFilter?.name)
        cell.viewModel = cellViewModel
        cell.bind()

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return sizeForItemAtIndex(indexPath.item, totalItems: viewModel.filters.value.count, collectionViewWidth: collectionView.width, itemHeight: layoutConstraint.homeCategoryItemHeight, spacing: layoutConstraint.homeCategorySpacing)
    }

    func sizeForItemAtIndex(index: Int, totalItems: Int, collectionViewWidth: CGFloat, itemHeight: CGFloat, spacing: CGFloat) -> CGSize {
        if totalItems == 2 || totalItems == 4 {
            return sizeForOneItem(forNumberOfItems: 2, collectionWidth: collectionViewWidth, itemHeight: itemHeight, spacing: spacing)
        }

        if totalItems == 3 || totalItems == 6 {
            return sizeForOneItem(forNumberOfItems: 3, collectionWidth: collectionViewWidth - 1, itemHeight: itemHeight, spacing: spacing)
        }

        if totalItems == 5 {
            if index == 0 || index == 1 {
                return sizeForOneItem(forNumberOfItems: 2, collectionWidth: collectionViewWidth, itemHeight: itemHeight, spacing: spacing)
            } else {
                return sizeForOneItem(forNumberOfItems: 3, collectionWidth: collectionViewWidth - 1, itemHeight: itemHeight, spacing: spacing)
            }
        }

        return CGSize.zero
    }

    func sizeForOneItem(forNumberOfItems totalCount: Int, collectionWidth: CGFloat, itemHeight: CGFloat, spacing: CGFloat) -> CGSize {

        let numberOfSpacing = totalCount + 1
        return CGSizeMake((collectionWidth - CGFloat(numberOfSpacing) * spacing)/CGFloat(totalCount), itemHeight)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedFilter = viewModel.filters.value[indexPath.row]

        // Update Visible Cells
        guard let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? CreateChannelFilterCollectionViewCell else {
            return
        }

        let cells = collectionView.visibleCells()
        for cell in cells {
            if let cell = cell as? CreateChannelFilterCollectionViewCell {
                cell.setSelectedState(cell == selectedCell)
            }
        }
    }

}
