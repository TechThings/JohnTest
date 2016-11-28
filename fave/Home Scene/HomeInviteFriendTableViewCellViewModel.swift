//
//  HomeInviteFriendTableViewCellViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/26/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 *  @author Thanh KFit
 *
 *  HomeInviteFriendTableViewCellViewModel
 */
final class HomeInviteFriendTableViewCellViewModel: ViewModel {

    // MARK:- Signal
    let openCreditButtonDidTap = PublishSubject<()>()

    init(
        ) {
        super.init()
        openCreditButtonDidTap.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                let vm = CreditViewModel()
                let vc = CreditViewController.build(vm)
                viewController.navigationController?.pushViewController(vc, animated: true)
            })
        }.addDisposableTo(disposeBag)
    }
}
