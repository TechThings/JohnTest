//
//  ObservableConvertibleType+Void.swift
//  FAVE
//
//  Created by Nazih Shoura on 19/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import RxCocoa
import RxSwift

extension ObservableConvertibleType where E == Void {

    func asDriver() -> Driver<E> {
        return self.asDriver(onErrorJustReturn: Void())
    }

}
