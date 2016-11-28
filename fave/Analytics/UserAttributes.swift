//
// Created by Michael Cheah on 7/26/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation

class UserAttributes {

    let user: User
    let city: City?

    init(user: User,
         city: City?) {
        self.user = user
        self.city = city
    }

    var id: String {
        return String(self.user.id)
    }

    var name: String? {
        return self.user.name
    }

    var email: String? {
        return self.user.email
    }

    var cityName: String? {
        return self.city?.name
    }

    var gender: String? {
        guard let gender = user.gender where gender != .NotSpecify else {
            return nil
        }

        return gender.rawValue
    }
}
