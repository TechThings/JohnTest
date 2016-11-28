//
//  ViewController.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import SwiftLoader

class ViewController: UIViewController {
    #if TRACE_RESOURCES
    private let startResourceCount = resourceCount
    #endif

    var disposeBag = DisposeBag()

    // TODO: Find a way to inject this
    let logger = loggerDefault
    /// Track the ViewController activities
    let networkActivityIndicator = ActivityIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()

        #if TRACE_RESOURCES
            logger.log("**********\nNumber of start resources when loading \(self.subjectLabel) = \(resourceCount)\n**********\n", loggingMode: .info, logingTags: [.memoryLeaks], shouldShowCodeLocation: false)
        #endif
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        logger.log("\(self.subjectLabel) will appear", loggingMode: .info, logingTags: [.memoryLeaks, .ui], shouldShowCodeLocation: false)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        logger.log("\(self.subjectLabel) did appear", loggingMode: .info, logingTags: [.memoryLeaks, .ui], shouldShowCodeLocation: false)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        logger.log("\(self.subjectLabel) will disappear", loggingMode: .info, logingTags: [.memoryLeaks, .ui], shouldShowCodeLocation: false)
    }

    deinit {
        logger.log("\(self.subjectLabel) will deinit", loggingMode: .info, logingTags: [.memoryLeaks, .ui], shouldShowCodeLocation: false)

        NSNotificationCenter.defaultCenter().removeObserver(self)

        #if TRACE_RESOURCES
            logger.log(message: "**********\n\(self.subjectLabel) disposed with \(resourceCount) resources\n**********\n", loggingMode: .info, logingTags: [.memoryLeaks], shouldShowCodeLocation: false)

            /*
             !!! This cleanup logic is adapted for example app use case. !!!
             
             It is being used to detect memory leaks during pre release tests.
             
             !!! In case you want to have some resource leak detection logic, the simplest
             method is just printing out `RxSwift.resourceCount` periodically to output. !!!
             
             
             /* add somewhere in
             func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
             */
             _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
             .subscribeNext { _ in
             print("Resource count \(RxSwift.resourceCount)")
             }
             
             Most efficient way to test for memory leaks is:
             * navigate to your screen and use it
             * navigate back
             * observe initial resource count
             * navigate second time to your screen and use it
             * navigate back
             * observe final resource count
             
             In case there is a difference in resource count between initial and final resource counts, there might be a memory
             leak somewhere.
             
             The reason why 2 navigations are suggested is because first navigation forces loading of lazy resources.
             */

            let numberOfResourcesThatShouldRemain = startResourceCount
            let mainQueue = dispatch_get_main_queue()
            /*
             This first `dispatch_async` is here to compensate for CoreAnimation delay after
             changing view controller hierarchy. This time is usually ~100ms on simulator and less on device.
             
             If somebody knows more about why this delay happens, you can make a PR with explanation here.
             */
            dispatch_async(mainQueue) {

                /*
                 Some small additional period to clean things up. In case there were async operations fired,
                 they can't be cleaned up momentarily.
                 */
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
                dispatch_after(time, mainQueue) {
                    // If this fails for you while testing, and you've been clicking fast, it's ok, just click slower,
                    // this is a debug build with resource tracing turned on.
                    //
                    // If this crashes when you've been clicking slowly, then it would be interesting to find out why.
                    // ¯\_(ツ)_/¯
                    assert(resourceCount <= numberOfResourcesThatShouldRemain, "Resources weren't cleaned properly")
                }
            }
        #endif
    }

    override func didReceiveMemoryWarning() {
        // CC: Replace with cashe
        OutletsMapViewModel.outletsCache = [String: [Outlet]]()
        super.didReceiveMemoryWarning()
    }
}
