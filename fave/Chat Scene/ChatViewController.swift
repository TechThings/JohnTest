//
//  ChatViewController.swift
//  FAVE
//
//  Created by Nazih Shoura on 08/08/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JSQMessagesViewController

final class ChatViewController: JSQMessagesViewController {

    private static let scrollViewAutoScrollMargin: CGFloat = 50.0
    private var readyToChat: Bool = false
    static let broadcastMessageFont = UIFont.systemFontOfSize(13)
    static let broadcastMessageWidth: CGFloat = 200.0
    static let broadcastMessagePadding: CGFloat = 16.0
    static let broadcastMessageCellMargin: CGFloat = 25.0

    // MARK:- IBOutlet

    // MARK:- ViewModel
    var viewModel: ChatViewControllerViewModel!
    weak var containerViewController: UIViewController?

    var avatarDictionary = [String: RemoteAvatarView]()

    var disposeBag = DisposeBag()

    let incomingBubble: JSQMessagesBubbleImage = {
        // Bubbles with Tail
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.whiteColor())
    }()

    let incomingBubbleGrouped: JSQMessagesBubbleImage = {
        // Bubbles without Tail
        return JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero).incomingMessagesBubbleImageWithColor(UIColor.whiteColor())
    }()

    let outgoingBubble: JSQMessagesBubbleImage = {
        // Bubbles with Tail
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.favePink())
    }()

    let outgoingBubbleGrouped: JSQMessagesBubbleImage = {
        // Bubbles without Tail
        return JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero).outgoingMessagesBubbleImageWithColor(UIColor.favePink())
    }()

    // MARK:- Constant

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let viewModel = viewModel {
            viewModel.setAsActive()
            viewModel.connect()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if (self.inputToolbar.contentView.textView.isFirstResponder()) {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let viewModel = viewModel {

            viewModel.disconnect()
        }

        // Hide type indicator
        self.showTypingIndicator = false
    }

    // CC: Need to override the topLayoutGuide because we put it in a container view
    // Reference: https://github.com/jessesquires/JSQMessagesViewController/issues/325
    override var topLayoutGuide: UILayoutSupport {
        guard let parentTLG = self.containerViewController?.topLayoutGuide else {
            return super.topLayoutGuide
        }

        return parentTLG
    }

    deinit {
        print("ChatViewController deinit")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setup() {
        // Add some extra padding on top
        self.topContentAdditionalInset = 40.0

        // Add custom cell
        collectionView?.registerNib(UINib(nibName: literal.BroadcastMessageCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: literal.BroadcastMessageCollectionViewCell)

        // Set custom layout manager
        collectionView?.collectionViewLayout = CustomCollectionViewFlowLayout()

        // Set custom font
        collectionView?.collectionViewLayout.messageBubbleFont = UIFont.systemFontOfSize(15)

        // Background Color
        collectionView?.backgroundColor = UIColor.faveBackground()

        // Set Load More Header View Font Color
        collectionView?.loadEarlierMessagesHeaderTextColor = UIColor.faveBlue()

        // Show avatar
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: RemoteAvatarView.diameter(), height: RemoteAvatarView.diameter())
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        // Hide Upload Attachment Button
        self.inputToolbar.contentView.leftBarButtonItem = nil

        self.automaticallyScrollsToMostRecentMessage = true

        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
    }

    func received(message message: JSQMessage) {
        self.finishReceivingMessageAnimated(true)
    }

    // MARK: JSQMessagesViewController method overrides
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        self.viewModel.sendMessage(text)
        self.finishSendingMessageAnimated(true)
    }

    //MARK: JSQMessages CollectionView DataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.currentMessages.count
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return viewModel.currentMessages[indexPath.item]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        let isOutgoing = viewModel.currentMessages[indexPath.item].senderId == self.senderId
        if (isCellGrouped(indexPath)) {
            if isOutgoing {
                return outgoingBubbleGrouped
            }
            return incomingBubbleGrouped
        } else {
            if isOutgoing {
                return outgoingBubble
            }
            return incomingBubble
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        let currentMessage = self.viewModel.currentMessages[indexPath.item]
        if (currentMessage.senderId == self.senderId) {
            return nil
        }

        if (isCellGrouped(indexPath)) {
            return nil
        }

        if let cachedImage = avatarDictionary[currentMessage.senderId] {
            return cachedImage
        } else {
            // Get initial
            guard let participant = {
                _ -> ChatParticipant? in
                for p in self.viewModel.channel.value.chatParticipants {
                    if let id = p.id where String(id) == currentMessage.senderId {
                        return p
                    }
                }

                return nil
            }() else {
                return nil
            }

            let avatarSource = RemoteAvatarView(chatParticipant: participant)
            avatarSource.delegate = self
            avatarDictionary[currentMessage.senderId] = avatarSource

            return avatarSource
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let currentMessage = self.viewModel.currentMessages[indexPath.item]

        // Handle Broadcast message
        if (currentMessage.isBroadcast) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(literal.BroadcastMessageCollectionViewCell, forIndexPath: indexPath) as! BroadcastMessageCollectionViewCell
            cell.broadcastMessageLabel.font = ChatViewController.broadcastMessageFont
            let viewModel = BroadcastMessageCollectionViewCellViewModel(message: currentMessage)
            cell.viewModel = viewModel
            return cell
        }

        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        // Customize Text Color
        let isOutgoing = currentMessage.senderId == self.senderId
        cell.textView.textColor = isOutgoing ? UIColor.whiteColor() : UIColor.darkTextColor()
        let hyperlinkTextColor = isOutgoing ? UIColor.whiteColor() : UIColor.blueColor()
        cell.textView.linkTextAttributes = [ NSForegroundColorAttributeName : hyperlinkTextColor,
                                             NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue | NSUnderlineStyle.PatternSolid.rawValue ]

        return cell
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let currentMessage = self.viewModel.currentMessages[indexPath.item]
        if (currentMessage.isBroadcast) {
            return 0.0
        }

        let previousMessage = self.viewModel.currentMessages[safe: indexPath.item - 1]

        if let previousMessage = previousMessage {
            if (!currentMessage.date.equalToDateIgnoringTime(previousMessage.date)) {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }

        return 0.0
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let currentMessage = self.viewModel.currentMessages[indexPath.item]

        // Don't show if sender is us or it's a broadcast message
        if (currentMessage.senderId == self.senderId || currentMessage.isBroadcast) {
            return 0.0
        }

        // To group messages from same sender
        if indexPath.item - 1 > 0 {
            let previousMessage = self.viewModel.currentMessages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }

        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        // Don't show for Broadcast Message
        let currentMessage = self.viewModel.currentMessages[indexPath.item]
        if (currentMessage.isBroadcast) {
            return 0.0
        }

        // Group The Message By Sender And Timestamp
        let grouped = self.isCellGrouped(indexPath)
        return grouped ? 0.0 : kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    private func isCellGrouped(indexPath: NSIndexPath!) -> Bool {
        // Group The Message By Sender And Timestamp
        let currentMessage = self.viewModel.currentMessages[indexPath.item]

        // Check if this is the most recent message, or the only message
        if indexPath.item >= self.viewModel.currentMessages.count - 1 {
            return false
        }

        let previousMessage = self.viewModel.currentMessages[safe: indexPath.item - 1]
        let nextMessage = self.viewModel.currentMessages[safe: indexPath.item + 1]

        // Check for Next message
        if let nextMessage = nextMessage {
            if currentMessage.senderId != nextMessage.senderId {
                return false
            } else {
                // To group messages from same sender within 60 seconds of each other
                if nextMessage.date.timeIntervalSinceDate(currentMessage.date) < 60 {
                    return true
                } else {
                    return false
                }
            }
        }

        // To group messages from same sender within 60 seconds of each other
        if let previousMessage = previousMessage {
            if currentMessage.date.timeIntervalSinceDate(previousMessage.date) < 60 {
                return true
            }
        }

        return false
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        // Use Top Label to display the date if the days are different
        let currentMessage = self.viewModel.currentMessages[indexPath.item]
        if (currentMessage.isBroadcast) {
            return nil
        }

        let previousMessage = self.viewModel.currentMessages[safe: indexPath.item - 1]
        if let previousMessage = previousMessage {
            if (currentMessage.date.equalToDateIgnoringTime(previousMessage.date)) {
                return nil
            }
        }

        let displayText = JSQMessagesTimestampFormatter.sharedFormatter().relativeDateForDate(currentMessage.date)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        let attributedString = NSAttributedString(string: displayText,
                                                  attributes: [NSParagraphStyleAttributeName: paragraphStyle])

        return attributedString
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = viewModel.currentMessages[indexPath.item]

        // Don't show for Broadcast Message
        if (message.isBroadcast) {
            return nil
        }

        let isOutgoing = message.senderId == self.senderId

        let timeString = JSQMessagesTimestampFormatter.sharedFormatter().timeForDate(message.date)

        let displayText = {
            _ -> String in
            if (isOutgoing) {
                return "\(timeString)"
            } else {
                return "\(message.senderDisplayName) \(timeString)"
            }
        }()

        let paragraphStyle = NSMutableParagraphStyle()
        if isOutgoing {
            paragraphStyle.tailIndent = -15.0
            paragraphStyle.alignment = .Right
        } else {
            paragraphStyle.headIndent = 15.0 + collectionView.collectionViewLayout.incomingAvatarViewSize.width
            paragraphStyle.firstLineHeadIndent = 15.0 + collectionView.collectionViewLayout.incomingAvatarViewSize.width
            paragraphStyle.alignment = .Left
        }

        let attributedString = NSAttributedString(string: displayText,
                                                  attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.faveDarkGray()])

        return attributedString
    }

    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.viewModel.inputTextChanged.onNext(true)
        return true
    }

    override func collectionView(collectionView: JSQMessagesCollectionView, header headerView: JSQMessagesLoadEarlierHeaderView, didTapLoadEarlierMessagesButton sender: UIButton) {
        print("Load earlier messages!")
        self.viewModel.loadEarlierMessages()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - ChatViewController.scrollViewAutoScrollMargin)) {
            // Reach bottom
            self.automaticallyScrollsToMostRecentMessage = true
            return
        }

        if (scrollView.contentOffset.y < 0) {
            // Reach top
            self.automaticallyScrollsToMostRecentMessage = false
            return
        }

        if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height - ChatViewController.scrollViewAutoScrollMargin)) {
            // Middle
            self.automaticallyScrollsToMostRecentMessage = false
            return
        }
    }

    override func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.automaticallyScrollsToMostRecentMessage = true
        return self.readyToChat
    }

}

