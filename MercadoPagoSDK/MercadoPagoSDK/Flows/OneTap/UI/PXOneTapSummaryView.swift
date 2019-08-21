//
//  PXOneTapSummaryView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit

class Row {
    var data: OneTapHeaderSummaryData
    var view: PXOneTapSummaryRowView
    var constraint: NSLayoutConstraint
    var rowHeight: CGFloat

    init(data: OneTapHeaderSummaryData, view: PXOneTapSummaryRowView, constraint: NSLayoutConstraint, rowHeight: CGFloat) {
        self.data = data
        self.view = view
        self.constraint = constraint
        self.rowHeight = rowHeight
    }

    func updateData(_ data: OneTapHeaderSummaryData) {
        self.data = data
    }
}

class PXOneTapSummaryView: PXComponentView {
    private var data: [OneTapHeaderSummaryData] = [] {
        willSet {
            if data.count > newValue.count {
                removeSummaryRows(oldValue: data, newValue: newValue, animated: true)
            } else if data.count < newValue.count {
                addSummaryRows(oldValue: data, newValue: newValue, animated: true)

//                let newRowsData = getNewRowsData(oldValue: data, newValue: newValue)
//                var newRows: [Row] = []
//                for rowData in newRowsData {
//                    let rowView = getSummaryRowView(with: rowData)
//                    let rowHeight = rowView.getTotalHeightNeeded()
//                    let row = Row(data: rowData, view: rowView, constraint: nil, rowHeight: rowHeight)
//                    newRows.insert(row, at: 1)
//                }
            } else {
                updateAllRows(newData: newValue)
            }
        }
        didSet {
            print("****** la cantidad de datas es: ", data.count)
        }
    }
    private weak var delegate: PXOneTapSummaryProtocol?
    private var rowViews: [PXOneTapSummaryRowView] = []
    private var rows: [Row] = [] {
        didSet {
            print("****** la cantidad de rows es: ", rows.count)
            if rows.count < oldValue.count {
                //DELETE EXTRA ROWS
            } else if rows.count > oldValue.count {
                //ADD MISSING ROWS
            } else {
                //UPDATE ALL ROWS
            }
        }
    }

    var currentAnimator: UIViewPropertyAnimator?

