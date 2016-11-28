////
////  ActivityGeneralSectionHeader.swift
////  FAVE
////
////  Created by Kevin Mun on 23/05/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//
//class ActivityGeneralSectionHeader: UIView {
//
//    @IBOutlet weak var headerImage: UIImageView!
//    @IBOutlet weak var headerTitle: UILabel!
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
//        let view = NSBundle.mainBundle().loadNibNamed(String(ActivityGeneralSectionHeader), owner: self, options: nil)[0] as! UIView
//        view.frame = self.bounds
//        self.addSubview(view)
//    }
//
//
//}
