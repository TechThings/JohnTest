//
//  FilterSectionSingleTableViewCell.swift
//  FAVE
//
//  Created by Thanh KFit on 9/20/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

protocol FilterSectionSingleTableViewCellDelegate: class {
    func filterSectionSingleDidSelected(singleFilter: FilterSingleSelected?)
}

final class FilterSectionSingleTableViewCell: TableViewCell {
    var viewModel: FilterSectionSingleTableViewCellViewModel! {
        didSet {
            bind()
        }
    }
    weak var delegate: FilterSectionSingleTableViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
        // Initialization code
    }

    func registerCell() {
        collectionView.registerNib(UINib(nibName: literal.FilterSectionSingleCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: literal.FilterSectionSingleCollectionViewCell)
    }
}

extension FilterSectionSingleTableViewCell: UICollectionViewDelegate {

    func updateCells() {
        let cells = collectionView.visibleCells()
        for cell in cells {
            if let cell = cell as? FilterSectionSingleCollectionViewCell {
                if cell.viewModel.filterId == viewModel.selectedFilter?.data?.id {
                     cell.updateCell(true)
                } else {
                    cell.updateCell(false)
                }
            }
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.updateSelectedFilter(atIndex: indexPath.row)
        updateCells()
        delegate?.filterSectionSingleDidSelected(viewModel.selectedFilter)
    }
}

extension FilterSectionSingleTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel, let section = viewModel.section.value {
            return section.data.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let data = viewModel.section.value!.data[indexPath.row] as! FilterSectionData
        var isSelected = false
        if let selectedFilter = self.viewModel.selectedFilter?.data {
            isSelected = (data.id == selectedFilter.id)
        }
        let cellViewModel = FilterSectionSingleCollectionViewCellViewModel(isSelected: isSelected, data: data)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(literal.FilterSectionSingleCollectionViewCell, forIndexPath: indexPath) as! FilterSectionSingleCollectionViewCell
        cell.viewModel = cellViewModel
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((collectionView.width - 60)/4, collectionView.height - 24)
    }
}

extension FilterSectionSingleTableViewCell: Refreshable {
    func refresh() {
        viewModel.selectedFilter = nil
        updateCells()
    }
}

extension FilterSectionSingleTableViewCell: ViewModelBindable {
    func bind() {
        viewModel.section
            .asDriver()
            .filterNil()
            .driveNext { [weak self] _ in
                self?.collectionView.reloadData()
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.section
            .asDriver()
            .filterNil()
            .map { (filterSection) -> String in
                return (filterSection.title)
            }.drive(titleLabel.rx_text)
        .addDisposableTo(rx_reusableDisposeBag)
    }
}
