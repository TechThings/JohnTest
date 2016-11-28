//
//  ParticipantsViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 23/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Nazih Shoura
 *
 *  ParticipantsViewModel
 */
final class ParticipantsViewModel: ViewModel {

    // MARK:- Variable

    //MARK:- Input
    let avatars: Variable<[Avatarable]>

    // MARK:- Intermediate

    // MARK- Output

    init(
        avatars: Variable<[Avatarable]>
        ) {
        self.avatars = avatars
        super.init()

    }
}
