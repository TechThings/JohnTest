//
//  FilterCategoriesTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 7/25/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

protocol FilterCategoriesTableViewCellDelegate: class {
    func filterCategoriesDidSelected(categories categories: [SubCategory])
}

final class FilterCategoriesTableViewCell: TableViewCell {

    let sizeOfACaterogiesCell = (UIScreen.mainWidth - 60)/5

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: FilterCategoriesTableViewCellDelegate?

    var viewModel: FilterCategoriesCellViewModel! {
        didSet {
            bind()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.registerNib(UINib(nibName: String(FilterCategoryCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(FilterCategoryCollectionViewCell))
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

extension FilterCategoriesTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel == nil ? 0 : 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(sizeOfACaterogiesCell, sizeOfACaterogiesCell + 15)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let category = viewModel.categories[indexPath.row]
        let isSelected = viewModel.selectedCategories.map({return $0.id}).contains(viewModel.categories[indexPath.row].id)
        let cellViewModel = FilterCategoryCollectionViewCellViewModel(category: category, isSelected: isSelected)

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(FilterCategoryCollectionViewCell), forIndexPath: indexPath) as! FilterCategoryCollectionViewCell
        cell.viewModel = cellViewModel
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Update Visible Cells
        guard let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCategoryCollectionViewCell else {
            return
        }

        selectedCell.updateSelected()

        viewModel.didSeletectCategory(viewModel.categories[indexPath.row])
        if let delegate = delegate {
            delegate.filterCategoriesDidSelected(categories: viewModel.selectedCategories)
        }
    }
}

extension FilterCategoriesTableViewCell: Refreshable {

    func refresh() {
        viewModel.selectedCategories = []
        collectionView.reloadData()
    }
}

extension FilterCategoriesTableViewCell : ViewModelBindable {
    func bind() {
        self.collectionView.reloadData()
    }
}
