//
// Created by Michael Cheah on 8/2/16.
// Copyright (c) 2016 kfit. All rights reserved.
//

import Foundation
import RxSwift
import SendBirdSDK

/*

Rough guide for using this final class.
You must call login() first.
You must call connect() after joinAndLoadInitialChat() before you can send / receive any message

    rxSendBirdDefault.login()
    .flatMap {
        _ in
        return rxSendBirdDefault.fetchChannelList()
    }
    .flatMap {
        (channels: [SendBirdMessagingChannel]) in
        return rxSendBirdDefault.joinAndLoadInitialChat(channels.first!.getUrl())
    }
    .doOnNext {
        (models: [SendBirdMessageModel]) in
        print("Models" + models.description)
    }
    .flatMap {
        _ in
        return rxSendBirdDefault.connect()
    }
    .subscribeNext {
        print("Channel" + $0.description)
    }
*/

protocol RxSendBird {

    var sendBirdError: PublishSubject<SendBirdError?> { get }

    var messagingStarted: PublishSubject<SendBirdMessagingChannel> { get }

    var messagingChannelUpdated: PublishSubject<SendBirdMessagingChannel> { get }

    var messagingEnded: PublishSubject<SendBirdMessagingChannel> { get }

    var channelConnected: PublishSubject<SendBirdChannel> { get }

    var messageReceived: PublishSubject<SendBirdMessageModel> { get }

    var typeStartReceived: PublishSubject<SendBirdTypeStatus> { get }

    var typeEndReceived: PublishSubject<SendBirdTypeStatus> { get }

    var channelLeft: PublishSubject<SendBirdChannel> { get }

    var serverConnected: PublishSubject<Bool> { get }

    func initAppId()

    func registerForRemoteNotifications(deviceToken: NSData)

    func login() -> Observable<SendBirdChannel>

    func logout()

    func connect() -> Observable<SendBirdChannel>

    func isConnected() -> Bool

    func joinChannel(channelUrl: String)

    func joinDefaultChannel()

    func joinMessagingChannel(channelUrl: String) -> Observable<SendBirdMessagingChannel>

    func fetchChannelList() -> Observable<[SendBirdMessagingChannel]>

    func startMessaging(userIds: [String]) -> Observable<SendBirdMessagingChannel>

    func inviteMessagingWithChannelUrl(channelUrl: String, userIds: [String]) -> Observable<SendBirdMessagingChannel>

    func markAsRead(channel: SendBirdMessagingChannel)

    func loadInitialMessages(channelUrl: String, count: Int) -> Observable<[SendBirdMessageModel]>

    func loadPreviousMessages(channelUrl: String, fromTimestamp: Int64, count: Int) -> Observable<[SendBirdMessageModel]>

    func loadNextMessages(channelUrl: String, fromTimestamp: Int64, count: Int) -> Observable<[SendBirdMessageModel]>

    func joinAndLoadInitialChat(channelUrl: String, count: Int) -> Observable<(SendBirdMessagingChannel, [SendBirdMessageModel])>

    func sendMessage(message: String)

    func updateTypingStatus(typing: Bool)

    // This one just disconnect from the channel. You are still in the channel
    func leaveChannel(channelUrl: String) -> Observable<SendBirdChannel>

    // This one remove you from the channel!
    func endMessagingWithChannelUrl(channelUrl: String) -> Observable<SendBirdMessagingChannel>

    func parsePushNotificationForDeepLink(userInfo: [NSObject : AnyObject]) -> LinkModel?
}

final class RxSendBirdDefault: RxSendBird {

    // MARK:- Dependancy
    private let userProvider: UserProvider
    private let channelProvider: ChannelProvider

