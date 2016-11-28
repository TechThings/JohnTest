////
//// Created by Michael Cheah on 7/11/16.
//// Copyright (c) 2016 kfit. All rights reserved.
////
//
//import Foundation
//import Braintree
//
//final class CompletingBTDropInViewController: BTDropInViewController {
//
//    var completion: (() -> Void)?
//
//    init(APIClient: BTAPIClient, completion: (() -> Void)?) {
//        super.init(APIClient: APIClient)
//
//        self.completion = completion
//    }
//
//    override init(nibName nibNameOrNil: String?,
//                  bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    func viewControllerCancelClicked() {
//        if let completionHandler = self.completion {
//            completionHandler()
//        }
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//}
