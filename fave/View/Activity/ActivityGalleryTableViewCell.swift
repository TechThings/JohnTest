////
////  ActivityGalleryTableViewCell.swift
////  FAVE
////
////  Created by Kevin Mun on 26/05/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//
//@objc protocol ActivityGalleryTableViewCellDelegate {
//    func didTapOnImage(index:Int)
//}
//
//class ActivityGalleryTableViewCell: UITableViewCell {
//    @IBOutlet weak var firstView: UIView!
//    @IBOutlet weak var secondView: UIView!
//    @IBOutlet weak var thirdView: UIView!
//    
//    @IBOutlet weak var firstImageView: UIImageView!
//    @IBOutlet weak var secondImageView: UIImageView!
//    @IBOutlet weak var thirdImageView: UIImageView!
//    @IBOutlet weak var imageCountLabel: UILabel!
//    
//    weak var delegate:ActivityGalleryTableViewCellDelegate!
//    
//    private var diffCount:Int = 0
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        setup()
//    }
//    
//    func setup() {
//        firstView.hidden = true
//        secondView.hidden = true
//        thirdView.hidden = true
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//    func setImages(images:[NSURL]) {
//        let minCount = min(3, images.count)
//        if minCount > 3 {
//            diffCount = images.count - 3
//        }
//        for index in 0...minCount-1 {
//            let imageUrl = images[index]
//            setDisplayImage(imageUrl, index: index)
//        }
//    }
//    
//    private func setDisplayImage(imageUrl:NSURL, index:Int) {
//        var targetedImageView: UIImageView?
//        var targetedView: UIView?
//        
//        switch index {
//        case 0:
//            targetedImageView = firstImageView
//            targetedView = firstView
//            break
//        case 1:
//            targetedImageView = secondImageView
//            targetedView = secondView
//            break
//        case 2:
//            targetedImageView = thirdImageView
//            targetedView = thirdView
//            if diffCount > 0 {
//                imageCountLabel.hidden = false
//                imageCountLabel.text = "+\(diffCount)"
//            } else {
//                imageCountLabel.hidden = true
//                imageCountLabel.text = nil
//            }
//            break
//        default:
//            break
//        }
//        
//        if let targetedImageView = targetedImageView, targetedView = targetedView {
//            targetedView.hidden = false
//            targetedImageView.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "default_image"))
//        }
//    }
//    
//    @IBAction func didTapThirdImage(sender: AnyObject) {
//        if let delegate = delegate {
//            delegate.didTapOnImage(2)
//        }
//    }
//    
//    @IBAction func didTapSecondImage(sender: AnyObject) {
//        if let delegate = delegate {
//            delegate.didTapOnImage(1)
//        }
//    }
//    
//    @IBAction func didTapFirstImage(sender: AnyObject) {
//        if let delegate = delegate {
//            delegate.didTapOnImage(0)
//        }
//    }
//    
//}
