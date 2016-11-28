//
//  ChannelProvider.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SendBirdSDK

protocol ChannelProvider: Refreshable, Cachable {
    var channels: Variable<[Channel]> {get}
    func fetchChannel(channelUrl: String) -> Observable<ChannelAPIResponsePayload>
    func fetchChannels(compareWithMessagingServiceChannels messagingServiceChannels: [SendBirdMessagingChannel]) -> Observable<ChannelsAPIResponsePayload>
    func post(channel: Channel) -> Observable<CreateChannelAPIResponsePayload>
    // Helper methods
    func filterInvitedChannels(channels: [Channel], forUserWithId userId: Int) -> ([Channel], [Channel])
    func leave(channel: Channel)  -> Observable<LeaveChannelAPIResponsePayload>
    func update(channel: Channel, withUserParticipationStatus userParticipationStatus: UserParticipationStatus) -> Observable<UpdateParticipationStatusAPIResponsePayload>
    func update(messagingChannel: SendBirdMessagingChannel)
}

final class ChannelProviderDefault: Provider, ChannelProvider {

    // MARK:- Dependency
    private let channelAPI: ChannelAPI
    private let channelsAPI: ChannelsAPI
    private let createChannelAPI: CreateChannelAPI
    private let updateParticipationStatusAPI: UpdateParticipationStatusAPI
    private let leaveChannelAPI: LeaveChannelAPI
    private let userProvider: UserProvider

    // MARK:- Provider variables
    let channels: Variable<[Channel]>

    init(channelAPI: ChannelAPI = ChannelAPIDefault()
        , channelsAPI: ChannelsAPI = ChannelsAPIDefault()
        , createChannelAPI: CreateChannelAPI = CreateChannelAPIDefault()
        , updateParticipationStatusAPI: UpdateParticipationStatusAPI = UpdateParticipationStatusAPIDefault()
        , leaveChannelAPI: LeaveChannelAPI = LeaveChannelAPIDefault()
        , userProvider: UserProvider = userProviderDefault
        ) {
        self.channelAPI = channelAPI
        self.channelsAPI = channelsAPI
        self.createChannelAPI = createChannelAPI

        self.leaveChannelAPI = leaveChannelAPI
        self.updateParticipationStatusAPI = updateParticipationStatusAPI
        self.userProvider = userProvider

        // Disabling the cache for now
        //        let cashedCannels = ChannelProviderDefault.loadCacheForChannels()

        let cashedCannels = [Channel]()
        self.channels = Variable(cashedCannels)
        super.init()

        // Cache the Channels
        // Disabling the cache for now
        channels
            .asObservable()
            .subscribeNext { (channels: [Channel]) in ChannelProviderDefault.cache(channels: channels) }
            .addDisposableTo(disposeBag)

        // Sort the channel's participant list
        channels
            .asObservable()
            .subscribeNext { _ in
                self.channels.value.forEach {
                    (aChannel: Channel) in
                    aChannel.chatParticipants.sortInPlace({ (lhs: ChatParticipant, rhs: ChatParticipant) -> Bool in
                        // Put Ourselves Always First
                        if (lhs.id == self.userProvider.currentUser.value.id) {
                            return true
                        }

                        if (rhs.id == self.userProvider.currentUser.value.id) {
                            return false
                        }

                        return lhs.participationStatus.sortingPriority > rhs.participationStatus.sortingPriority
                    })
                }
            }
            .addDisposableTo(disposeBag)

        // MARK:- Logout
        // Clear the cashe
        app
            .logoutSignal
            .subscribeNext {
                ChannelProviderDefault.clearCacheForChannels()
            }
            .addDisposableTo(disposeBag)

        // Set the user to Guest
        app
            .logoutSignal
            .map { [Channel]() }
            .bindTo(channels)
            .addDisposableTo(disposeBag)
    }

