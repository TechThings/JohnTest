//
//  Concealable.swift
//
//  Created by Nazih Shoura on 02/06/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

protocol Concealable {
    var concealed: Variable<Bool> {get set}
    func conceal()
    func conceal(animateWithDuration duration: NSTimeInterval, complition: ((Bool) -> Void)?)
    func unconceal()
    func unconceal(animateWithDuration duration: NSTimeInterval, complition: ((Bool) -> Void)?)
}
