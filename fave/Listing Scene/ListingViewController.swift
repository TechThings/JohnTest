import UIKit
import RxSwift
import RxCocoa
import IDMPhotoBrowser
import AMPopTip
import MoEngage_iOS_SDK

enum ListingSection: Int {
    case Photo = 0
    case Detail
    case About
    case Book
    case DateTimeSlot
    case PromoCode
    case Collection
    case Outlet
    case MultipleOutlets
    case ThingsToKnow
    case WhatYouGet
    case Info
    case Location
    case Cancellation
    case Gallery
    case Review
    case Count
}

final class ListingViewController: ViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyNowButton: Button!
    @IBOutlet weak var chatButton: Button!
    @IBOutlet weak var floatingButtonsView: UIView!

    // MARK:- ViewModel
    var viewModel: ListingViewModel!

    // MARK:- Constant
    private let tableHeaderViewHeight: CGFloat = 200
    private let activityDetailsRowHeight: CGFloat = 120
    private let activityBuyNowRowHeight: CGFloat = 128
    private let activityOutletRowHeight: CGFloat = 110
    private let activityMultipleOutletsRowHeight: CGFloat = 74
    private let activityPhotoRowHeight: CGFloat = 200
    private let activityBookRowHeight: CGFloat = 62
    private let activityDateTimeSlotHeight: CGFloat = 55
    private let activityThingsToKnowRowHeight = Variable<CGFloat>(0)
    private let activityWhatYouGetRowHeight = Variable<CGFloat>(0)
    private let activityGallaryRowHeight: CGFloat = 120
    private let activityInfoHeaderHeight: CGFloat = 60
    private let activityCancellationRowHeight: CGFloat = 315
    private let activityCollectionRowHeight: CGFloat = 77
    private let activityPromoCodeRowHeight: CGFloat = 84
    private let activityStandardFooterHeight: CGFloat = 40

    private var readMore: Bool = false

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.contentOffset.y  > 100 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = viewModel.listingDetails.value?.name
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"ui-gradient"), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.title = ""
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        floatingButtonsView.layer.shadowColor = UIColor.blackColor().CGColor
        floatingButtonsView.layer.shadowOffset = CGSize(width: 0, height: -0.75)
        floatingButtonsView.layer.shadowOpacity = 0.15
        floatingButtonsView.layer.shadowRadius = 1.25
        floatingButtonsView.layer.shadowPath = UIBezierPath(rect:floatingButtonsView.bounds).CGPath

        viewModel.activityIndicator.asDriver().driveNext { (active: Bool) in
            if !active {
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.floatingButtonsView.transform = CGAffineTransformMakeTranslation(0, 0)
                    }, completion: nil)
            }
            }.addDisposableTo(disposeBag)

        viewModel.setAsActive()

        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_OFFER_DETAIL)

        MoEngage.sharedInstance().handleInAppMessage()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    @IBAction func didTapShareBarButton(sender: AnyObject) {
        if let share = viewModel.listingDetails.value?.shareMessage, let url = share.url, let copy = share.copyString {

            let activityViewController = UIActivityViewController(activityItems: [url as NSURL, copy as String], applicationActivities: nil)

            let presentationController = activityViewController.popoverPresentationController
            if let sourceButton = sender as? UIBarButtonItem {
                presentationController?.barButtonItem = sourceButton
            } else {
                presentationController?.sourceView = sender.view
            }
            self.viewModel.lightHouseService.navigate.onNext({ (viewController) in
                viewController.presentViewController(activityViewController, animated: true, completion: { })
            })
        }
    }

    func setup() {
    self.buyNowButton.setTitle(NSLocalizedString("activity_detail_buy_now_button_text", comment: ""), forState: .Normal)
        self.chatButton.setTitle(NSLocalizedString("main_tab_chat_text", comment: ""), forState: .Normal)

        tableView.registerNib(UINib(nibName: literal.ListingDetailsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingDetailsTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingBookTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingBookTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingOutletTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingOutletTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingMultipleOutletsTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingMultipleOutletsTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingAboutTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingAboutTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingStandardInfoTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingStandardInfoTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingInfoAmenityTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingInfoAmenityTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingGalleryTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingGalleryTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingBuyNowTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingBuyNowTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingHeaderPhotoTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingHeaderPhotoTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingThingsToKnowTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingThingsToKnowTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingWhatYouGetTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingWhatYouGetTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingOutletLocationTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingOutletLocationTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingNextSessionTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingNextSessionTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingCancellationTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingCancellationTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingCollectionDetailTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingCollectionDetailTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingPromoCodeTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingPromoCodeTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingReviewTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ListingReviewTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ListingDateTimeSlotTableViewCell, bundle:nil) , forCellReuseIdentifier: literal.ListingDateTimeSlotTableViewCell)

        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 30,right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0,left: 0,bottom: floatingButtonsView.frame.size.height,right: 0)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 82,right: 0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        floatingButtonsView.transform = CGAffineTransformMakeTranslation(0, floatingButtonsView.frame.size.height)

        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
          self.setupToolTip()
        })
    }

    func setupToolTip() {

        if(getTooltipShown() == false) {

            let backgroundOpaqueView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 17 - chatButton.frame.size.height))
            backgroundOpaqueView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            self.view.addSubview(backgroundOpaqueView)

            let toolTipView = UINib (nibName: "ChatTooltip", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ChatTooltipView

            toolTipView.gotItButton
            .rx_tap
            .asObservable()
            .subscribeNext({ _ in
                backgroundOpaqueView .removeFromSuperview()
                toolTipView.dismissToolTip()
            }).addDisposableTo(disposeBag)

            chatButton
                .rx_tap
                .asObservable()
                .subscribeNext({ _ in
                    backgroundOpaqueView .removeFromSuperview()
                    toolTipView.dismissToolTip()
                }).addDisposableTo(disposeBag)

            toolTipView.configureToolTip(self.view, chatButton: self.chatButton)

            saveToolTipShown()
        }
    }

    @IBAction func buyNowDidTap(sender: UIButton?) {
        guard let listingDetails = viewModel.listingDetails.value else { return }

        let analyticsModel = ListingAnalyticsModel(listing: listingDetails)
        analyticsModel.buyNowClickedEvent.send()

        if let listingOpenVoucherDetails = viewModel.listingDetails.value as? ListingOpenVoucherDetails {
            let confirmationVC = ConfirmationViewController.build(ConfirmationViewModel(listingDetails: listingOpenVoucherDetails, classSession: nil))
            self.navigationController?.presentViewController(confirmationVC, animated: true, completion: nil)
        }

        if let listingTimeSlotDetails = viewModel.listingDetails.value as? ListingTimeSlotDetailsType {
            let nextSessionsViewModel = NextSessionsViewModel(listingTimeSlotDetails: listingTimeSlotDetails)
            let nextSessionsVC = NextSessionsViewController.build(nextSessionsViewModel)
            self.navigationController?.pushViewController(nextSessionsVC, animated: true)
        }
    }

    @IBAction func chatDidTap(sender: AnyObject) {
        switch viewModel.functionality.value {
        case let .InitiateFromChat(channelListing: channelListing):
            guard let listingDetails = viewModel.listingDetails.value else { return }

            channelListing.value = (listingDetails as ListingType)
            guard let vcs = self.navigationController?.viewControllers,
                let previousVC = vcs[safe:vcs.count - 3] as? CreateChannelViewController else {
                    self.navigationController?.popViewControllerAnimated(true)
                    return
            }

            self.navigationController?.popToViewController(previousVC, animated: true)
        case .Initiate():
            if let navController = self.navigationController,
                let previousVC = navController.viewControllers[safe:navController.viewControllers.count - 2],
                let _ = previousVC as? ChatContainerViewController {
                self.navigationController?.popViewControllerAnimated(true)
                return
            }

            guard let listing = viewModel.listingDetails.value else { return }

            let localyticsEvent = LocalyticsEvent.createTapEvent(tappedOn: "new_chat", screenName: screenName.SCREEN_OFFER_DETAIL)
            viewModel.rxAnalytics.sendAnalyticsEvent(localyticsEvent, providers: AnalyticsProviderType.Localytics)

            let vm = ContactsViewControllerViewModel(contactsViewControllerViewModelFunctionality: ContactsViewControllerViewModelFunctionality.InitiateChat(chatParticipants: Variable([ChatParticipant]()), listing: Variable(listing)))
            let vc = ContactsViewController.build(vm)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK:- ViewModelBinldable
extension ListingViewController: ViewModelBindable {
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
            .listingDetails
            .asObservable().skip(0)
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        activityThingsToKnowRowHeight
            .asObservable()
            .filter {
                return $0 > 0
            }
            .take(1) // Otherwise we will have infinite loop
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                // CC: Need reload ThingsToKnow only
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        activityWhatYouGetRowHeight
            .asObservable()
            .filter {
                return $0 > 0
            }
            .take(1)
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel
            .buyNowButtonEnabled
            .driveNext { [weak self] (value: Bool) in

                self?.buyNowButton.enabled = value
                if value == false {
                    self?.buyNowButton.backgroundColor = UIColor.faveDarkGray()
                } else {
                    self?.buyNowButton.backgroundColor = UIColor.faveGreen()
                }

            }
            .addDisposableTo(disposeBag)

        if viewModel.shouldHideBuyButton {
            buyNowButton.hidden = true
            chatButton.setTitle("ADD TO CHAT", forState: UIControlState.Normal)
        } else {
            buyNowButton.hidden = false
            chatButton.setTitle("CHAT", forState: UIControlState.Normal)
        }
    }
}

// MARK:- UITableViewDatasource+Delegate
extension ListingViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.listingDetails.value == nil ? 0 : ListingSection.Count.rawValue
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case ListingSection.ThingsToKnow.rawValue:
            return viewModel.hasThingsToKnow ? 1 : 0
        case ListingSection.WhatYouGet.rawValue:
            return viewModel.hasWhatYouGet ? 1 : 0
        case ListingSection.Review.rawValue:
            return viewModel.reviewsCount
        case ListingSection.Info.rawValue:
            return viewModel.hasInfo ? 1 : 0

        case ListingSection.Book.rawValue:
            if let _ = viewModel.listingDetails.value as? ListingOpenVoucher {
                return 1
            }
            if let _ = viewModel.listingDetails.value as? ListingTimeSlot {
                return 0
            }
            return 0

        case ListingSection.PromoCode.rawValue:

            if let _ = viewModel.listingDetails.value?.purchaseDetails.promoSavingsUserVisible, let _ = viewModel.listingDetails.value?.purchaseDetails.promoCode {
                return 1
            }
            return 0

        case ListingSection.Collection.rawValue:
            return viewModel.listingDetails.value?.collections?.count > 0 ?  1 : 0

        case ListingSection.DateTimeSlot.rawValue:
            if let listing = viewModel.listingDetails.value as? ListingTimeSlot {
                return listing.classSessions.count > 0 ? 1 : 0
            }
            return 0

        case ListingSection.Cancellation.rawValue:
            if ((viewModel.hasCancellationPolicy == true) || (viewModel.hasFavePromise == true)) {
                return 1
            } else {
                return 0
            }

        case ListingSection.Location.rawValue:
            guard let type = viewModel.listingDetails.value?.company.companyType else {
                return 0
            }
            if type == .online {
                return 0
            } else {
                return 1
            }

        default:
            if viewModel.listingDetails.value == nil {
                return 0
            } else { return 1 }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.section {
        case ListingSection.Photo.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingHeaderPhotoTableViewCell, forIndexPath: indexPath) as! ListingHeaderPhotoTableViewCell
            let cellViewModel = ListingHeaderPhotoTableViewCellViewModel(listing: viewModel.listingDetails.value!)
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case ListingSection.Detail.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingDetailsTableViewCell, forIndexPath: indexPath) as! ListingDetailsTableViewCell
            let cellViewModel = ListingDetailsTableViewCellViewModel(listing: viewModel.listingDetails.value!)
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case ListingSection.About.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingAboutTableViewCell, forIndexPath: indexPath) as! ListingAboutTableViewCell
            let description = viewModel.listingDetails.value?.listingDescription.emptyOnNil()
            let cellViewModel = ListingAboutTableViewCellViewModel(aboutText: description!, readMore: readMore)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case ListingSection.Book.rawValue:
            if let listingOpenVoucher = viewModel.listingDetails.value as? ListingOpenVoucher {
                let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingBuyNowTableViewCell, forIndexPath: indexPath) as! ListingBuyNowTableViewCell
                let cellViewModel = ListingBuyNowTableViewCellViewModel(listingOpenVoucher: listingOpenVoucher)
                cell.viewModel = cellViewModel

                cell.bind()

                return cell
            }

            return tableView.dequeueReusableCellWithIdentifier(literal.ListingBuyNowTableViewCell, forIndexPath: indexPath) as! ListingBuyNowTableViewCell

        case ListingSection.DateTimeSlot.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingDateTimeSlotTableViewCell, forIndexPath: indexPath) as! ListingDateTimeSlotTableViewCell
            return cell

        case ListingSection.Outlet.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingOutletTableViewCell, forIndexPath: indexPath) as! ListingOutletTableViewCell
            let cellViewModel = ListingOutletTableViewCellViewModel(outletSearch: (viewModel.listingDetails.value?.outlet)!)
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case ListingSection.MultipleOutlets.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ListingMultipleOutletsTableViewCell), forIndexPath: indexPath) as! ListingMultipleOutletsTableViewCell
            let cellViewModel = ActivityMultipleOutletsCellViewModel(numberOfOutlet: viewModel.listingDetails.value?.totalRedeemableOutlets)
            cell.viewModel = cellViewModel
            return cell

        case ListingSection.Info.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingStandardInfoTableViewCell, forIndexPath: indexPath) as! ListingStandardInfoTableViewCell
            cell.descriptionLabel.text = viewModel.listingDetails.value?.tips
            cell.descriptionLabel.lineSpacing = 2.2
            cell.descriptionLabel.textAlignment = .Left
            return cell

        case ListingSection.Cancellation.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingCancellationTableViewCell, forIndexPath: indexPath) as! ListingCancellationTableViewCell

            let cellViewModel = ListingCancellationTableViewCellViewModel(cancellationPolicy: (viewModel.listingDetails.value?.cancellationPolicy), showPolicy: (viewModel.hasCancellationPolicy), showPromise: (viewModel.hasFavePromise))
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case ListingSection.Gallery.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingGalleryTableViewCell, forIndexPath: indexPath) as! ListingGalleryTableViewCell
            cell.setImages((viewModel.listingDetails.value?.galleryImages)!)

            cell.delegate = self
            return cell

        case ListingSection.Collection.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingCollectionDetailTableViewCell, forIndexPath: indexPath) as! ListingCollectionDetailTableViewCell
            cell.selectionStyle = .None
            let cellViewModel = ListingCollectionDetailTableViewCellViewModel(collections: (viewModel.listingDetails.value?.collections)!)
            cell.viewModel = cellViewModel
            cell.bind()

            return cell

        case ListingSection.Review.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingReviewTableViewCell, forIndexPath: indexPath) as! ListingReviewTableViewCell
            let cellViewModel = ListingReviewTableViewCellViewModel(review: viewModel.listingDetails.value!.company.reviews![indexPath.row])
            cell.viewModel = cellViewModel
            return cell

        case ListingSection.PromoCode.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingPromoCodeTableViewCell, forIndexPath: indexPath) as! ListingPromoCodeTableViewCell

            let cellViewModel = ListingPromoCodeTableViewCellViewModel(promoSavings: viewModel.listingDetails.value!.purchaseDetails.promoSavingsUserVisible, promoCode: viewModel.listingDetails.value!.purchaseDetails.promoCode)

            cell.viewModel = cellViewModel
            cell.bind()

            cell.selectionStyle = .None

            return cell

        case ListingSection.ThingsToKnow.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingThingsToKnowTableViewCell, forIndexPath: indexPath) as! ListingThingsToKnowTableViewCell
            let cellViewModel = ListingThingsToKnowTableViewCellViewModel(listing: viewModel.listingDetails.value!, cellHeight: activityThingsToKnowRowHeight)
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case ListingSection.WhatYouGet.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingWhatYouGetTableViewCell, forIndexPath: indexPath) as! ListingWhatYouGetTableViewCell
            let cellViewModel = ListingWhatYouGetTableViewCellModel(listing: viewModel.listingDetails.value!, cellHeight: activityWhatYouGetRowHeight)
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        case ListingSection.Location.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ListingOutletLocationTableViewCell, forIndexPath: indexPath) as! ListingOutletLocationTableViewCell
            let cellViewModel = OutletContactViewModel(outlet: (viewModel.listingDetails.value?.outlet)!)
            cell.viewModel = cellViewModel
            cell.bind()
            return cell

        default:
            return UITableViewCell()
        }
    }
}