    // MARK:- Output
    var sendBirdError = PublishSubject<SendBirdError?>()
    var messagingStarted = PublishSubject<SendBirdMessagingChannel>()
    var messagingChannelUpdated = PublishSubject<SendBirdMessagingChannel>()
    var messagingEnded = PublishSubject<SendBirdMessagingChannel>()
    var channelConnected = PublishSubject<SendBirdChannel>()
    var messageReceived = PublishSubject<SendBirdMessageModel>()
    var typeStartReceived = PublishSubject<SendBirdTypeStatus>()
    var typeEndReceived = PublishSubject<SendBirdTypeStatus>()
    var channelLeft = PublishSubject<SendBirdChannel>()
    var serverConnected = PublishSubject<Bool>()

    init(userProvider: UserProvider = userProviderDefault,
         channelProvider: ChannelProvider = channelProviderDefault) {
        self.userProvider = userProvider
        self.channelProvider = channelProvider
    }

    func initAppId() {
        SendBird.initAppId(appDefault.keys.SendBirdAppId)
    }

    func registerForRemoteNotifications(deviceToken: NSData) {
        SendBird.registerForRemoteNotifications(deviceToken)
    }

    func login() -> Observable<SendBirdChannel> {
        return self.userProvider.currentUser.asObservable()
        .filter {
            (user: User) -> Bool in
            !user.isGuest
        }
        .doOnNext {
            (user: User) in
            let safeName: String
            if let name = user.name {
                safeName = name
            } else {
                safeName = ""
            }

            let safeImageUrl = (user.profileImageURL?.absoluteString).emptyOnNil()
            let safeAccessToken = (user.sendbirdAccessToken).emptyOnNil()

            SendBird.loginWithUserId("\(user.id)", andUserName: safeName, andUserImageUrl: safeImageUrl, andAccessToken: safeAccessToken)

            // Always join the default_channel first after logging in
            self.joinChannel("default_channel")
        }
        .flatMap {
            _ in
            return self.connect()
        }
    }

    func logout() {
        SendBird.disconnect()

        // Update Connection Status
        self.serverConnected.onNext(self.isConnected())
    }

    func connect() -> Observable<SendBirdChannel> {
        SendBird.connect()

        return self.channelConnected
        .asObservable()
        .amb(sendBirdError.asObservable().filter {
            (error: SendBirdError?) -> Bool in
            return error == .ErrJoinMessaging || error == .ErrStartMessaging || error == .ErrNetwork || error == .ErrUndefined
        }.flatMap {
            (error: SendBirdError?) -> Observable<SendBirdChannel> in
            guard let error = error else {
                return Observable.error(SendBirdError.ErrUndefined)
            }
            return Observable.error(error)
        })
        .take(1)
    }

    func isConnected() -> Bool {
        return SendBird.connectState() == WS_OPEN
    }

    func joinChannel(channelUrl: String) {
        SendBird.joinChannel(channelUrl)
    }

    func joinDefaultChannel() {
        self.joinChannel("default_channel")
        SendBird.connect()
    }

    func joinMessagingChannel(channelUrl: String) -> Observable<SendBirdMessagingChannel> {
        // CC This should be in doOnSubscribe() which is not in RxSwift now. Otherwise there could be a race-condition
        SendBird.joinMessagingWithChannelUrl(channelUrl)

        return self.messagingStarted
        .asObservable()
        .filter {
            (channel: SendBirdMessagingChannel) -> Bool in
            return channel.getUrl() == channelUrl
        }
        .amb(sendBirdError.asObservable().filter {
            (error: SendBirdError?) -> Bool in
            return error == .ErrJoinMessaging || error == .ErrStartMessaging || error == .ErrNetwork || error == .ErrUndefined
        }.flatMap {
            (error: SendBirdError?) -> Observable<SendBirdMessagingChannel> in
            guard let error = error else {
                return Observable.error(SendBirdError.ErrUndefined)
            }
            return Observable.error(error)
        }).take(1)
    }

