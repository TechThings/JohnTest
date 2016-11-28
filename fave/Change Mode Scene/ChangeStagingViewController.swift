//
//  ChangeStagingViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 8/29/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit

final class ChangeStagingViewController: ViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel: ChangeStagingViewControllerViewModel!

    @IBAction func dismissButtonDidTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: literal.StagingContentTableViewCell, bundle: nil), forCellReuseIdentifier: literal.StagingContentTableViewCell)
        tableView.registerNib(UINib(nibName: literal.ChangeStagingSubmitTableViewCell, bundle: nil), forCellReuseIdentifier: literal.ChangeStagingSubmitTableViewCell)
        bind()
    }
}

extension ChangeStagingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Mode.caseCount + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == Mode.caseCount {
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.ChangeStagingSubmitTableViewCell, forIndexPath: indexPath) as! ChangeStagingSubmitTableViewCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.StagingContentTableViewCell, forIndexPath: indexPath) as! StagingContentTableViewCell

            if viewModel.current.value == indexPath.row {
                cell.selectedCheckBox.image = UIImage(named: "ic_checkbox_selected")
            } else {
                cell.selectedCheckBox.image = UIImage(named: "ic_checkbox")
            }

            if let mode = Mode(rawValue: indexPath.row) {
                cell.label.text = mode.name
            }

            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let _ = Mode(rawValue: indexPath.row) {
            viewModel.current.value = indexPath.row
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == Mode.caseCount {
            return 75
        }
        return 55
    }
}

extension ChangeStagingViewController: ChangeStagingSubmitDelegate {
    func changeStagingDidChange() {
        if let mode = Mode(rawValue: viewModel.current.value) {
            viewModel.app.update(mode: mode)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension ChangeStagingViewController: ViewModelBindable {
    func bind() {
        viewModel
            .current
            .asDriver()
            .driveNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
}

extension ChangeStagingViewController: Buildable {
    static func build(builder: ChangeStagingViewControllerViewModel) -> ChangeStagingViewController {
        let storyboard = UIStoryboard(name: "ChangeStaging", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.ChangeStagingViewController) as! ChangeStagingViewController
        vc.viewModel = builder
        return vc
    }
}
