//
//  HomeOffersCarouselTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeOffersCarouselTableViewCell: TableViewCell {
    var viewModel: HomeOffersCarouselTableViewCellViewModel! {
        didSet { bind() }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!

    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottom: NSLayoutConstraint!

    func setup() {
        collectionView.registerNib(UINib(nibName: literal.HomeListingCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: literal.HomeListingCollectionViewCell)
    }

    override func awakeFromNib() {
        setup()
    }

    override func prepareForReuse() {
        activityIndicator.hidden = viewModel.activityIndicatorHidden.value
    }
}

extension HomeOffersCarouselTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel, let listingsModel = viewModel.listings.value {
            return listingsModel.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellViewModel = HomeListingCollectionViewCellViewModel(listing: viewModel.listings.value![indexPath.row])

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(literal.HomeListingCollectionViewCell, forIndexPath: indexPath) as! HomeListingCollectionViewCell
        cell.viewModel = cellViewModel
        cell.bind()
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.width*0.8, 260)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.didSelectItemAtIndex(indexPath.item)
    }
}

extension HomeOffersCarouselTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .sectionModel
            .driveNext { [weak self] sectionModel in
                self?.titleLabel.text = sectionModel?.name
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel
            .listings
            .asDriver()
            .filterNil()
            .driveNext { [weak self] (listings) in
                self?.collectionView.reloadData()
                if listings.count == 0 {
                    self?.titleViewHeight.constant = 0
                    self?.collectionViewHeight.constant = 1
                    self?.collectionViewBottom.constant = 0
                } else {
                    self?.titleViewHeight.constant = 50
                    self?.collectionViewHeight.constant = 260
                    self?.collectionViewBottom.constant = 10
                }
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.activityIndicatorHidden.asDriver().drive(activityIndicator.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
    }
}
