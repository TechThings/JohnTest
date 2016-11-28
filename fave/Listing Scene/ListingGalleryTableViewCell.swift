//
//  ListingGalleryTableViewCell.swift
//  FAVE
//
//  Created by Kevin Mun on 26/05/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol ListingGalleryTableViewCellDelegate {
    func didTapOnImage(index: Int, imageView: UIView)
}

final class ListingGalleryTableViewCell: UITableViewCell {
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var imageCountLabel: UILabel!
    @IBOutlet weak var opacityView: UIView!

    weak var delegate: ListingGalleryTableViewCellDelegate!

    private var diffCount: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }

    func setup() {
        firstView.hidden = true
        secondView.hidden = true
        thirdView.hidden = true

        firstView.layer.cornerRadius = 2
        secondView.layer.cornerRadius = 2
        thirdView.layer.cornerRadius = 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setImages(images: [NSURL]) {
        if images.count == 0 {return}
        if images.count > 3 {
            diffCount = images.count - 3
        }
        for index in 0...images.count - 1 {
            let imageUrl = images[index]
            setDisplayImage(imageUrl, index: index)
        }
    }

    private func setDisplayImage(imageUrl: NSURL, index: Int) {
        var targetedImageView: UIImageView?
        var targetedView: UIView?

        switch index {
        case 0:
            targetedImageView = firstImageView
            targetedView = firstView
            break
        case 1:
            targetedImageView = secondImageView
            targetedView = secondView
            break
        case 2:
            targetedImageView = thirdImageView
            targetedView = thirdView
            if diffCount > 0 {
                imageCountLabel.hidden = false
                imageCountLabel.text = "+\(diffCount)"
                opacityView.hidden = false
            } else {
                imageCountLabel.hidden = true
                imageCountLabel.text = nil
                opacityView.hidden = true
            }
            break
        default:
            break
        }

        if let targetedImageView = targetedImageView, targetedView = targetedView {
            targetedView.hidden = false
            targetedImageView.kf_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "image-placeholder"), optionsInfo: [.Transition(ImageTransition.Fade(0.5))], progressBlock: nil, completionHandler: nil)
        }
    }

    @IBAction func didTapThirdImage(sender: AnyObject) {
        if let delegate = delegate {
            delegate.didTapOnImage(2, imageView: thirdView)
        }
    }

    @IBAction func didTapSecondImage(sender: AnyObject) {
        if let delegate = delegate {
            delegate.didTapOnImage(1, imageView: secondView)
        }
    }

    @IBAction func didTapFirstImage(sender: AnyObject) {
        if let delegate = delegate {
            delegate.didTapOnImage(0, imageView: firstView)
        }
    }

}
