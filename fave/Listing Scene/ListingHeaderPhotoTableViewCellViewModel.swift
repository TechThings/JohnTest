//
//  ListingBuyNowTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 7/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingHeaderPhotoTableViewCellViewModel: ViewModel {

    let photoUrl = Variable<NSURL?>(nil)
    let photosCountText: Driver<String>
    let photosCountHidden: Driver<Bool>

    let galleryImages: [NSURL]?

    init(listing: ListingType) {
        galleryImages = listing.galleryImages
        photoUrl.value = listing.featuredImage
        photosCountText = Driver.of(String(format:NSLocalizedString("offer_photo_count", comment: ""), listing.galleryImages.count))
        photosCountHidden = Driver.of(listing.galleryImages.count == 0)
        super.init()
    }
}
