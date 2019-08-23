//
//  PXOneTapSummaryView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit

class Row: Equatable {
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.rowHeight == rhs.rowHeight && lhs.constraint == rhs.constraint && lhs.view == rhs.view && lhs.data == rhs.data
    }

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

extension Collection {

    subscript(optional index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }

}

class PXOneTapSummaryView: PXComponentView {
    private var data: [OneTapHeaderSummaryData] = [] {
        willSet {
            if data.count > newValue.count {
                removeSummaryRows(oldValue: data, newValue: newValue, animated: true)
            } else if data.count < newValue.count {
                addSummaryRows(oldValue: data, newValue: newValue, animated: true)
            } else {
                updateAllRows(newData: newValue)
            }
        }
    }
    private weak var delegate: PXOneTapSummaryProtocol?
    private var rowViews: [PXOneTapSummaryRowView] = []
    private var rows: [Row] = []
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
            print("******* consta en ren: ", offset)

            let rowViewConstraint = PXLayout.pinBottom(view: rowView, withMargin: offset)

            offset += rowView.getRowHeight()

            self.rows.append(Row(data: row, view: rowView, constraint: rowViewConstraint, rowHeight: rowView.getTotalHeightNeeded()))

            if row.isTotal {
                let separatorView = UIView()
                separatorView.backgroundColor = ThemeManager.shared.boldLabelTintColor()
                separatorView.alpha = 0.1
                separatorView.translatesAutoresizingMaskIntoConstraints = false

                self.addSubview(separatorView)
                PXLayout.pinBottom(view: separatorView, withMargin: offset).isActive = true
                PXLayout.setHeight(owner: separatorView, height: 1).isActive = true
                PXLayout.pinLeft(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                PXLayout.pinRight(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                offset += PXLayout.S_MARGIN
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

    func stopCurrentAnimatorIfNeeded() {
        if let cAnimator = self.currentAnimator {
            cAnimator.stopAnimation(false)
            cAnimator.finishAnimation(at: .end)
        }
    }

    func animateRows(_ rowsToAnimate: [Row], rowsToMove: [Row], newData: [OneTapHeaderSummaryData], animateIn: Bool, distance: CGFloat, completion: @escaping () -> Void) {
        let duration: Double = 0.4
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: nil)

        if let cAnimator = self.currentAnimator {
            cAnimator.stopAnimation(false)
            cAnimator.finishAnimation(at: .end)
        }

        animator.addAnimations {
            self.updateAllRows(newData: newData)
        }

        for row in rowsToAnimate {
            animator.addAnimations {
                row.view.alpha = animateIn ? 1 : 0
                row.constraint.constant += animateIn ? -distance + row.rowHeight : distance
                self.layoutIfNeeded()
            }
        }

        for mRow in rowsToMove {
            animator.addAnimations {
                mRow.constraint.constant += animateIn ? -distance : distance
                self.layoutIfNeeded()
            }
        }

        animator.addCompletion { (_) in
            completion()
        }

        currentAnimator = animator
        animator.startAnimation()
    }

    func removeSummaryRows(oldValue: [OneTapHeaderSummaryData], newValue: [OneTapHeaderSummaryData], animated: Bool) {
        let amountToRemove = oldValue.count - newValue.count
        var indexesToRemove: [Int] = []

        for index in 1...amountToRemove {
            indexesToRemove.append(index)
        }

        var distanceDelta: CGFloat = 0
        var rowsToRemove: [Row] = []
        var rowsToMove: [Row] = []

        for (index, row) in rows.enumerated() where !row.data.isTotal {
            if indexesToRemove.contains(index) {
                distanceDelta += row.rowHeight
                rowsToRemove.append(row)
            } else {
                rowsToMove.append(row)
            }
        }

        for row in rowsToRemove {
            if let index = self.rows.firstIndex(of: row) {
                self.rows.remove(at: index)
            }
        }

        stopCurrentAnimatorIfNeeded()
        animateRows(rowsToRemove, rowsToMove: rowsToMove, newData: newValue, animateIn: false, distance: distanceDelta) {
            for row in rowsToRemove {
                row.view.removeFromSuperview()
            }
        }
    }

    func addSummaryRows(oldValue: [OneTapHeaderSummaryData], newValue: [OneTapHeaderSummaryData], animated: Bool) {
        let amountToAdd = newValue.count - oldValue.count
        var newRowsData: [OneTapHeaderSummaryData] = []

        for index in 1...amountToAdd {
            newRowsData.append(newValue[index])
        }

        var distanceDelta: CGFloat = 24 {
            didSet {
                print("new distance delta: ", distanceDelta)
            }
        }
        var rowsToAdd: [Row] = []
        var rowsToMove: [Row] = []

        for rowData in newRowsData {
            let rowView = getSummaryRowView(with: rowData)
            let totalHeight = rowView.getTotalHeightNeeded()
            rowView.alpha = 0

            var constraintConstant: CGFloat = 0 {
                didSet {
                    print("****** new constant: ", constraintConstant)
                }
            }
            if let firstRow = rows[optional: 1] {
                constraintConstant = firstRow.constraint.constant
                constraintConstant += totalHeight
            } else {
                distanceDelta = totalHeight + PXLayout.S_MARGIN
//                constraintConstant = -rows[0].view.getRowHeight() - PXLayout.M_MARGIN
                constraintConstant = -76
            }

            //View Constraints
            self.addSubview(rowView)
            let constraint = PXLayout.pinBottom(view: rowView, withMargin: -constraintConstant)
            print("******* consta en add: ", -constraintConstant)
            PXLayout.centerHorizontally(view: rowView).isActive = true
            PXLayout.pinLeft(view: rowView, withMargin: 0).isActive = true
            PXLayout.pinRight(view: rowView, withMargin: 0).isActive = true
            self.layoutIfNeeded()

            //Tap Gesture
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRow(_:)))
            rowView.addGestureRecognizer(tap)
            rowView.isUserInteractionEnabled = true

            let newRow = Row(data: rowData, view: rowView, constraint: constraint, rowHeight: totalHeight)
            rowsToAdd.append(newRow)
            rows.insert(newRow, at: 1)
        }

        for row in rows where !row.data.isTotal {
            rowsToMove.append(row)
        }

        stopCurrentAnimatorIfNeeded()
        animateRows(rowsToAdd, rowsToMove: rowsToMove, newData: newValue, animateIn: true, distance: distanceDelta) {
        }
    }

    func updateAllRows(newData: [OneTapHeaderSummaryData]) {
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
