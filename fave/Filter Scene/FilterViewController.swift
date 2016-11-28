//
//  FilterViewController.swift
//  FAVE
//
//  Created by Thanh KFit on 9/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol FilterUpdateDelegate: class {
    func filterDidUpdate(state: ListingsViewModelState)
}

final class FilterViewController: ViewController {

    weak var delegate: FilterUpdateDelegate?

    // MARK:- IBOutlet
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK:- ViewModel
    var viewModel: FilterViewControllerViewModel!

    // MARK:- Constant

    func registerCell() {
        self.tableView.registerNib(UINib(nibName: literal.FilterSectionSingleTableViewCell, bundle: nil), forCellReuseIdentifier: literal.FilterSectionSingleTableViewCell)
        self.tableView.registerNib(UINib(nibName: literal.FilterCategoriesTableViewCell, bundle: nil), forCellReuseIdentifier: literal.FilterCategoriesTableViewCell)
    }

    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        bind()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.setAsActive()
        self.navigationController?.navigationBarHidden = false
        viewModel.trackingScreen.trackingScreen(screenName.SCREEN_NEARBY)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func didTapDoneButton(sender: AnyObject) {
        delegate?.filterDidUpdate(viewModel.state)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTapResetButton(sender: AnyObject) {
        viewModel.resetFilter()
        refreshCell()
    }

    func refreshCell() {
        let cells = tableView.visibleCells
        for cell in cells {
            if let cell = cell as? FilterSectionSingleTableViewCell {
                cell.refresh()
            } else if let cell = cell as? FilterCategoriesTableViewCell {
                cell.refresh()
            }
        }
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellModel = viewModel.sections.value[indexPath.row]

        switch cellModel.viewType {
        case .Single: return 115
        case .SubCategories:
            if let subCategories = cellModel.data as? [SubCategory] {
                if subCategories.count == 0 {return CGFloat.min}

                let numberOfRow = ceil(CGFloat(subCategories.count)/5)
                let heightForRow = (UIScreen.mainWidth - 60)/5 + 25
                return (numberOfRow * heightForRow) + 55
            }
            return CGFloat.min
        }
    }
}

extension FilterViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections.value.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellModel = viewModel.sections.value[indexPath.row]
        switch cellModel.viewType {

        case .Single:
            var selectedId: Int? = nil
            switch cellModel.queryType {
            case .Distances:
                selectedId = viewModel.state.distances
            case .PriceRanges:
                selectedId = viewModel.state.priceRanges
            default:
                break
            }

            let cellViewModel = FilterSectionSingleTableViewCellViewModel(section: cellModel, selectedId: selectedId)
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.FilterSectionSingleTableViewCell, forIndexPath: indexPath) as! FilterSectionSingleTableViewCell
            cell.viewModel = cellViewModel
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            return cell

        case .SubCategories:
            var subCategories = [SubCategory]()
            if let data = cellModel.data as? [SubCategory] {
                subCategories = data
            }
            let cellViewModel = FilterCategoriesCellViewModel(categories: subCategories, selectedCategories: viewModel.state.subCategories)
            let cell = tableView.dequeueReusableCellWithIdentifier(literal.FilterCategoriesTableViewCell, forIndexPath: indexPath) as! FilterCategoriesTableViewCell
            cell.viewModel = cellViewModel
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.delegate = self
            return cell
        }
    }
}

extension FilterViewController: FilterSectionSingleTableViewCellDelegate, FilterCategoriesTableViewCellDelegate {
    func filterSectionSingleDidSelected(singleFilter: FilterSingleSelected?) {
        viewModel.updateSingleSelected(singleFilter)
    }

    func filterCategoriesDidSelected(categories categories: [SubCategory]) {
        viewModel.updateCategoriesSelected(categories)
    }
}

// MARK:- ViewModelBinldable
extension FilterViewController: ViewModelBindable {
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

        viewModel.sections
            .asDriver()
            .driveNext { [weak self] _ in
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)

        viewModel
            .title
            .drive(titleLabel.rx_text)
            .addDisposableTo(disposeBag)
    }
}

// MARK:- Refreshable
extension FilterViewController: Refreshable {
    func refresh() {
        viewModel.refresh()
    }
}

// MARK:- Buildable
extension FilterViewController: Buildable {
    final class func build(builder: FilterViewControllerViewModel) -> FilterViewController {
        let storyboard = UIStoryboard(name: "Filter", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(literal.FilterViewController) as! FilterViewController
        vc.viewModel = builder
        return vc
    }
}