    func fetchChannelList() -> Observable<[SendBirdMessagingChannel]> {
        return Observable.create {
            (observer: AnyObserver<[SendBirdMessagingChannel]>) -> Disposable in
            let query = SendBird.queryMessagingChannelList()
            query.setNewMessageSinceJoinedOnly(false)

            if (!query.hasNext()) {
                observer.on(.Completed)
            } else {
                query.nextWithResultBlock({
                    (results: NSMutableArray!) in
                    if let channels = results as NSArray as? [SendBirdMessagingChannel] {
                        observer.on(.Next(channels))
                    }
                    observer.on(.Completed)

                }, endBlock: {
                    (errorCode: Int) in
                    if let error = SendBirdError(rawValue: errorCode) {
                        observer.on(.Error(error))
                    } else {
                        observer.on(.Error(SendBirdError.ErrUndefined))
                    }
                })
            }

            return AnonymousDisposable {
                query.cancel()
            }
        }
    }

    func startMessaging(userIds: [String]) -> Observable<SendBirdMessagingChannel> {
        if userIds.count == 0 {
            // If nobody from invited list in on fave, start chat with the user himself. At least he will be able to chat
            // - and later we add rest of the users from backend when they join fave
            guard let userId = {
                () -> Int? in
                let user = self.userProvider.currentUser.value
                if (user.isGuest) {
                    return nil
                }
                return user.id
            }() else {
                return Observable.error(SendBirdError.ErrUndefined)
            }

            SendBird.startMessagingAsGroupWithUserId(String(userId))
        } else if userIds.count == 1 {
            // if only with one user - have to explicitly user 'startMessaging as group'
            SendBird.startMessagingAsGroupWithUserId(userIds.first!)
        } else {
            SendBird.startMessagingWithUserIds(userIds)
        }

        return self.messagingStarted
        .asObservable()
        .amb(sendBirdError.asObservable().filter {
            (error: SendBirdError?) -> Bool in
            return error == .ErrJoinMessaging || error == .ErrStartMessaging || error == .ErrNetwork || error == .ErrUndefined
        }.flatMap {
            (error: SendBirdError?) -> Observable<SendBirdMessagingChannel> in
            guard let error = error else {
                return Observable.error(SendBirdError.ErrUndefined)
            }
            return Observable.error(error)
        }).take(1)
    }

    func inviteMessagingWithChannelUrl(channelUrl: String, userIds: [String]) -> Observable<SendBirdMessagingChannel> {
        if userIds.count == 0 {
            return Observable.empty()
        }

        SendBird.inviteMessagingWithChannelUrl(channelUrl, andUserIds: userIds)

        return self.messagingChannelUpdated
            .asObservable()
            .filter {
                (channel: SendBirdMessagingChannel) -> Bool in
                return channel.getUrl() == channelUrl
            }
            .amb(sendBirdError.asObservable().filter {
                (error: SendBirdError?) -> Bool in
                return error == .ErrInviteMessaging || error == .ErrNetwork || error == .ErrUndefined
                }.flatMap {
                    (error: SendBirdError?) -> Observable<SendBirdMessagingChannel> in
                    guard let error = error else {
                        return Observable.error(SendBirdError.ErrUndefined)
                    }
                    return Observable.error(error)
                }).take(1)
    }

    func markAsRead(channel: SendBirdMessagingChannel) {
        SendBird.markAsReadForChannel(channel.getUrl())

        channel.unreadMessageCount = 0
        self.channelProvider.update(channel)
        self.messagingChannelUpdated.onNext(channel)
    }

    func loadInitialMessages(channelUrl: String, count: Int) -> Observable<[SendBirdMessageModel]> {
        return loadPreviousMessages(channelUrl, fromTimestamp: Int64.max, count: count)
    }

