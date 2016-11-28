//
//  Avatarable.swift
//  FAVE
//
//  Created by Nazih Shoura on 23/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol Avatarable {
    var imageURL: NSURL? {get}
    var firstLetter: Character {get}
    var lastLetter: Character? {get}
    var participationStatus: UserParticipationStatus {get}
}
