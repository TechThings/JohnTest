//
//  ChannelsTableViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 04/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SendBirdSDK

/**
 *  @author Nazih Shoura
 *
 *  ChannelsTableViewModel
 */
final class ChannelsTableViewModel: ViewModel {

    // MARK:- Dependency
    private let channelProvider: ChannelProvider
    private let messagingService: RxSendBird
    private let userProvider: UserProvider
    private let settingsProvider: SettingsProvider

    // MARK:- Variable

    //MARK:- Input

    // MARK- Output
    let sectionsModels: Driver<[ChannelsTableViewModelSectionModel]>
    let dataSource = RxTableViewSectionedReloadDataSource<ChannelsTableViewModelSectionModel>()

    init(
        channelProvider: ChannelProvider = channelProviderDefault
        , messagingService: RxSendBird = rxSendBirdDefault
        , userProvider: UserProvider = userProviderDefault
        , settingsProvider: SettingsProvider = settingsProviderDefault
        ) {
        self.channelProvider = channelProvider
        self.messagingService = messagingService
        self.userProvider = userProvider
        self.settingsProvider = settingsProvider

        self.sectionsModels = Observable.combineLatest(channelProvider.channels.asObservable()
            , settingsProvider.settings.asObservable()
        ) {
            return ($0, $1)
            }
            .map { (channels: [Channel], settings: Settings) -> [ChannelsTableViewModelSectionModel] in

                var items = [ChannelsTableViewModelSectionItem]()

                let (invitedChannels, responsedChannels) = channelProvider.filterInvitedChannels(channels, forUserWithId: userProvider.currentUser.value.id)

                if invitedChannels.isEmpty {
                    let channelsHeaderView = ChannelsTableViewModelSectionItem.ChannelsHeaderSectionItem(viewModel: ChannelsHeaderViewModel())
                    items.append(channelsHeaderView)
                } else {
                    let channelsInvitationHeaderView = ChannelsTableViewModelSectionItem.ChannelsInvitationsHeaderSectionItem(viewModel: ChannelInvitationsTableViewCellViewModel(channels: invitedChannels))
                    items.append(channelsInvitationHeaderView)

                }

                if (settings.chatCreditFeature == true) {
                    let channelCreditView =
                        ChannelsTableViewModelSectionItem
                            .ChannelCreditSectionItem(viewModel: ChannelCreditsCellViewModel())

                    items.append(channelCreditView)
                }

                let channelsItems = responsedChannels
                    .map { (channel: Channel) -> ChannelsTableViewModelSectionItem in
                        ChannelsTableViewModelSectionItem.ChannelsSectionItem(viewModel: ChannelViewModel(channel: Variable(channel)))
                }

                items.appendContentsOf(channelsItems)

                return [ChannelsTableViewModelSectionModel.ChannelsSection(items: items)]
            }
            .asDriver(onErrorJustReturn: [ChannelsTableViewModelSectionModel]())

        super.init()

        skinTableViewDataSource(dataSource)

    }

    private func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<ChannelsTableViewModelSectionModel>) {
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            switch item {
            case let .ChannelsSectionItem(viewModel):
                let cell: ChannelTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.channelView.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell
            case let .ChannelsInvitationsHeaderSectionItem(viewModel):
                let cell: ChannelInvitationsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                return cell
            case let .ChannelsHeaderSectionItem(viewModel):
                let cell: ChannelsHeaderViewTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.channelsHeaderView.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                return cell

            case let .ChannelCreditSectionItem(viewModel):

                let cell: ChannelCreditsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.viewModel = viewModel
                cell.setNeedsLayout()
                cell.layoutIfNeeded()

                return cell
            }
        }
    }
}

enum ChannelsTableViewModelSectionModel {
    case ChannelsSection(items: [ChannelsTableViewModelSectionItem])
}

extension ChannelsTableViewModelSectionModel: SectionModelType {
    typealias Item = ChannelsTableViewModelSectionItem

    var items: [ChannelsTableViewModelSectionItem] {
        switch  self {
        case .ChannelsSection(items: let items):
            return items
        }
    }

    init(original: ChannelsTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .ChannelsSection(items: _):
            self = .ChannelsSection(items: items)
        }
    }
}

enum ChannelsTableViewModelSectionItem {
    case ChannelsSectionItem(viewModel: ChannelViewModel)
    case ChannelsHeaderSectionItem(viewModel: ChannelsHeaderViewModel)
    case ChannelsInvitationsHeaderSectionItem(viewModel: ChannelInvitationsTableViewCellViewModel)
    case ChannelCreditSectionItem(viewModel: ChannelCreditsCellViewModel)
}

// MARK:- Refreshable
extension ChannelsTableViewModel: Refreshable {
    func refresh() {
        guard userProvider.currentUser.value.isGuest == false else {return}
        let response = messagingService.fetchChannelList()
            .flatMap { (messagingServiceChannels: [SendBirdMessagingChannel]) in self.channelProvider.fetchChannels(compareWithMessagingServiceChannels: messagingServiceChannels) }
            .trackActivity(app.activityIndicator)
            .trackActivity(activityIndicator)

        response
            .doOnError { [weak self] (error: ErrorType) in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController =
                        UIAlertController.alertController(forError: error, actions: nil)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            .subscribe()
            .addDisposableTo(disposeBag)

    }
}
