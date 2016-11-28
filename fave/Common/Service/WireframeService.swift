//
//  Wireframe.swift
//
//  Created by Nazih Shoura on 08/05/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import UIKit
import Alexandria

protocol WireframeService {
    /**
     open the passed URL
     
     - author: Nazih Shoura
     
     - parameter URL: The URL to be opened
     */
    func openURL(URL: NSURL)

    /**
     Show an alert controller
     
     - author: Nazih Shoura
     
     - parameter title:   The title of the alert controller
     - parameter message: The message of the alert controller
     - parameter actions: The array of the alert actions to configure the UIAlertController with
     */
    func alertFor(title title: String, message: String, preferredStyle: UIAlertControllerStyle, actions: [UIAlertAction]?)

    func alertFor(error: ErrorType, actions: [UIAlertAction]?)

}

final class WireframeServiceDefault: Service, WireframeService {

    init() {
        super.init()
    }

    func openURL(URL: NSURL) {
        UIApplication.sharedApplication().openURL(URL)
    }

    func alertFor(title title: String, message: String, preferredStyle: UIAlertControllerStyle = .Alert, actions: [UIAlertAction]? = nil) {

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
        if NSThread.isMainThread() {
            UIViewController.currentViewController?.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                UIViewController.currentViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    func alertFor(error: ErrorType, actions: [UIAlertAction]? = nil) {
        let errorDescription = (error as NSError).localizedDescription ?? NSLocalizedString("msg_something_wrong", comment:"")
        let errorString = NSLocalizedString("Fave", comment: "")
        alertFor(title: errorString, message: errorDescription, preferredStyle: .Alert, actions: actions)
    }
}
