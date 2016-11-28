//
//  ObjectLock.swift
//  FAVE
//
//  Created by Nazih Shoura on 19/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

func perform<T>(onLockObject lockObject: AnyObject, aClosure closure: () -> T) -> T {
    objc_sync_enter(lockObject)
    defer { objc_sync_exit(lockObject) }
    return closure()
}
