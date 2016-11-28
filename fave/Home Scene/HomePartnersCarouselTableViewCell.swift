//
//  HomePartnersCarouselTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomePartnersCarouselTableViewCell: TableViewCell {
    var viewModel: HomePartnersCarouselTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!

    @IBOutlet weak var viewAllButton: UIButton!
    func setup() {
        collectionView.registerNib(UINib(nibName: String(HomeOutletCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(HomeOutletCollectionViewCell))
        self.viewAllButton.setTitle(NSLocalizedString("activity_detail_view_all_text", comment: ""), forState: .Normal)

    }

    override func awakeFromNib() {
        setup()
    }

    @IBAction func didTapViewAllButton(sender: AnyObject) {
        viewModel.viewAllItems()
    }
}

extension HomePartnersCarouselTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.outlets.value.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(HomeOutletCollectionViewCell), forIndexPath: indexPath) as! HomeOutletCollectionViewCell

        let outlet = viewModel.outlets.value[indexPath.row]

        let cellViewModel = OutletsSearchTableViewCellModel(outlet: outlet, company: outlet.company!)
        cell.viewModel = cellViewModel
        cell.bind()
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 220, height: 240)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.didSelectItemAtIndex(indexPath.item)
    }
}

extension HomePartnersCarouselTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .sectionModel
            .filterNil()
            .map { (homeSection: HomeSection) -> String in
                return homeSection.name
            }
            .asDriver()
            .drive(titleLabel.rx_text)
            .addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .outlets
            .asDriver()
            .driveNext { [weak self] _ in
                self?.collectionView.reloadData()
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .activityIndicatorHidden
            .asDriver()
            .drive(activityIndicator.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)
    }
}