    func fetchChannel(channelUrl: String) -> Observable<ChannelAPIResponsePayload> {
        let channelAPIRequestPayload = ChannelAPIRequestPayload(channelUrlString: channelUrl)

        let response = channelAPI.channel(withRequestPayload: channelAPIRequestPayload)
            .doOnNext {
                [weak self] (result: ChannelAPIResponsePayload) in
                guard let strongSelf = self else { return }
                // Update cache
                var channels = strongSelf.channels.value
                if let cachedChannel = channels.removeElement(result.channel) { // Remove existing channel first if this is an update
                    // Copy existing Messenging Service Channel
                    result.channel.messagingServiceChannel.value = cachedChannel.messagingServiceChannel.value
                }

                channels.insert(result.channel, atIndex: 0)
                strongSelf.channels.value = channels.sort({ (lhs: Channel, rhs: Channel) -> Bool in
                    guard let lhsSBChannel = lhs.messagingServiceChannel.value else {
                        return false
                    }

                    guard let rhsSBChannel = rhs.messagingServiceChannel.value else {
                        return true
                    }

                    let lhsTimestamp = lhsSBChannel.getLastMessageTimestamp() == 0 ? lhsSBChannel.getCreatedAt() * 1000 : lhsSBChannel.getLastMessageTimestamp()
                    let rhsTimestamp = rhsSBChannel.getLastMessageTimestamp() == 0 ? rhsSBChannel.getCreatedAt() * 1000 : rhsSBChannel.getLastMessageTimestamp()

                    return lhsTimestamp > rhsTimestamp
                })
            }
            .trackActivity(activityIndicator)

        return response
    }

    /**
     Fetch the channels
     
     - author: Nazih Shoura
     
     - side effect: Update the provider chennels variable
     
     - returns: The result of the fetch
     */
    func fetchChannels(compareWithMessagingServiceChannels messagingServiceChannels: [SendBirdMessagingChannel]) -> Observable<ChannelsAPIResponsePayload> {
        let response = channelsAPI
            .channels(withRequestPayload: ChannelsAPIRequestPayload())
            .trackActivity(activityIndicator)
            .doOnNext { [weak self] (result: ChannelsAPIResponsePayload) in
                var channelsDict = [String: Channel]()
                result.channels.forEach {
                    (channel: Channel) in
                    channelsDict[channel.url.absoluteString!] = channel
                }

                var channels = [Channel]()
                messagingServiceChannels
                    .forEach { (messagingServiceChannel: SendBirdMessagingChannel) in
                        if let channel = channelsDict[messagingServiceChannel.getUrl()] {
                            channel.messagingServiceChannel.value = messagingServiceChannel
                            channels.append(channel)
                        }
                }
                self?.channels.value = channels.sort({ (lhs: Channel, rhs: Channel) -> Bool in
                    guard let lhsSBChannel = lhs.messagingServiceChannel.value else {
                        return false
                    }

                    guard let rhsSBChannel = rhs.messagingServiceChannel.value else {
                        return true
                    }

                    let lhsTimestamp = lhsSBChannel.getLastMessageTimestamp() == 0 ? lhsSBChannel.getCreatedAt() * 1000 : lhsSBChannel.getLastMessageTimestamp()
                    let rhsTimestamp = rhsSBChannel.getLastMessageTimestamp() == 0 ? rhsSBChannel.getCreatedAt() * 1000 : rhsSBChannel.getLastMessageTimestamp()

                    return lhsTimestamp > rhsTimestamp
                })
        }

        return response
    }

    /**
     Post a channels to the server
     
     - author: Nazih Shoura
     
     - side effect: Add the posted channel to the beginning the provider chennels variable array
     
     - returns: The result of the fetch
     */
    func post(channel: Channel) -> Observable<CreateChannelAPIResponsePayload> {
        let createChannelRequestPayload = CreateChannelAPIRequestPayload(channel: channel)

        let response = createChannelAPI
            .createChannel(withRequestPayload: createChannelRequestPayload)
            .trackActivity(activityIndicator)
            .doOnNext { [weak self] (result: CreateChannelAPIResponsePayload) in
                guard let strongSelf = self else { return }
                var channels = strongSelf.channels.value
                channels.removeElement(result.channel) // Remove existing channel first if this is an update
                channels.insert(result.channel, atIndex: 0)
                strongSelf.channels.value = channels
        }

        return response
    }

