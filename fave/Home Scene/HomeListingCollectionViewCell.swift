//
//  HomeActivitesTableViewCell.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeListingCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var homeListingView: HomeListingView!

    // MARK:- ViewModel
    var viewModel: HomeListingCollectionViewCellViewModel! {
        didSet {
            let vm = HomeListingViewViewModel(listing: viewModel.listing)
            homeListingView.viewModel = vm
        }
    }
}

// MARK:- ViewModelBinldable
extension HomeListingCollectionViewCell: ViewModelBindable {
    func bind() {
    }
}