extension ListingViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case ListingSection.Detail.rawValue:
            return UITableViewAutomaticDimension

        case ListingSection.Book.rawValue:
            return UITableViewAutomaticDimension

        case ListingSection.About.rawValue:
            return (viewModel.listingDetails.value?.listingDescription).emptyOnNil().isEmpty ? 0 : UITableViewAutomaticDimension

        case ListingSection.Photo.rawValue:
            return activityPhotoRowHeight

        case ListingSection.Outlet.rawValue:
            return activityOutletRowHeight

        case ListingSection.MultipleOutlets.rawValue:
            if let totalRedeemableOutlets = viewModel.listingDetails.value?.totalRedeemableOutlets where totalRedeemableOutlets > 1 {
                return activityMultipleOutletsRowHeight
            }
            return CGFloat.min

        case ListingSection.Info.rawValue:
            return UITableViewAutomaticDimension

        case ListingSection.ThingsToKnow.rawValue:
            return activityThingsToKnowRowHeight.value

        case ListingSection.WhatYouGet.rawValue:
            return activityWhatYouGetRowHeight.value

        case ListingSection.Gallery.rawValue:
            if (viewModel.listingDetails.value?.galleryImages.count == 0) {
                return CGFloat.min
            } else {
                return activityGallaryRowHeight
            }

        case ListingSection.Cancellation.rawValue:
            return UITableViewAutomaticDimension

        case ListingSection.Collection.rawValue:
            return activityCollectionRowHeight

        case ListingSection.PromoCode.rawValue:
            return activityPromoCodeRowHeight

        case ListingSection.Review.rawValue:
            return UITableViewAutomaticDimension

        case ListingSection.Location.rawValue:
            guard let type = viewModel.listingDetails.value?.company.companyType else {
                return 0
            }
            if type == .online {
                return 0
            } else {
                return UITableViewAutomaticDimension
            }

        default:
            return UITableViewAutomaticDimension
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if section == ListingSection.Info.rawValue && viewModel.hasInfo {
            return activityInfoHeaderHeight
        }

        if section == ListingSection.Outlet.rawValue {
            return activityInfoHeaderHeight
        }

        if section == ListingSection.Gallery.rawValue {
            if (viewModel.listingDetails.value?.galleryImages.count == 0) {
                return CGFloat.min
            } else {
                return activityInfoHeaderHeight
            }
        }

        if section == ListingSection.Review.rawValue && viewModel.reviewsCount > 0 {
            return activityInfoHeaderHeight
        }

        if section == ListingSection.ThingsToKnow.rawValue && viewModel.hasThingsToKnow {
            return activityInfoHeaderHeight
        }

        if section == ListingSection.WhatYouGet.rawValue && viewModel.hasWhatYouGet {
            return activityInfoHeaderHeight
        }

        if section == ListingSection.Location.rawValue {
            guard let type = viewModel.listingDetails.value?.company.companyType else {
                return 0
            }
            if type == .online {
                return 0
            } else {
                return activityInfoHeaderHeight
            }
        }

        if section == ListingSection.Cancellation.rawValue {
            if ((viewModel.hasCancellationPolicy == true) ||  (viewModel.hasFavePromise == true)) {
                return activityInfoHeaderHeight
            }
        }

        return CGFloat.min
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == ListingSection.Info.rawValue {
            let header = UINib(nibName: "ListingGeneralSectionHeader",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
            header.headerTitle.text = NSLocalizedString("tips", comment: "")
            return header
        }

        if section == ListingSection.Review.rawValue {
            let header = UINib(nibName: "ListingReviewHeaderSectionView",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingReviewHeaderSectionView
            header.reviewsButton.rx_tap.asDriver().driveNext({ [weak self] in
                let vc = ReviewViewController.build(ReviewViewControllerViewModel(companyId: (self?.viewModel.listingDetails.value!.company.id)!))
                self?.navigationController?.pushViewController(vc, animated: true)
                }).addDisposableTo(disposeBag)
            return header
        }

        if section == ListingSection.Outlet.rawValue {
            let header = UINib(nibName: "ListingGeneralSectionHeader",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
            header.headerTitle.text = NSLocalizedString("outlet", comment: "")
            return header
        }

        if section == ListingSection.Cancellation.rawValue {
            if((viewModel.hasFavePromise == true) || (viewModel.hasCancellationPolicy == true)) {
                let header = UINib(nibName: "ListingGeneralSectionHeader",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
                header.headerTitle.text = NSLocalizedString("cancellation_policy", comment: "")
                return header
            } else { return nil }

        }

        if section == ListingSection.Gallery.rawValue {
            if (viewModel.listingDetails.value?.galleryImages.count > 0) {
                let header = UINib(nibName: "ListingGeneralSectionHeader",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
                header.headerTitle.text = NSLocalizedString("photos", comment: "")
                return header
            }
        }

        if section == ListingSection.ThingsToKnow.rawValue {
            let header = UINib(nibName: "ListingGeneralSectionHeader",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
            header.headerTitle.text = NSLocalizedString("things_to_know", comment: "")
            return header
        }

        if section == ListingSection.WhatYouGet.rawValue {
            let header = UINib(nibName: "ListingGeneralSectionHeader", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
            header.headerTitle.text = "What you get"
            return header
        }

        if section == ListingSection.Location.rawValue {
            guard let type = viewModel.listingDetails.value?.company.companyType else {
                return nil
            }
            let header = UINib(nibName: "ListingGeneralSectionHeader",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingGeneralSectionHeader
            header.headerTitle.text = NSLocalizedString("location", comment: "")
            if type == .online {
                return nil
            } else {
                return header
            }

        }

        return nil
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        let type = viewModel.listingDetails.value?.company.companyType
        if section == ListingSection.ThingsToKnow.rawValue && viewModel.hasThingsToKnow && type != .online {
            return 70
        }
        return CGFloat.min
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == ListingSection.ThingsToKnow.rawValue {
            if viewModel.listingDetails.value == nil {
                return nil
            } else {
                guard let type = viewModel.listingDetails.value?.company.companyType else {
                    return nil
                }
                let footer = UINib(nibName: "ListingThingsToKnowFooter",bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! ListingThingsToKnowFooter

                let footerViewModel = ListingThingsToKnowFooterViewModel()
                footer.viewModel = footerViewModel
                //header.headerTitle.text = NSLocalizedliteral."location", comment: "")
                if type == .online {
                    return nil
                } else {
                    return footer
                }
            }
        }

        return nil
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch indexPath.section {
        case ListingSection.Outlet.rawValue:
            guard let viewControllers = self.navigationController?.viewControllers,
                let outletVC = viewControllers[safe:viewControllers.count - 2] else {
                    return
            }

            if outletVC is OutletViewController {
                self.navigationController?.popViewControllerAnimated(true)
                return
            }

            let vc = OutletViewController.build(OutletViewControllerViewModel(outletId: viewModel.listingDetails.value!.outlet.id,
                companyId: viewModel.listingDetails.value!.company.id))
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            return

        case ListingSection.Collection.rawValue:

            let collection = viewModel.listingDetails.value?.collections![0]

            let vc = ListingsCollectionViewController.build(ListingsCollectionViewControllerViewModel(collectionId: (collection?.id)!))

            self.navigationController?.pushViewController(vc, animated: true)
            return

        case ListingSection.DateTimeSlot.rawValue:

            if ((viewModel.listingDetails.value as? ListingTimeSlot) != nil) {
                self.buyNowDidTap(nil)
            }
            return

        case ListingSection.MultipleOutlets.rawValue:
            if let listingDetails = viewModel.listingDetails.value {

                let vc = MultipleOutletsViewController.build(MultipleOutletsViewControllerViewModel(listing: listingDetails))
                let nvc = UINavigationController(rootViewController: vc)

                viewModel.lightHouseService
                    .navigate
                    .onNext { (viewController) in
                        viewController.presentViewController(nvc, animated: true, completion: nil)
                }
                /*
                let vc = MultipleOutletsViewController.build(MultipleOutletsViewControllerViewModel(listing: listingDetails))
                self.navigationController?.pushViewController(vc, animated: true)
                */
            }
            return

        case ListingSection.About.rawValue:

            readMore = !readMore
            self.tableView.reloadItemsAtIndexPaths([indexPath], animationStyle: .Automatic)
            return

        default:
            return
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y  > 150 {
            self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
            self.title = viewModel.listingDetails.value?.name
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"ui-gradient"), forBarMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.title = ""
        }
    }
}

// MARK:- Build
extension ListingViewController: Buildable {
    static func build(builder: ListingViewModel) -> ListingViewController {
        let storyboard = UIStoryboard(name: "Listing", bundle: nil)
        builder.refresh()
        let viewController = storyboard.instantiateViewControllerWithIdentifier(literal.ListingViewController) as! ListingViewController
        viewController.viewModel = builder
        return viewController
    }
}

extension ListingViewController : DeepLinkBuildable {
    static func build(deepLink: String, params: [String : AnyObject]?) -> ListingViewController? {
        let urlComponents = NSURLComponents(string: deepLink)
        let urlParams = urlComponents?.queryItems

        let listingId: Int?

        if let listing_id = urlParams?.filter({$0.name == "listing_id"}).first?.value {
            listingId = Int(listing_id)
        } else {
            guard let params = params, let listing_id = params["listing_id"] as? String else {return nil}
            listingId = Int(listing_id)
        }

        if let listingId = listingId {
            // CC: Support later
            return build(ListingViewModel(listingId: listingId, outletId: nil, functionality: Variable(ListingViewModelFunctionality.Initiate())))
        }

        return nil
    }
}

extension ListingViewController: ListingGalleryTableViewCellDelegate {
    func didTapOnImage(index: Int, imageView: UIView) {
        let photoBrowser = IDMPhotoBrowser(photoURLs: self.viewModel.listingDetails.value?.galleryImages, animatedFromView: imageView)
        photoBrowser.setInitialPageIndex(UInt(index))
        self.navigationController?.presentViewController(photoBrowser, animated: true, completion: nil)
    }
}

extension ListingViewController {
    func getTooltipShown () -> Bool {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("ToolTip_Seen") {
            return true
        }
        return false
    }
    func saveToolTipShown () {
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "ToolTip_Seen")
    }
}
