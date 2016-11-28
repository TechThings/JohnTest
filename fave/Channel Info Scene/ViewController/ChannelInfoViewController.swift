//
//  ChannelInfoViewController.swift
//  FAVE
//
//  Created by Michael Cheah on 8/12/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInfoViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK:- ViewModel
    var viewModel: ChannelInfoViewModel!

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("chat_info", comment: "")
        setup()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_CONVERSATION_INFO)
        viewModel.setAsActive()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    func setup() {
        //tableView.registerNib(UINib.init(nibName: literal.ChannelInfoHeaderTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInfoHeaderTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ChannelInfoFriendsHeaderTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInfoFriendsHeaderTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ChannelInfoInviteFriendsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInfoInviteFriendsTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ChannelInfoFriendTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInfoFriendTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ChannelInfoSeparatorTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInfoSeparatorTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ChannelInfoLeaveChatTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChannelInfoLeaveChatTableViewCell)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 40,right: 0)

    }

}

// MARK:- ViewModelBinldable

extension ChannelInfoViewController: ViewModelBindable {
    func bind() {

        viewModel
            .lightHouseService
            .navigate
            .filter { [weak self] _ -> Bool in
                guard let strongSelf = self else {return false}
                return strongSelf.viewModel.isActive
            }
            .subscribeNext { [weak self] (navigationClosure: NavigationClosure) in
                guard let strongSelf = self else { return }
                navigationClosure(viewController: strongSelf)
            }.addDisposableTo(disposeBag)

        viewModel
            .refreshSignal
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable

extension ChannelInfoViewController: Buildable {
    final class func build(builder: ChannelInfoViewModel) -> ChannelInfoViewController {
        let storyboard = UIStoryboard(name: "ChannelInfo", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(String(ChannelInfoViewController)) as! ChannelInfoViewController
        vc.viewModel = builder
        return vc
    }
}

extension ChannelInfoViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatInfoItem.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = viewModel.chatInfoItem[indexPath.row]
        switch item.itemType {
//        case .Header:
//            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChannelInfoHeaderTableViewCell, forIndexPath: indexPath) as! ChannelInfoHeaderTableViewCell
//            let cellViewModel = ChannelInfoHeaderTableViewCellModel.init(chatTitle: viewModel.chatTitle)
//            cell.viewModel = cellViewModel
//            cell.bind()
//            return cell
        case .FriendsHeader:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChannelInfoFriendsHeaderTableViewCell, forIndexPath: indexPath)
            return cell
        case .InviteFriend:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChannelInfoInviteFriendsTableViewCell, forIndexPath: indexPath) as! ChannelInfoInviteFriendsTableViewCell
            let cellViewModel = ChannelInfoInviteFriendsTableViewCellModel(channel: viewModel.channel, chatParticipants: (item.item as! Variable<[ChatParticipant]>))
            cell.viewModel = cellViewModel
            return cell
        case .Friend:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChannelInfoFriendTableViewCell, forIndexPath: indexPath) as! ChannelInfoFriendTableViewCell
            let cellViewModel = ChannelInfoFriendTableViewCellModel(channel: viewModel.channel, chatParticipant: Variable(item.item as! ChatParticipant))
            cell.viewModel = cellViewModel
            cell.bind()
            return cell
        case .Separator:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChannelInfoSeparatorTableViewCell, forIndexPath: indexPath)
            return cell
        case .LeaveChat:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChannelInfoLeaveChatTableViewCell, forIndexPath: indexPath)
            return cell
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = viewModel.chatInfoItem[indexPath.row]

        switch item.itemType {
        case .FriendsHeader:
            return 55
        case .Separator:
            return 15
        case .LeaveChat:
            return 50
        default:
            return UITableViewAutomaticDimension
        }
    }
}

extension ChannelInfoViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let item = viewModel.chatInfoItem[safe: indexPath.row] else { return }
        if item.itemType == ChatInfoItemKind.LeaveChat {
            let okAction = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.viewModel.leaveChatDidTap.onNext(())
                })
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil)

            let alertController = UIAlertController.alertController(forTitle: NSLocalizedString("sure_want_to_leave", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.Alert, actions: [okAction, cancelAction])
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
