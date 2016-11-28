//
//  TableView.swift
//  FAVE
//
//  Created by Thanh KFit on 7/22/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TableView: UITableView {

    let activityIndicator = ActivityIndicator()
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
