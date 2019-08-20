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
    private var oldData: [OneTapHeaderSummaryData] = []
    private var data: [OneTapHeaderSummaryData] = []
    private weak var delegate: PXOneTapSummaryProtocol?
    private var rowViews: [PXOneTapSummaryRowView] = []
    private var rows: [Row] = [] {
        didSet {
            if rows.count < oldValue.count {
                //DELETE EXTRA ROWS
            } else if rows.count > oldValue.count {
                //ADD MISSING ROWS
            } else {
                //UPDATE ALL ROWS
            }
        }
    }


    init(data: [OneTapHeaderSummaryData] = [], delegate: PXOneTapSummaryProtocol) {
        self.data = data
        self.delegate = delegate
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render() {
        self.removeAllSubviews()
        self.pinContentViewToBottom()
        self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

        var offset: CGFloat = 0
        for row in self.data.reversed() {
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

    func removeSummaryRows(animated: Bool) {
        let rowsToRemove = oldData.count - data.count
        var indexesToRemove: [Int] = []

        for index in 1...rowsToRemove {
            indexesToRemove.append(index)
        }

        var animator = PXAnimator(duration: animated ? 0.5 : 0.0, dampingRatio: 1)

        var distanceDelta: CGFloat = 0

        for (index, row) in rows.enumerated() {
            if indexesToRemove.contains(index) {
                distanceDelta += row.rowHeight

                animator.addAnimation(animation: {
                    row.view.alpha = 0
                    self.layoutIfNeeded()
                })

                animator.addCompletion {
                    row.view.removeFromSuperview()
                    self.rows.remove(at: index)
                    self.updateAllRows()
                }
            }

            if !row.data.isTotal {
                animator.addAnimation(animation: {
                    row.constraint.constant += distanceDelta
                    self.layoutIfNeeded()
                })
            }
        }

//        if let currentAnimator = currentAnimator {
//
//        } else {
//            animator.animate()
//        }
//        self.currentAnimator = animator
//
//        animator.addCompletion {
//            self.currentAnimator = nil
//        }
    }

    func addSummaryRows(animated: Bool) {
        let rowsToAdd = self.data.count - oldData.count
        var newRowsData: [OneTapHeaderSummaryData] = []

        for index in 1...rowsToAdd {
            newRowsData.append(self.data.reversed()[index])
        }

        var animator = PXAnimator(duration: animated ? 0.5 : 0.0, dampingRatio: 1)

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

        for row in rows where !row.data.isTotal {
            animator.addAnimation(animation: {
                row.view.alpha = 1
                row.constraint.constant -= distanceDelta
                self.layoutIfNeeded()
            })
        }

        animator.addCompletion {
            self.updateAllRows()
        }

//        self.currentAnimator = animator
//        animator.animate()
//        animator.addCompletion {
//            self.currentAnimator = nil
//        }
    }

    func updateAllRows() {
        for (index, row) in rows.reversed().enumerated() {
            let newRowData = self.data[index]
            row.view.update(newRowData)
            row.updateData(newRowData)
        }
    }

    var currentAnimator: PXAnimator?

    func update(_ newData: [OneTapHeaderSummaryData], hideAnimatedView: Bool = false) {

        self.oldData = data
        self.data = newData

        if data.count < oldData.count {
            removeSummaryRows(animated: true)
        } else if data.count > oldData.count {
            addSummaryRows(animated: true)
        } else {
            updateAllRows()
        }
    }

    func getSummaryRowView(with data: OneTapHeaderSummaryData) -> PXOneTapSummaryRowView {
        let rowView = PXOneTapSummaryRowView(data: data)
        return rowView
    }
}
