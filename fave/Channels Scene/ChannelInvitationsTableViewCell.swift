//
//  ChannelInvitationsTableViewCell.swift
//  FAVE
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelInvitationsTableViewCell: TableViewCell {

    // MARK:- ViewModel
    var viewModel: ChannelInvitationsTableViewCellViewModel! {
        didSet { bind() }
    }

    // MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var invitationsLabel: UILabel!

    var delegate: OutletsSearchTableViewCellModelDelegate?

    // MARK:- Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {

        collectionView.registerNib(UINib(nibName: String(ChannelInvitationCollectionViewCell), bundle: nil), forCellWithReuseIdentifier: String(ChannelInvitationCollectionViewCell))
    }
}

// MARK:- ViewModelBinldable
extension ChannelInvitationsTableViewCell: ViewModelBindable {
    func bind() {
        viewModel
            .channels
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (channels: [Channel]) in
                self?.pageControl.numberOfPages = channels.count
                self?.collectionView.reloadData()
            }.addDisposableTo(rx_reusableDisposeBag)

        viewModel.invitations.drive(invitationsLabel.rx_text).addDisposableTo(rx_reusableDisposeBag)

    }
}

extension ChannelInvitationsTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.channels.value.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellViewModel = ChannelInvitationCollectionViewCellViewModel(channel: Variable(viewModel.channels.value[indexPath.row]))

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(ChannelInvitationCollectionViewCell), forIndexPath: indexPath) as! ChannelInvitationCollectionViewCell

        cell.viewModel = cellViewModel

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.width - 30, 332)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }

}

extension ChannelInvitationsTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(ceil(scrollView.contentOffset.x / collectionView.width))
    }
}