extension ChatViewController: RemoteAvatarViewDelegate {
    func reloadViewForAvatar() {
        self.collectionView.reloadData()
    }
}

// MARK:- ViewModelBinldable

extension ChatViewController: ViewModelBindable {
    func bind() {
        self.senderId = viewModel.userId.value
        viewModel
            .userId
            .asDriver()
            .driveNext {
                [weak self] (userId: String) in
                self?.senderId = userId
            }
            .addDisposableTo(disposeBag)

        self.senderDisplayName = viewModel.userName.value
        viewModel
            .userName
            .asDriver()
            .driveNext {
                [weak self] (userName: String) in
                self?.senderDisplayName = userName
            }
            .addDisposableTo(disposeBag)

        NSNotificationCenter.defaultCenter()
            .rx_notification(UIApplicationWillResignActiveNotification)
            .subscribeNext {
                [weak self] _ in
                print("ChatViewController appWillResignActive")
                if let viewModel = self?.viewModel {

                    viewModel.disconnect()
                }
            }
            .addDisposableTo(disposeBag)

        NSNotificationCenter.defaultCenter()
            .rx_notification(UIApplicationWillEnterForegroundNotification)
            .subscribeNext {
                [weak self] _ in
                print("ChatViewController appWillEnterForeground")
                if let viewModel = self?.viewModel {
                    viewModel.setAsActive()
                    viewModel.connect()
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .messagesUpdated
            .asDriver(onErrorJustReturn: false)
            .driveNext {
                [weak self] (refresh: Bool) in
                if (refresh) {
                    self?.collectionView.reloadData()
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .scrollMessagesView
            .asDriver(onErrorJustReturn: .None)
            .driveNext {
                [weak self] (direction: ScrollingDirection) in
                switch (direction) {
                case .Bottom(let animated):
                    self?.scrollToBottomAnimated(animated)
                case .Top(let animated):
                    self?.scrollToIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: animated)
                case .Index(let indexPath, let animated):
                    self?.scrollToIndexPath(indexPath, animated: animated)
                case .None:
                    // Do nothing
                    print("Got None for scrollMessagesView")
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .messageReceived
            .driveNext {
                [weak self] (message: JSQMessage) in
                self?.received(message: message)
            }
            .addDisposableTo(disposeBag)

        viewModel
            .showTypingIndicator
            .driveNext {
                [weak self] (typing: Bool) in
                self?.showTypingIndicator = typing

                // Scroll to actually view the indicator
                if let autoScroll = self?.automaticallyScrollsToMostRecentMessage.boolValue where autoScroll == true {
                    self?.scrollToBottomAnimated(true)
                }
            }
            .addDisposableTo(disposeBag)

        viewModel
            .showLoadMoreHeader
            .driveNext {
                [weak self] (loadMoreVisible: Bool) in
                self?.showLoadEarlierMessagesHeader = loadMoreVisible
            }
            .addDisposableTo(disposeBag)

        self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString("chat_connecting", comment: "")
        viewModel
            .serverConnected
            .driveNext {
                [weak self] (connected: Bool) in
                self?.readyToChat = connected
                if (connected) {
                    self?.inputToolbar.contentView.textView.placeHolder = NSLocalizedString("chat_type_something", comment: "")
                } else {
                    self?.inputToolbar.contentView.textView.placeHolder = NSLocalizedString("chat_connecting", comment: "")
                }
            }
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Buildable

extension ChatViewController: Buildable {
    final class func build(builder: ChatViewControllerViewModel) -> ChatViewController {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.ChatViewController) as! ChatViewController
        vc.viewModel = builder
        return vc
    }
}
