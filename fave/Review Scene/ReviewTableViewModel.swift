//
//  ReviewTableViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/11/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/**
 *  @author Thanh KFit
 *
 *  ReviewTableViewModel
 */
final class ReviewTableViewModel: ViewModel {

    // MARK:- Dependency
    private let reviewsAPI: ReviewsAPI

    //MARK:- Input
    let companyId: Int

    // MARK:- Intermediate
    private let reviews = Variable([Review]())

    // MARK- Output
    let sectionsModels: Driver<[ReviewTableViewModelSectionModel]>
    let dataSource = RxTableViewSectionedReloadDataSource<ReviewTableViewModelSectionModel>()

    init(
        reviewsAPI: ReviewsAPI = ReviewsAPIDefault()
        , companyId: Int
        ) {
        self.reviewsAPI = reviewsAPI
        self.companyId = companyId

        self.sectionsModels = reviews
            .asObservable()
            .map { (reviews: [Review]) -> [ReviewTableViewModelSectionModel] in
                let items = reviews
                    .map { (review: Review) -> ReviewTableViewModelSectionItem in
                        ReviewTableViewModelSectionItem.ReviewSectionItem(viewModel: ListingReviewTableViewCellViewModel(review: review))
                }

                return [ReviewTableViewModelSectionModel.ReviewSection(items: items)]
            }
            .asDriver(onErrorJustReturn: [ReviewTableViewModelSectionModel]())
            .startWith([ReviewTableViewModelSectionModel]())

        super.init()

        skinTableViewDataSource(dataSource)
    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<ReviewTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .ReviewSectionItem(viewModel):
                let cell: ListingReviewTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
            }
        }
    }
}

// MARK:- Refreshable
extension ReviewTableViewModel: Refreshable {
    func refresh() {
        let response = reviewsAPI
            .getReviews(withRequestPayload: ReviewsAPIRequestPayload(companyId: companyId))

        response
            .trackActivity(activityIndicator)
            .trackActivity(app.activityIndicator)
            .doOnError({ [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext({ (viewController: UIViewController) in
                    viewController.presentViewController(UIAlertController.alertController(forError: error, actions: nil), animated: true, completion: nil)
                })
                })
            .map({ (reviewsAPIResponsePayload: ReviewsAPIResponsePayload) -> [Review] in
                return reviewsAPIResponsePayload.reviews
            })
            .bindTo(reviews)
            .addDisposableTo(disposeBag)

    }
}

enum ReviewTableViewModelSectionModel {
    case ReviewSection(items: [ReviewTableViewModelSectionItem])
}

extension ReviewTableViewModelSectionModel: SectionModelType {
    typealias Item = ReviewTableViewModelSectionItem

    var items: [ReviewTableViewModelSectionItem] {
        switch  self {
        case .ReviewSection(items: let items):
            return items
        }
    }

    init(original: ReviewTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .ReviewSection(items: _):
            self = .ReviewSection(items: items)
        }
    }
}

enum ReviewTableViewModelSectionItem {
    case ReviewSectionItem(viewModel: ListingReviewTableViewCellViewModel)
}
