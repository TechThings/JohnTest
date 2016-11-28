//
//  HomeFiltersTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeFiltersTableViewCell: TableViewCell {
    // MARK:- ViewModel
    var viewModel: HomeFiltersTableViewCellViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        collectionView.registerNib(UINib(nibName: String(HomeFilterCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(HomeFilterCollectionViewCell))
        selectionStyle = .None
    }
}

// MARK:- ViewModelBinldable
extension HomeFiltersTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .filters
            .asDriver()
            .driveNext({ [weak self] _ in
                self?.collectionView.reloadData()
            }).addDisposableTo(rx_reusableDisposeBag)

        viewModel.filters
            .asObservable()
            .map { (filters) -> Bool in
                return filters.count > 0
            }.asDriver(onErrorJustReturn: true)
            .drive(activityIndicator.rx_hidden)
            .addDisposableTo(rx_reusableDisposeBag)

    }
}

extension HomeFiltersTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.filters.value.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellViewModel = HomeFilterCollectionViewCellViewModel(item: viewModel.filters.value[indexPath.row])

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(HomeFilterCollectionViewCell), forIndexPath: indexPath) as! HomeFilterCollectionViewCell

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
        viewModel.didSelectItemAtIndex(indexPath.item)
    }
}
