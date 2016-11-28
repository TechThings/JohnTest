//
//  ListingsCollectionView.swift
//  FAVE
//
//  Created by Nazih Shoura on 13/07/2016.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class ListingsCollectionView: View {

    // MARK:- ViewModel
    var viewModel: ListingsCollectionViewModel! {
        didSet { bind() }
    }

    // MARK:- Constant

    // MARK:- IBOutlet
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var openListingsCollectionButton: UIButton!
    @IBOutlet weak var offerCountLabel: UILabel!

    @IBAction func openListingsCollectionButtonDidTab(sender: AnyObject) {
        let vc = ListingsCollectionViewController.build(ListingsCollectionViewControllerViewModel(collectionId: viewModel.listingsCollection.id))

        viewModel.lightHouseService
        .navigate
        .onNext { (viewController) in
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK:- Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func load() {
        let view = NSBundle.mainBundle().loadNibNamed(self.subjectLabel, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        super.updateConstraints()
    }
}

// MARK:- ViewModelBinldable
extension ListingsCollectionView: ViewModelBindable {
    func bind() {
        viewModel
            .imageURL
            .driveNext { [weak self]
                (value) in
                if let value = value {
                    self?.photoImageView.kf_setImageWithURL(
                        value
                        , placeholderImage: UIImage(named: "image-placeholder")
                        , optionsInfo: [.Transition(ImageTransition.Fade(0.5))])
                } else {
                    self?.photoImageView.image = UIImage(named: "image-placeholder")
                }
            }.addDisposableTo(disposeBag)

        viewModel
        .offerCountText
        .drive(offerCountLabel.rx_text)
        .addDisposableTo(disposeBag)
    }
}
