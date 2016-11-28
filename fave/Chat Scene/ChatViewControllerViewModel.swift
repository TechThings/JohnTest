//
//  ChatViewControllerViewModel.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JSQMessagesViewController
import SendBirdSDK

enum ScrollingDirection {
    case None
    case Bottom(animated:Bool)
    case Top(animated:Bool)
    case Index(indexPath:NSIndexPath, animated:Bool)
}

/**
 *  @author Nazih Shoura
 *
 *  ChatViewControllerViewModel
 */

final class ChatViewControllerViewModel: ViewModel {

    private static let messagePageSize = 15
    private static let broadcasterSenderId = "broadcaster"

    // MARK:- Dependency
    let userProvider: UserProvider
    let rxSendBird: RxSendBird
    let rxAnalytics: RxAnalytics

    // MARK:- Variable

    //MARK:- Input
    let channel: Variable<Channel>

    // MARK:- Intermediate

    // MARK- Output
    let userId: Variable<String> = Variable("")
    let userName: Variable<String> = Variable("")
    let earliestMessageForPagination = Variable<SendBirdMessageModel?>(nil)
    let latestMessageForPagination = Variable<SendBirdMessageModel?>(nil)
    var currentMessages = [JSQMessage]()
    var loadingPreviousMessages = false

    //MARK:- Signal
    let messagesUpdated = PublishSubject<Bool>()
    let scrollMessagesView = PublishSubject<ScrollingDirection>()
    let inputTextChanged = PublishSubject<Bool>()
    private let markMessageReceivedRead = PublishSubject<Bool>()

    init(channel: Variable<Channel>
        , rxSendBird: RxSendBird = rxSendBirdDefault
        , userProvider: UserProvider = userProviderDefault
        , rxAnalytics: RxAnalytics = rxAnalyticsDefault
        ) {
        self.userProvider = userProvider
        self.rxSendBird = rxSendBird
        self.channel = channel
        self.rxAnalytics = rxAnalytics
        super.init()

        // userId
        userProvider
            .currentUser
            .asObservable()
            .map {
                (user: User) -> String in String(user.id)
            }
            .bindTo(userId)
            .addDisposableTo(disposeBag)

        // userName
        userProvider
            .currentUser
            .asObservable()
            .map {
                (user: User) -> String in
                if let result = user.firstName { return result } else if let result = user.name { return result } else { return "" }
            }
            .bindTo(userName)
            .addDisposableTo(disposeBag)

        // Initial messages
        self.rxSendBird.joinAndLoadInitialChat((self.channel.value.url.absoluteString!),
            count: ChatViewControllerViewModel.messagePageSize)
            .map {
                (result: (SendBirdMessagingChannel, [SendBirdMessageModel])) -> [SendBirdMessageModel] in
                // Sort Messages First
                return result.1
                    .sort {
                        (message1: SendBirdMessageModel, message2: SendBirdMessageModel) -> Bool in
                        // Sort message by earliest first until most recent
                        return message1.getMessageTimestamp() < message2.getMessageTimestamp()
                }
            }
            .doOnNext {
                [weak self] (messages: [SendBirdMessageModel]) in
                // CAVEAT: According to SendBird Documentation the count can be bigger than the limit we set
                // when the timestamps are close
                if (messages.count >= ChatViewControllerViewModel.messagePageSize) {
                    self?.earliestMessageForPagination.value = messages[safe: 0]
                } else {
                    self?.earliestMessageForPagination.value = nil
                }

                // Save the last message
                if (messages.isNotEmpty) {
                    self?.latestMessageForPagination.value = messages[safe: messages.count - 1]
                }
            }
            .map {
                (messages: [SendBirdMessageModel]) -> [JSQMessage] in
                messages
                    .map {
                        (message: SendBirdMessageModel) -> JSQMessage in
                        return ChatViewControllerViewModel.transformMessage(message)
                }
            }
            .doOnNext {
                [weak self] (jsqMessages: [JSQMessage]) in
                self?.currentMessages.appendContentsOf(jsqMessages)
                self?.messagesUpdated.onNext(true)
                self?.scrollMessagesView.onNext(ScrollingDirection.Bottom(animated: false))
            }
            .flatMap {
                [weak self] _ -> Observable<SendBirdChannel> in
                guard let strongself = self else {
                    return Observable.error(ChatError.ErrLoadChatFailed)
                }
                return strongself.rxSendBird.connect()
            }
            .timeout(15, scheduler: MainScheduler.instance)
            .doOnError {
                [weak self] _ in
                self?.lightHouseService.navigate.onNext { (viewController: UIViewController) in
                    let alertController = UIAlertController.alertController(forTitle: "Fave", message: NSLocalizedString("chat_load_fail", comment: ""))
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }

            }
            .trackActivity(app.activityIndicator)
            .subscribeNext {
                [weak self] (channel: SendBirdChannel) in
                print("Connected to Channel " + channel.url)

                // Mark Messages in this channel as read
                print("Marking Messages Read After Loading")
                guard let messagingChannel = self?.channel.value.messagingServiceChannel.value else {
                    return
                }

                self?.rxSendBird.markAsRead(messagingChannel)
            }.addDisposableTo(disposeBag)

        // Listen to user typing
        inputTextChanged
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
            .driveNext {
                [weak self] (typing: Bool) in
                self?.rxSendBird.updateTypingStatus(typing)
            }.addDisposableTo(disposeBag)

        inputTextChanged
            .asDriver(onErrorJustReturn: false)
            .filter {
                (typing: Bool) in
                return typing
            }
            .debounce(5)
            .driveNext {
                [weak self] _ in
                self?.inputTextChanged.onNext(false)
            }.addDisposableTo(disposeBag)

        markMessageReceivedRead
            .asDriver(onErrorJustReturn: false)
            .debounce(3)
            .driveNext {
                [weak self] _ in
                print("Marking Messages Read if we are active on screen")
                if let active = self?.isActive where active == true {
                    guard let messagingChannel = self?.channel.value.messagingServiceChannel.value else {
                        return
                    }

                    self?.rxSendBird.markAsRead(messagingChannel)
                }
            }.addDisposableTo(disposeBag)
    }

