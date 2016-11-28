////
////  ActivityHeaderView.swift
////  FAVE
////
////  Created by Kevin Mun on 30/05/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//
//class ActivityHeaderView: UIView {
//
//    @IBOutlet weak var contentImage: UIImageView!
//    
//    // MARK: Initilization
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        load()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        load()
//    }
//    
//    private func load() {
//        let view = NSBundle.mainBundle().loadNibNamed(String(ActivityHeaderView), owner: self, options: nil)[0] as! UIView
//        view.frame = self.bounds
//        self.addSubview(view)
//    }
//    
//    func setDisplayImage(imageUrl:NSURL?) {
//        if let imageUrl = imageUrl {
//            self.contentImage.sd_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "default_image"))
//        }
//    }
//}