    init(data: [OneTapHeaderSummaryData] = [], delegate: PXOneTapSummaryProtocol) {
        self.data = data.reversed()
        self.delegate = delegate
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getNewRowsData(oldValue: [OneTapHeaderSummaryData], newValue: [OneTapHeaderSummaryData]) -> [OneTapHeaderSummaryData] {
        let rowsToAdd = newValue.count - oldValue.count
        var newRowsData: [OneTapHeaderSummaryData] = []

        for index in 1...rowsToAdd {
            newRowsData.append(newValue[index])
        }

        return newRowsData
    }

    func render() {
        self.removeAllSubviews()
        self.pinContentViewToBottom()
        self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

        var offset: CGFloat = 0
        for row in self.data {
            let rowView = self.getSummaryRowView(with: row)
            let margin = rowView.getRowMargin()

            offset += margin

            self.addSubview(rowView)
            let rowViewConstraint = PXLayout.pinBottom(view: rowView, withMargin: offset)

            offset += rowView.getRowHeight()

            self.rows.append(Row(data: row, view: rowView, constraint: rowViewConstraint, rowHeight: rowView.getTotalHeightNeeded()))

            if row.isTotal {
                let separatorView = UIView()
                separatorView.backgroundColor = ThemeManager.shared.boldLabelTintColor()
                separatorView.alpha = 0.1
                separatorView.translatesAutoresizingMaskIntoConstraints = false

                self.addSubview(separatorView)
                offset += margin
                PXLayout.pinBottom(view: separatorView, withMargin: offset).isActive = true
                PXLayout.setHeight(owner: separatorView, height: 1).isActive = true
                PXLayout.pinLeft(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinRight(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
            }

            PXLayout.centerHorizontally(view: rowView).isActive = true
            PXLayout.pinLeft(view: rowView, withMargin: 0).isActive = true
            PXLayout.pinRight(view: rowView, withMargin: 0).isActive = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRow(_:)))
            rowView.addGestureRecognizer(tap)
            rowView.isUserInteractionEnabled = true
        }
    }

    func tapRow(_ sender: UITapGestureRecognizer) {
        if let rowView = sender.view as? PXOneTapSummaryRowView,
            let type = rowView.getData().type,
            let action = rowAction(for: type) {
                action()
        }
    }

    private func rowAction(for type: PXOneTapSummaryRowView.RowType) -> PXOneTapSummaryRowView.Handler? {
        switch type {
        case .charges:
            return self.delegate?.didTapCharges
        case .discount:
            return self.delegate?.didTapDiscount
        default:
            return nil
        }
    }

    func removeSummaryRows(oldValue: [OneTapHeaderSummaryData], newValue: [OneTapHeaderSummaryData], animated: Bool) {
        let rowsToRemove = oldValue.count - newValue.count
        var indexesToRemove: [Int] = []

        for index in 1...rowsToRemove {
            indexesToRemove.append(index)
        }

        let animator = UIViewPropertyAnimator(duration: animated ? 0.5 : 0.0, dampingRatio: 1, animations: nil)
        animator.isInterruptible = true

        var distanceDelta: CGFloat = 0

        for (index, row) in rows.enumerated() {
            if indexesToRemove.contains(index) {
                distanceDelta += row.rowHeight

                animator.addAnimations {
                    row.view.alpha = 0
                    self.layoutIfNeeded()
                }

                animator.addCompletion { (_) in
                    print("****** Completion del remove index: ", index)
                    self.currentAnimator = nil
                    row.view.removeFromSuperview()
                    self.rows.remove(at: index)
                    self.updateAllRows(newData: newValue)
                }
            }

            if !row.data.isTotal {
                animator.addAnimations {
                    row.constraint.constant += distanceDelta
                    self.layoutIfNeeded()
                }
            }
        }

        if let currentAnimator = self.currentAnimator {
            currentAnimator.stopAnimation(true)
            print("****** Stop Animation en el remove")
        }
        self.currentAnimator = animator
        animator.startAnimation()
    }

    func addSummaryRows(oldValue: [OneTapHeaderSummaryData], newValue: [OneTapHeaderSummaryData], animated: Bool) {
        let rowsToAdd = newValue.count - oldValue.count
        var newRowsData: [OneTapHeaderSummaryData] = []

        for index in 1...rowsToAdd {
            newRowsData.append(newValue[index])
        }

        let animator = UIViewPropertyAnimator(duration: animated ? 0.5 : 0.0, dampingRatio: 1, animations: nil)
        animator.isInterruptible = true

        var distanceDelta: CGFloat = 0

        var newRows: [Row] = []
        for rowData in newRowsData {
            let rowView = getSummaryRowView(with: rowData)
            let totalHeight = rowView.getTotalHeightNeeded()
            distanceDelta += totalHeight
            rowView.alpha = 0

            var constraintConstant = rows[1].constraint.constant
            constraintConstant += totalHeight

            self.addSubview(rowView)
            let constraint = PXLayout.pinBottom(view: rowView, withMargin: -constraintConstant)
            PXLayout.centerHorizontally(view: rowView).isActive = true
            PXLayout.pinLeft(view: rowView, withMargin: 0).isActive = true
            PXLayout.pinRight(view: rowView, withMargin: 0).isActive = true
            self.layoutIfNeeded()

            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRow(_:)))
            rowView.addGestureRecognizer(tap)
            rowView.isUserInteractionEnabled = true

            let newRow = Row(data: rowData, view: rowView, constraint: constraint, rowHeight: totalHeight)
            newRows.append(newRow)
            rows.insert(newRow, at: 1)
        }

        for (index, row) in rows.enumerated() where !row.data.isTotal {
            animator.addAnimations {
                row.view.alpha = 1
                row.constraint.constant -= distanceDelta
                self.layoutIfNeeded()
            }

            animator.addCompletion { (_) in
                print("****** Completion del add en el index: ", index)
                self.currentAnimator = nil
                self.updateAllRows(newData: newValue)
            }
        }

//        animator.addCompletion { (_) in
//            print("****** Completion en el add")
//            self.currentAnimator = nil
//            self.updateAllRows(newData: newValue)
//        }

        if let currentAnimator = self.currentAnimator {
            currentAnimator.stopAnimation(true)
            self.rows.removeLast()
            print("****** Stop Animation en el add")
        }
        self.currentAnimator = animator
        animator.startAnimation()
    }

    func updateAllRows(newData: [OneTapHeaderSummaryData]) {
        print("**** Update")
        for (index, row) in rows.enumerated() {
            let newRowData = newData[index]
            row.view.update(newRowData)
            row.updateData(newRowData)
        }
    }

    func update(_ newData: [OneTapHeaderSummaryData], hideAnimatedView: Bool = false) {
        self.data = newData.reversed()
    }

    func getSummaryRowView(with data: OneTapHeaderSummaryData) -> PXOneTapSummaryRowView {
        let rowView = PXOneTapSummaryRowView(data: data)
        return rowView
    }
}
