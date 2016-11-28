//
//  ListingBuyNowTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 23/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import IDMPhotoBrowser

final class ListingHeaderPhotoTableViewCell: TableViewCell {

    @IBOutlet weak var photoCountView: UIView!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!

    @IBAction func headerImageButtonTapped(sender: AnyObject) {
        if viewModel.galleryImages?.count == 0 {return}

        let photoBrowser = IDMPhotoBrowser(photoURLs: viewModel.galleryImages, animatedFromView: photoCountView)
        photoBrowser.setInitialPageIndex(0)

        viewModel.lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.presentViewController(photoBrowser, animated: true, completion: nil)
        }
    }

    var viewModel: ListingHeaderPhotoTableViewCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        photoCountView.layer.cornerRadius = 3
    }
}

extension ListingHeaderPhotoTableViewCell: ViewModelBindable {
    func bind() {

        viewModel.photoUrl
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (url: NSURL?) in
                if let url = url {
                    self?.photo.kf_setImageWithURL(url, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
                } else {
                    self?.photo.image = UIImage(named: "image-placeholder")
                }

            }.addDisposableTo(rx_reusableDisposeBag)

         viewModel.photosCountText.drive(photoCountLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)
        viewModel.photosCountHidden.drive(photoCountView.rx_hidden).addDisposableTo(rx_reusableDisposeBag)
    }
}
