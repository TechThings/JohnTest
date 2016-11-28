//
//  ViewModelBindable.swift
//
//  Created by Nazih Shoura on 01/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation

protocol ViewModelBindable {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! {get set}
}
