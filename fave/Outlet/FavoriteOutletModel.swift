//
// Created by Michael Cheah on 7/15/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift

final class FavoriteOutletModel: NSObject {
    let favoriteOutlet = PublishSubject<Outlet>()

    func favoriteChanged(outlet: Outlet) {
        favoriteOutlet.onNext(outlet)
    }

    func getFavoriteOutlet() -> Observable<Outlet> {
        return favoriteOutlet.asObservable()
    }
}