    func update(channel: Channel, withUserParticipationStatus userParticipationStatus: UserParticipationStatus) -> Observable<UpdateParticipationStatusAPIResponsePayload> {
        // TODO lock

        let updateChannelRequestPayload = UpdateParticipationStatusAPIRequestPayload(channelURLString: channel.url.absoluteString!, participationStatus: userParticipationStatus.rawValue)

        let response = updateParticipationStatusAPI
        .updateParticipationStatus(withRequestPayload: updateChannelRequestPayload)
        .trackActivity(activityIndicator)
        .doOnNext { [weak self] (result: UpdateParticipationStatusAPIResponsePayload) in
            guard let strongSelf = self else { return }
            var channels = strongSelf.channels.value
            if let index = channels.indexOf(result.channel) {
                channels[index] = result.channel
                strongSelf.channels.value = channels
            }
        }
        return response
    }

    func update(messagingChannel: SendBirdMessagingChannel) {
        // TODO lock
        let channels = self.channels.value
        if let channelToUpdate = channels.filter({
            (channel: Channel) -> Bool in
            return channel.url.absoluteString == messagingChannel.getUrl()
        }).first {
            channelToUpdate.messagingServiceChannel.value = messagingChannel
            if (channelToUpdate.chatParticipants.count != Int(messagingChannel.getMemberCount())) {
                // Participant Changed. Need to update from Server
                self.fetchChannel(channelToUpdate.url.absoluteString!)
                .subscribeNext {
                    _ in
                    print("Channel Updated After Participant Changed")
                }
                .addDisposableTo(disposeBag)
            }
        }

        self.channels.value = channels.sort({ (lhs: Channel, rhs: Channel) -> Bool in
            guard let lhsSBChannel = lhs.messagingServiceChannel.value else {
                return false
            }

            guard let rhsSBChannel = rhs.messagingServiceChannel.value else {
                return true
            }

            let lhsTimestamp = lhsSBChannel.getLastMessageTimestamp() == 0 ? lhsSBChannel.getCreatedAt() * 1000 : lhsSBChannel.getLastMessageTimestamp()
            let rhsTimestamp = rhsSBChannel.getLastMessageTimestamp() == 0 ? rhsSBChannel.getCreatedAt() * 1000 : rhsSBChannel.getLastMessageTimestamp()

            return lhsTimestamp > rhsTimestamp
        })
    }

    func leave(channel: Channel)  -> Observable<LeaveChannelAPIResponsePayload> {
        // TODO lock

        let leaveChannelRequestPayload = LeaveChannelAPIRequestPayload(channelURLString: channel.url.absoluteString!)
        let response = leaveChannelAPI
        .leaveChannel(withRequestPayload: leaveChannelRequestPayload)
        .trackActivity(activityIndicator)
        .doOnNext { [weak self] (result: LeaveChannelAPIResponsePayload) in
            guard let strongSelf = self else {return }
            var channels = strongSelf.channels.value
            channels.removeElement(channel)
            strongSelf.channels.value = channels
        }
        return response
    }

    func filterInvitedChannels(channels: [Channel], forUserWithId userId: Int) -> ([Channel], [Channel]) {
        var invitedChannels = [Channel]()
        var responsedChannels = [Channel]()

        for channel in channels {
            guard let userChatParticipant = channel
                .chatParticipants
                .filter({ (chatParticipant: ChatParticipant) -> Bool in
                    return chatParticipant.id == userId
                }).first else {continue}

            if userChatParticipant.participationStatus == UserParticipationStatus.Invited {
                invitedChannels.append(channel)
            } else {
                responsedChannels.append(channel)
            }
        }
        return (invitedChannels, responsedChannels)
    }
}

extension ChannelProviderDefault {
    func refresh() {
        // Refresh the provided variables
    }
}

// MARK:- Cashe
extension ChannelProviderDefault {
    static func clearCacheForChannels() {
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                nil, forKey: "\(literal.ChannelProviderDefault).channels")
    }

    static func cache(channels channels: [Channel]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(channels)
        NSUserDefaults
            .standardUserDefaults()
            .setObject(
                data, forKey: "\(literal.ChannelProviderDefault).channels")
    }

    static func loadCacheForChannels() -> [Channel] {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey("\(literal.ChannelProviderDefault).channels") as? NSData else {
            return [Channel]()
        }

        guard let channels = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Channel] else {
            ChannelProviderDefault.clearCacheForChannels()
            return [Channel]()
        }
        return channels
    }
}