    func loadPreviousMessages(channelUrl: String, fromTimestamp: Int64, count: Int) -> Observable<[SendBirdMessageModel]> {
        return Observable.create {
            (observer: AnyObserver<[SendBirdMessageModel]>) -> Disposable in
            let query = SendBird.queryMessageListInChannel(channelUrl) as SendBirdMessageListQuery
            let sbCount = count >= Int(Int32.max) ? Int32.max : Int32(count)

            query.prevWithMessageTs(fromTimestamp, andLimit: sbCount, resultBlock: {
                (results: NSMutableArray!) in
                if let messages = results as NSArray as? [SendBirdMessageModel] {
                    let filteredMessages = messages.filter {
                        return !($0 is SendBirdSystemMessage)
                    }
                    observer.on(.Next(filteredMessages))
                }
                observer.on(.Completed)

            }, endBlock: {
                (error: NSError!) in
                observer.on(.Error(error))
            })

            return AnonymousDisposable {
            }
        }
    }

    func loadNextMessages(channelUrl: String, fromTimestamp: Int64, count: Int) -> Observable<[SendBirdMessageModel]> {
        return Observable.create {
            (observer: AnyObserver<[SendBirdMessageModel]>) -> Disposable in
            let query = SendBird.queryMessageListInChannel(channelUrl) as SendBirdMessageListQuery
            let sbCount = count >= Int(Int32.max) ? Int32.max : Int32(count)

            query.nextWithMessageTs(fromTimestamp, andLimit: sbCount, resultBlock: {
                (results: NSMutableArray!) in
                if let messages = results as NSArray as? [SendBirdMessageModel] {
                    let filteredMessages = messages.filter {
                        return !($0 is SendBirdSystemMessage)
                    }
                    observer.on(.Next(filteredMessages))
                }
                observer.on(.Completed)

                }, endBlock: {
                    (error: NSError!) in
                    observer.on(.Error(error))
            })

            return AnonymousDisposable {
            }
        }
    }

    func joinAndLoadInitialChat(channelUrl: String, count: Int) -> Observable<(SendBirdMessagingChannel, [SendBirdMessageModel])> {
        return self.joinMessagingChannel(channelUrl)
        .flatMap {
            [weak self] (channel: SendBirdMessagingChannel) -> Observable<(SendBirdMessagingChannel, [SendBirdMessageModel])> in
            guard let strongself = self else {
                return Observable.empty()
            }

            return strongself.loadInitialMessages(channel.getUrl(), count: count)
                .map {
                    (model: [SendBirdMessageModel]) -> (SendBirdMessagingChannel, [SendBirdMessageModel]) in
                        return (channel, model)
                }
        }
        .doOnNext {
            [weak self] _ in
            self?.joinChannel(channelUrl)
        }
    }

    func sendMessage(message: String) {
        SendBird.sendMessage(message)
    }

    func updateTypingStatus(typing: Bool) {

        if typing {
            SendBird.typeStart()
        } else {
            SendBird.typeEnd()
        }
    }

    func leaveChannel(channelUrl: String) -> Observable<SendBirdChannel> {
        // CC This should be in doOnSubscribe() which is not in RxSwift now. Otherwise there could be a race-condition
        SendBird.leaveChannel(channelUrl)

        return self.channelLeft
        .asObservable()
        .filter {
            (channel: SendBirdChannel) -> Bool in
            return channel.url == channelUrl
        }
        .doOnNext {
            _ in
            SendBird.disconnect()

            // Update Connection Status
            self.serverConnected.onNext(self.isConnected())
        }
        .amb(sendBirdError.asObservable().filter {
            (error: SendBirdError?) -> Bool in
            return error == .ErrLeaveChannel || error == .ErrNetwork || error == .ErrUndefined
        }.flatMap {
            (error: SendBirdError?) -> Observable<SendBirdChannel> in
            guard let error = error else {
                return Observable.error(SendBirdError.ErrUndefined)
            }
            return Observable.error(error)
        }).take(1)
    }

