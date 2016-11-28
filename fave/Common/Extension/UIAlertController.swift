//
//  UIAlertController+Error.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

extension UIAlertController {
    final class func alertController(forError error: ErrorType, actions: [UIAlertAction]? = nil) -> UIAlertController {
        let errorDescription = { () -> String in
            if let describableError = error as? DescribableError {
                let errorDescription = describableError.userVisibleDescription
                return errorDescription
            }
            if (error as NSError).localizedDescription != "" {
                let errorDescription = (error as NSError).localizedDescription
                return errorDescription
            }
            return NSLocalizedString("msg_something_wrong", comment:"")
        }()

        let errorString = "FAVE"
        return alertController(forTitle: errorString, message: errorDescription, preferredStyle: .Alert, actions: actions)
    }

    final class func alertController(forTitle title: String, message: String, preferredStyle: UIAlertControllerStyle = .Alert, actions: [UIAlertAction]? = nil) -> UIAlertController {

        let actionsToAdd: [UIAlertAction] = {
            if actions != nil {
                return actions!
            } else {
                let okAction = UIAlertAction(title: NSLocalizedString("msg_dialog_ok", comment: ""), style: .Cancel, handler: nil)
                return [okAction]
            }
        }()

        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actionsToAdd {
            alertController.addAction(action)
        }

        return alertController
    }

}

extension UIAlertController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    public override func shouldAutorotate() -> Bool {
        return false
    }
}