    var showLoadMoreHeader: Driver<Bool> {
        return earliestMessageForPagination.asDriver().map {
            (message: SendBirdMessageModel?) -> Bool in
            return message != nil
        }
    }

    var messageReceived: Driver<JSQMessage> {
        return self.rxSendBird.messageReceived.asDriver(onErrorJustReturn: SendBirdMessageModel())
            .doOnNext {
                [weak self] (message: SendBirdMessageModel) in
                self?.latestMessageForPagination.value = message
            }

            .map {
                (message: SendBirdMessageModel) -> JSQMessage in
                return ChatViewControllerViewModel.transformMessage(message)
            }
            .doOnNext {
                [weak self] (message: JSQMessage) in
                self?.currentMessages.append(message)
                if (message.isMediaMessage) {
                    // Only reload the collection view if it's a media message
                    self?.messagesUpdated.onNext(true)
                }

                if (self?.userId.value != message.senderId) {
                    // Mark received message as read
                    self?.markMessageReceivedRead.onNext(true)
                }
        }
    }

    var showTypingIndicator: Driver<Bool> {
        return Driver.of(
            self.rxSendBird.typeStartReceived
                .filter {
                    [weak self] (status: SendBirdTypeStatus) -> Bool in
                    // Don't show our own Type Status
                    return status.user.guestId != self?.userId.value
                }
                .map {
                    _ -> Bool in
                    return true
                }.asDriver(onErrorJustReturn: true),
            self.rxSendBird.typeEndReceived
                .filter {
                    [weak self] (status: SendBirdTypeStatus) -> Bool in
                    // Don't show our own Type Status
                    return status.user.guestId != self?.userId.value
                }
                .map {
                    _ -> Bool in
                    return false
                }.asDriver(onErrorJustReturn: false)).merge()
    }

    func sendMessage(text: String) {
        // Track event
        let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "send", screenName: screenName.SCREEN_CONVERSATION)
        rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

