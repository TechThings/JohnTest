//
//  RedeemMultipleOutletView.swift
//  MultipleOutlet
//
//  Created by Thanh KFit on 10/14/16.
//  Copyright © 2016 Thanh KFit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class RedeemMultipleOutletView: View {

    class func instanceFromNib() -> UIView {
        return UINib(nibName: literal.RedeemMultipleOutletView, bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }

    var viewModel: RedeemMultipleOutletViewModel! {
        didSet {
            bind()
        }
    }

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: KFITLabel!

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
        let view = NSBundle.mainBundle().loadNibNamed(literal.RedeemMultipleOutletView, owner: self, options: nil)![0] as! UIView
        view.frame = bounds
        addSubview(view)
    }

    override func updateConstraints() {
        setup()
        super.updateConstraints()
    }

    private func registerCell() {
        tableView.registerNib(UINib(nibName: literal.RedeemMutipleOutletTableViewCell, bundle: nil), forCellReuseIdentifier: literal.RedeemMutipleOutletTableViewCell)
    }

    private func setup() {

        descriptionLabel.text = NSLocalizedString("you_must_be_at_right_and_time_to_redeem", comment: "")
        descriptionLabel.lineSpacing = 2.3

        cancelButton.layer.cornerRadius = 3.0
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = UIColor(red: 153.0/255.0, green: 169.0/255.0, blue: 179.0/255.0, alpha: 0.45).CGColor
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), forState: UIControlState.Normal)

        redeemButton.layer.cornerRadius = 3.0
        redeemButton.setTitle(NSLocalizedString("redeem_now", comment: ""), forState: UIControlState.Normal)

        contentView.layer.cornerRadius = 3.0

        tableView.delegate = self
        tableView.dataSource = self
        registerCell()
    }
}

extension RedeemMultipleOutletView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outlets.value.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(literal.RedeemMutipleOutletTableViewCell, forIndexPath: indexPath) as! RedeemMutipleOutletTableViewCell
        let outlet = viewModel.outlets.value[indexPath.row]
        let selected = (viewModel.selectedOutletId.value == outlet.id)
        let cellViewModel = RedeemMultipleOutletTableViewCellViewModel(outlet: outlet, selected: selected)
        cell.viewModel = cellViewModel
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return viewModel.redeemOutletTableViewCellHeight
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let outlet = viewModel.outlets.value[indexPath.row]
        viewModel.selectedOutletId.value = outlet.id

        let cells = tableView.visibleCells
        for cell in cells {

            if let cell = cell as? RedeemMutipleOutletTableViewCell {
                let cellViewModel = cell.viewModel

                if cellViewModel.outlet.id == outlet.id {
                    cellViewModel.updateSelectedImage(true)
                } else {
                    cellViewModel.updateSelectedImage(false)
                }
            }
        }
    }

}

extension RedeemMultipleOutletView: ViewModelBindable {
    func bind() {
        viewModel.outlets
            .asDriver()
            .driveNext { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel.tableViewHeight
            .asDriver()
            .drive(tableViewHeight.rx_constant)
            .addDisposableTo(disposeBag)

        cancelButton.rx_tap
            .bindTo(viewModel.cancelButtonDidTap)
            .addDisposableTo(disposeBag)

        redeemButton.rx_tap
            .bindTo(viewModel.redeemButtonDidTap)
            .addDisposableTo(disposeBag)
    }
}
