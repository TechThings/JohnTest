//
//  HomeListingsCollectionsTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/1/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeListingsCollectionsTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: HomeListingsCollectionsTableViewCellViewModel!

    // MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewAllListingsCollectionsButton: UIButton!
    @IBAction func HomeListingsCollectionsTableViewCell(sender: UIButton) {
        let vc = ListingsCollectionsViewController.build(ListingsCollectionsViewControllerViewModel())
        self.delegate?.pushViewController(vc)
    }

    var delegate: OutletsSearchTableViewCellModelDelegate?

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        collectionView.registerNib(UINib(nibName: String(HomeListingsCollectionCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(HomeListingsCollectionCollectionViewCell))
        collectionView.contentInset = UIEdgeInsets(top: 0,left: 15,bottom: 0,right: 15)
        self.viewAllListingsCollectionsButton.setTitle(NSLocalizedString("activity_detail_view_all_text", comment: ""), forState: .Normal)

    }
}

// MARK:- ViewModelBinldable
extension HomeListingsCollectionsTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.items
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.collectionView.reloadData()
            }.addDisposableTo(rx_reusableDisposeBag)
    }
}

extension HomeListingsCollectionsTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.items.value.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellViewModel = HomeListingsCollectionCollectionViewCellViewModel(item: viewModel.items.value[indexPath.row])

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(HomeListingsCollectionCollectionViewCell), forIndexPath: indexPath) as! HomeListingsCollectionCollectionViewCell

        cell.viewModel = cellViewModel
        cell.bind()

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.width*0.8, collectionView.height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let viewModel = viewModel {
            if viewModel.items.value.count > 0 {
                return CGSize.zero
            } else {
                return collectionView.size
            }
        }
        return CGSize.zero
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = ListingsCollectionViewController.build(ListingsCollectionViewControllerViewModel(collectionId: viewModel.items.value[indexPath.row].id))

        delegate?.pushViewController(vc)
    }
}
