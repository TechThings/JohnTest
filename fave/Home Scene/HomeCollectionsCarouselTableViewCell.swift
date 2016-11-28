//
//  HomeCollectionsCarouselTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeCollectionsCarouselTableViewCell: TableViewCell {
    var viewModel: HomeCollectionsCarouselTableViewCellViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: ActivityIndicatorView!

    @IBOutlet weak var viewAllButton: UIButton!
    func setup() {
        collectionView.registerNib(UINib(nibName: String(HomeListingsCollectionCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(HomeListingsCollectionCollectionViewCell))
        collectionView.contentInset = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        self.viewAllButton.setTitle(NSLocalizedString("activity_detail_view_all_text", comment: ""), forState: .Normal)

    }

    override func awakeFromNib() {
        setup()
    }

    @IBAction func didTapViewAllButton(sender: AnyObject) {
        viewModel.viewAllItems()
    }

}

extension HomeCollectionsCarouselTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.listingsCollections.value.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellViewModel = HomeListingsCollectionCollectionViewCellViewModel(item: viewModel.listingsCollections.value[indexPath.row])

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(HomeListingsCollectionCollectionViewCell), forIndexPath: indexPath) as! HomeListingsCollectionCollectionViewCell

        cell.viewModel = cellViewModel
        cell.bind()

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.width*0.8, collectionView.height)
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.didSelectItemAtIndex(indexPath.item)
    }
}

extension HomeCollectionsCarouselTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.sectionModel
            .asDriver()
            .driveNext { [weak self] sectionModel in
                self?.titleLabel.text = sectionModel?.name
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.listingsCollections
            .asDriver()
            .driveNext { [weak self] _ in
                self?.collectionView.reloadData()
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.activityIndicatorHidden.asDriver().drive(activityIndicator.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
    }
}