        self.rxSendBird.sendMessage(text)
        // Immediately send typing stop when message is sent
        self.rxSendBird.updateTypingStatus(false)
        self.inputTextChanged.onNext(false)
    }

    final class func transformMessage(message: SendBirdMessageModel) -> JSQMessage {
        let epochTimestamp = Double(message.getMessageTimestamp()) / 1000

        if let sendBirdMessage = message as? SendBirdMessage {
            return JSQMessage(senderId: "\(sendBirdMessage.sender.guestId)", senderDisplayName: sendBirdMessage.getSenderName(),
                              date: NSDate(timeIntervalSince1970: epochTimestamp), text: sendBirdMessage.message)
        } else if let sendBirdBroadcastMessage = message as? SendBirdBroadcastMessage {
            return JSQMessage(senderId: ChatViewControllerViewModel.broadcasterSenderId, senderDisplayName: "Broadcast Message",
                              date: NSDate(timeIntervalSince1970: epochTimestamp), text: sendBirdBroadcastMessage.message)
        } else if let sendBirdSystemMessage = message as? SendBirdSystemMessage {
            return JSQMessage(senderId: ChatViewControllerViewModel.broadcasterSenderId, senderDisplayName: "Broadcast Message",
                              date: NSDate(timeIntervalSince1970: epochTimestamp), text: sendBirdSystemMessage.message)
        } else {
            return JSQMessage(senderId: ChatViewControllerViewModel.broadcasterSenderId, senderDisplayName: "Broadcast Message",
                              date: NSDate(timeIntervalSince1970: epochTimestamp), text: "Received an unsupported message")
        }
    }

    func connect() {
        self.loadLaterMessages()
        //        This seems to cause problems when leaving / joining rapidly. disable for now and see
        //        if (self.currentMessages.isNotEmpty) {
        //            self.rxSendBird.connect()
        //            .doOnNext {
        //                [weak self] _ in
        //                return self?.loadLaterMessages()
        //            }
        //            .subscribeNext {
        //                print("Connected to Channel" + $0.description)
        //            }.addDisposableTo(disposeBag)
        //        }
    }

    var serverConnected: Driver<Bool> {
        return self.rxSendBird.serverConnected
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
    }

    func disconnect() {
        //        This seems to cause problems when leaving / joining rapidly. disable for now and see
        //        self.rxSendBird.leaveChannel(self.channel.url.absoluteString ?? "")
        //        .subscribeNext {
        //            print("Disconnected from Channel" + $0.description)
        //        }.addDisposableTo(disposeBag)
    }

    func loadLaterMessages() {
        guard let latestMessage = self.latestMessageForPagination.value else {
            return
        }

        self.rxSendBird.loadNextMessages(self.channel.value.url.absoluteString!, fromTimestamp: latestMessage.getMessageTimestamp(), count: Int.max)
            .map {
                (messages: [SendBirdMessageModel]) -> [SendBirdMessageModel] in
                // Sort Messages First
                return messages
                    .sort {
                        (message1, message2) -> Bool in
                        // Sort message by earliest first until most recent
                        return message1.getMessageTimestamp() < message2.getMessageTimestamp()
                }
            }
            .doOnNext {
                [weak self] (messages: [SendBirdMessageModel]) in
                if (messages.isNotEmpty) {
                    self?.latestMessageForPagination.value = messages[safe: messages.count - 1]
                }
            }
            .map {
                (messages: [SendBirdMessageModel]) -> [JSQMessage] in
                messages
                    .map {
                        (message: SendBirdMessageModel) -> JSQMessage in
                        return ChatViewControllerViewModel.transformMessage(message)
                }
            }
            .doOnNext {
                [weak self] (jsqMessages: [JSQMessage]) in
                guard let strongself = self else {
                    return
                }

                // Append to the back of the current messages, and update collection view
                strongself.currentMessages = strongself.currentMessages + jsqMessages
                strongself.messagesUpdated.onNext(true)
            }
            .doOnError {
                _ in
                print("Error loading next messages")
            }
            .trackActivity(app.activityIndicator)
            .subscribeNext {
                [weak self] (messages: [JSQMessage]) in
                print("Next messages loaded")
                guard let strongself = self else {
                    return
                }

                // Send Scrolling Signal
                // Try to make sure that we scroll smoothly to the new messages when possible
                if (messages.count > 3) {
                    self?.scrollMessagesView.onNext(.Index(indexPath: NSIndexPath(forItem: strongself.currentMessages.count - messages.count + 1, inSection: 0), animated: false))
                    self?.scrollMessagesView.onNext(.Index(indexPath: NSIndexPath(forItem: strongself.currentMessages.count - messages.count + 3, inSection: 0), animated: true))
                } else {
                    self?.scrollMessagesView.onNext(.Bottom(animated: true))
                }

                // Mark new loaded Messages in this channel as read
                print("Marking Messages Read After Loading")
                guard let messagingChannel = self?.channel.value.messagingServiceChannel.value else {
                    return
                }

                strongself.rxSendBird.markAsRead(messagingChannel)
            }.addDisposableTo(disposeBag)
    }

    func loadEarlierMessages() {
        if (self.loadingPreviousMessages) {
            return
        }

        self.loadingPreviousMessages = true

        guard let earliestMessage = self.earliestMessageForPagination.value else {
            return
        }

        let channelString = self.channel.value.url.absoluteString.emptyOnNil

        self.rxSendBird.loadPreviousMessages(channelString(), fromTimestamp: earliestMessage.getMessageTimestamp(), count: ChatViewControllerViewModel.messagePageSize)
            .map {
                (messages: [SendBirdMessageModel]) in
                // Sort Messages First
                return messages
                    .sort {
                        (message1, message2) -> Bool in
                        // Sort message by earliest first until most recent
                        return message1.getMessageTimestamp() < message2.getMessageTimestamp()
                }
            }
            .doOnNext {
                [weak self] (messages: [SendBirdMessageModel]) in
                // CAVEAT: According to SendBird Documentation the count can be bigger than the limit we set
                // when the timestamps are close
                if (messages.count >= ChatViewControllerViewModel.messagePageSize) {
                    self?.earliestMessageForPagination.value = messages[safe: 0]
                } else {
                    self?.earliestMessageForPagination.value = nil
                }
            }
            .map {
                (messages: [SendBirdMessageModel]) -> [JSQMessage] in
                messages
                    .map {
                        (message: SendBirdMessageModel) -> JSQMessage in
                        return ChatViewControllerViewModel.transformMessage(message)
                }
            }
            .doOnNext {
                [weak self] (jsqMessages: [JSQMessage]) in
                guard let strongself = self else {
                    return
                }

                // Append to the front of the current messages, and update collection view
                strongself.currentMessages = jsqMessages + strongself.currentMessages
                strongself.messagesUpdated.onNext(true)
            }
            .doOnError {
                [weak self] _ in
                self?.loadingPreviousMessages = false
            }
            .subscribeNext {
                [weak self] (messages: [JSQMessage]) in
                print("Previous messages loaded")
                self?.loadingPreviousMessages = false

                // Send Scrolling Signal
                // Try to make sure that we scroll smoothly to the new messages when possible
                if (messages.count > 3) {
                    self?.scrollMessagesView.onNext(.Index(indexPath: NSIndexPath(forItem: messages.count - 1, inSection: 0), animated: false))
                    self?.scrollMessagesView.onNext(.Index(indexPath: NSIndexPath(forItem: messages.count - 3, inSection: 0), animated: true))
                } else {
                    self?.scrollMessagesView.onNext(.Top(animated: true))
                }
            }.addDisposableTo(disposeBag)
    }
}

extension JSQMessage {
    var isBroadcast: Bool {
        return self.senderId == ChatViewControllerViewModel.broadcasterSenderId
    }
}

enum ChatError: DescribableError {
    case ErrLoadChatFailed

    var description: String {
        switch self {
        case .ErrLoadChatFailed:
            return "Loading chat failed"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .ErrLoadChatFailed: return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }
}
