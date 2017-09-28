/*
 Copyright 2017 ArcTouch LLC.
 All rights reserved.
 
 This file, its contents, concepts, methods, behavior, and operation
 (collectively the "Software") are protected by trade secret, patent,
 and copyright laws. The use of the Software is governed by a license
 agreement. Disclosure of the Software to third parties, in any form,
 in whole or in part, is expressly prohibited except as authorized by
 the license agreement.
 */

import UIKit
import RxCocoa
import RxSwift
import ActionSheetPicker_3_0

final class ShowsProgressViewController: UIViewController, ShowsProgressView {
  var presenter: ShowsProgressPresenter!
  private let disposeBag = DisposeBag()
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var infoLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    guard presenter != nil else {
      fatalError("view loaded without a presenter")
    }

    guard let dataSource = presenter.dataSource as? UITableViewDataSource else {
      fatalError("dataSource should be an instance of UITableViewDataSource")
    }

    tableView.dataSource = dataSource

    presenter.viewDidLoad()

    let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
    refreshItem.rx.tap.asDriver().drive(onNext: { [unowned self] in
      self.presenter.updateShows()
      self.tableView.reloadData()
    }).disposed(by: disposeBag)

    let filterItem = UIBarButtonItem(image: R.image.filter(), style: .plain, target: nil, action: nil)
    filterItem.rx.tap.asDriver().drive(onNext: { [unowned self] in
      self.presenter.handleFilter()
    }).disposed(by: disposeBag)

    let directionItem = UIBarButtonItem(image: R.image.direction(), style: .plain, target: nil, action: nil)
    directionItem.rx.tap.asDriver().drive(onNext: { [unowned self] in
      self.presenter.handleDirection()
    }).disposed(by: disposeBag)

    self.navigationItem.rightBarButtonItems = [filterItem, directionItem, refreshItem]
  }

  func newViewModelAvailable(at index: Int) {
    showList()
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
  }

  func updateFinished() {
    showList()
  }

  func showEmptyView() {
    showInfoLabel()
  }

  func reloadList() {
    tableView.reloadData()
  }

  func showOptions(for sorting: [String], for filtering: [String], currentSort: Int, currentFilter: Int) {
    let title = "Sort & Filter"
    let rows = [sorting, filtering]
    let initial = [currentSort, currentFilter]

    let picker = ActionSheetMultipleStringPicker(title: title, rows: rows, initialSelection: initial, doneBlock: { [unowned self] (_, indexes, _) in
      let sortIndex = (indexes?[0] as? Int) ?? 0
      let filterIndex = (indexes?[1] as? Int) ?? 0
      self.presenter.changeSort(to: sortIndex, filter: filterIndex)
      }, cancel: { _ in
    }, origin: self.view)

    picker?.show()
  }

  private func showList() {
    if !tableView.isHidden {
      infoLabel.isHidden = true
      tableView.isHidden = false
    }
  }

  private func showInfoLabel() {
    if !infoLabel.isHidden {
      infoLabel.isHidden = false
      tableView.isHidden = true
    }
  }
}