    func endMessagingWithChannelUrl(channelUrl: String) -> Observable<SendBirdMessagingChannel> {
        // CC This should be in doOnSubscribe() which is not in RxSwift now. Otherwise there could be a race-condition
        SendBird.endMessagingWithChannelUrl(channelUrl)

        return self.messagingEnded
            .asObservable()
            .filter {
                (channel: SendBirdMessagingChannel) -> Bool in
                return channel.getUrl() == channelUrl
            }
            .amb(sendBirdError.asObservable().filter {
                (error: SendBirdError?) -> Bool in
                return error == .ErrEndMessaging || error == .ErrNetwork || error == .ErrUndefined
                }.flatMap {
                    (error: SendBirdError?) -> Observable<SendBirdMessagingChannel> in
                    guard let error = error else {
                        return Observable.error(SendBirdError.ErrUndefined)
                    }
                    return Observable.error(error)
                }).take(1)
    }

    func parsePushNotificationForDeepLink(userInfo: [NSObject:AnyObject]) -> LinkModel? {
        // CC: This should be extracted out somewhere to handle more types of push notification in the future
        if let jsonString = userInfo["fave"] as? String,
            let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
            let jsonData = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()),
            let dictionary = jsonData as? [String: AnyObject] {
            // Get Parameters from Fave Dictionary, check the notification type
            if let pushNotificationType = dictionary["type"] as? String {

                var params = [String: String]()
                if let title = dictionary["title"] as? String {
                    params["title"] = title
                }
                if let message = dictionary["message"] as? String {
                    params["message"] = message
                }

                if pushNotificationType == "invite" {
                    return LinkModel(type: .Invite, deepLink: "fave://access.kfit.com", params: params)
                } else if pushNotificationType == "chat_credit" {
                    return LinkModel(type: .Credits, deepLink: "fave://access.kfit.com", params: params)
                }
            }

            return nil
        } else if let sendBirdPayload = userInfo["sendbird"] as? NSDictionary {
            guard let channelUrl = sendBirdPayload["channel"]?["channel_url"] as? String else {
                return nil
            }

            let apsNotification = userInfo["aps"] as? NSDictionary
            _ = apsNotification?["alert"] as? String

//            print("Received SendBird APNS \(alertMsg) for channel \(channelUrl)")
            return LinkModel(type: .Chat, deepLink: "fave://access.kfit.com", params: ["channel_url": channelUrl])
        } else {
            return nil
        }
    }
}

enum SendBirdError: Int, ErrorType {
    case ErrReconnectFailed = 8000
    case ErrNetwork = 9000
    case ErrDataParsing = 9010
    case ErrLogin = 10000
    case ErrLoginAccessTokenInvalid = 10010
    case ErrGetChannelInfo = 11000
    case ErrFileUpload = 12000
    case ErrLoadChannel = 13000
    case ErrStartMessaging = 14000
    case ErrJoinMessaging = 14050
    case ErrEndMessaging = 14100
    case ErrEndAllMessaging = 14110
    case ErrInviteMessaging = 14150
    case ErrHideMessaging = 14200
    case ErrHideAllMessaging = 14210
    case ErrMarkAsRead = 15100
    case ErrMarkAsReadAll = 15200
    case ErrLeaveChannel = 16000
    case ErrUndefined = 9999999
}

