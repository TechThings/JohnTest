////
////  ActivityGeneralSectionFooter.swift
////  FAVE
////
////  Created by Kevin Mun on 23/05/2016.
////  Copyright © 2016 kfit. All rights reserved.
////
//
//import UIKit
//
//@objc protocol ActivityGeneralSectionFooterDelegate {
//    func didTapSectionButton(section:Int, sender:AnyObject)
//}
//
//class ActivityGeneralSectionFooter: UIView {
//
//    @IBOutlet weak var sectionButton: UIButton!
//    weak var delegate: ActivityGeneralSectionFooterDelegate!
//    var section: Int = 0
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
//        let view = NSBundle.mainBundle().loadNibNamed(String(ActivityGeneralSectionFooter), owner: self, options: nil)[0] as! UIView
//        view.frame = self.bounds
//        self.addSubview(view)
//    }
//    
//    @IBAction func didTapSectionButton(sender: AnyObject) {
//        if let delegate = delegate {
//            delegate.didTapSectionButton(section, sender: sender)
//        }
//    }
//
//}