extension RxSendBirdDefault {
    func registerEventHandler() {
        SendBird.setEventHandlerConnectBlock({
            (channel: SendBirdChannel!) in
            print("channelConnect")
            self.channelConnected.onNext(channel)

            // Update Connection Status
            self.serverConnected.onNext(self.isConnected())
        }, errorBlock: {
            (errorCode: Int) in
            print("SendBird Error: " + String(errorCode))
            self.sendBirdError.onNext(SendBirdError(rawValue: errorCode))

            // Update Connection Status
            self.serverConnected.onNext(self.isConnected())
        }, channelLeftBlock: {
            (channel: SendBirdChannel!) in
            print("channelLeftBlock")
            self.channelLeft.onNext(channel)
        }, messageReceivedBlock: {
            (message: SendBirdMessage!) in
            print("messageReceivedBlock")
            self.messageReceived.onNext(message)
        }, systemMessageReceivedBlock: {
            (systemMessage: SendBirdSystemMessage!) in
            print("systemMessageReceivedBlock")
            // We don't want to show system message
            // self.messageReceived.onNext(systemMessage)
        }, broadcastMessageReceivedBlock: {
            (broadcastMessage: SendBirdBroadcastMessage!) in
            print("broadcastMessageReceivedBlock")
            self.messageReceived.onNext(broadcastMessage)
        }, fileReceivedBlock: {
            (fileLink: SendBirdFileLink!) in
            print("fileReceivedBlock")
        }, messagingStartedBlock: {
            (messagingChannel: SendBirdMessagingChannel!) in
            print("messagingStartedBlock")
            self.channelProvider.update(messagingChannel)
            self.messagingStarted.onNext(messagingChannel)
        }, messagingUpdatedBlock: {
            (messagingChannel: SendBirdMessagingChannel!) in
            print("messagingUpdatedBlock " + messagingChannel.getUrl())
            // NO NEED. We are also getting the update in registerNotificationHandlerMessagingChannelUpdatedBlock
            // self.channelProvider.updateMessagingChannel(messagingChannel: messagingChannel)
            // self.messagingChannelUpdated.onNext(messagingChannel)
        }, messagingEndedBlock: {
            (messagingChannel: SendBirdMessagingChannel!) in
            print("messagingEndedBlock " + messagingChannel.getUrl())
            self.messagingEnded.onNext(messagingChannel)
        }, allMessagingEndedBlock: {
            print("allMessagingEndedBlock")
        }, messagingHiddenBlock: {
            (messagingChannel: SendBirdMessagingChannel!) in
            print("messagingHiddenBlock")
        }, allMessagingHiddenBlock: {
            print("allMessagingHiddenBlock")
        }, readReceivedBlock: {
            (status: SendBirdReadStatus!) in
            print("readReceivedBlock")
        }, typeStartReceivedBlock: {
            (status: SendBirdTypeStatus!) in
            print("typeStartReceivedBlock")
            self.typeStartReceived.onNext(status)
        }, typeEndReceivedBlock: {
            (status: SendBirdTypeStatus!) in
            print("typeEndReceivedBlock")
            self.typeEndReceived.onNext(status)
        }, allDataReceivedBlock: {
            (sendBirdDataType: UInt, count: Int32) in
            print("allDataReceivedBlock")

            // Update Connection Status
            self.serverConnected.onNext(self.isConnected())
        }, messageDeliveryBlock: {
            (send: Bool, message: String!, data: String!, messageId: String!) in
            print("messageDeliveryBlock")
        }, mutedMessagesReceivedBlock: {
            (message: SendBirdMessage!) in
            print("mutedMessagesReceivedBlock")
        }, mutedFileReceivedBlock: {
            (fileLink: SendBirdFileLink!) in
            print("mutedFileReceivedBlock")
        })

        SendBird.registerNotificationHandlerMessagingChannelUpdatedBlock({
                    (messagingChannel: SendBirdMessagingChannel!) in
                    // CC: Great hack to workaround the case where we are on the chat, and when someone sends a message
                    // we immediately get an unreadcount update. However after we send markAsRead(), we don't get back an
                    // update to change the unread count back to 0.
                    let currentChannel = SendBird.getCurrentChannel()
                    let newUnreadCount = {
                        _ -> Int32 in
                        if (messagingChannel.channel.url == currentChannel.url && self.isConnected()) {
                            // We are currently connected to this channel. Messages should be read as soon as it comes in
                            return 0
                        } else {
                            return messagingChannel.unreadMessageCount
                        }
                    }()

                    messagingChannel.unreadMessageCount = newUnreadCount
                    self.channelProvider.update(messagingChannel)
                    self.messagingChannelUpdated.onNext(messagingChannel)
                },
                mentionUpdatedBlock: {
                    (mention: SendBirdMention!) in
                    // TODO: Implement
                })
    }
}
