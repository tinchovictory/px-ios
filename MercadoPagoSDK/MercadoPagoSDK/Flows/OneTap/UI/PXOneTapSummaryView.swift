//
//  PXOneTapSummaryView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit

struct Row {
    let data: OneTapHeaderSummaryData
    let view: PXOneTapSummaryRowView
    let constraint: NSLayoutConstraint
    let rowHeight: CGFloat
}

class PXOneTapSummaryView: PXComponentView {
    private var oldData: [OneTapHeaderSummaryData] = []
    private var data: [OneTapHeaderSummaryData] = []
    private weak var delegate: PXOneTapSummaryProtocol?
    private var rows: [Row] = []

    init(data: [OneTapHeaderSummaryData] = [], delegate: PXOneTapSummaryProtocol) {
        self.data = data
        self.delegate = delegate
        super.init()
        render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reRender() {
        if oldData.count == data.count {
            render()
        } else {
            guard let rowViews = getSubviews().filter({(view: UIView) -> Bool in
                let rowView = view as? PXOneTapSummaryRowView
                return rowView != nil
//                return rowView != nil && rowView?.getData().type != PXOneTapSummaryRowView.RowType.total
            }) as? [PXOneTapSummaryRowView] else {
                render()
                return
            }

//            guard let rowViews = getSubviews().filter(
//                {$0.isKind(of: PXOneTapSummaryRowView.self) || $0.alpha == 0}) as? [PXOneTapSummaryRowView] else {
//                render()
//                return
//            }

            for (index, view) in rowViews.enumerated() {
                if oldData[index-1].type != data[index-1].type {
                    view.alpha = 0
                    view.removeFromSuperview()
                } else {
                    view.update(data[index])
                }
            }
        }
    }

    var totalHeight: CGFloat = 0

    func oldRender() {
            self.removeAllSubviews()
            self.pinContentViewToBottom()
            self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

            for row in self.data {
                let margin: CGFloat = row.isTotal ? PXLayout.S_MARGIN : PXLayout.XXS_MARGIN
                let rowView = self.getSummaryRowView(with: row)

                if row.isTotal {
                    let separatorView = UIView()
                    separatorView.backgroundColor = ThemeManager.shared.boldLabelTintColor()
                    separatorView.alpha = 0.1
                    separatorView.translatesAutoresizingMaskIntoConstraints = false
                    self.addSubviewToBottom(separatorView, withMargin: margin)
                    PXLayout.setHeight(owner: separatorView, height: 1).isActive = true
                    PXLayout.pinLeft(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                    PXLayout.pinRight(view: separatorView, withMargin: PXLayout.M_MARGIN).isActive = true
                }

                self.addSubviewToBottom(rowView, withMargin: margin)

                PXLayout.centerHorizontally(view: rowView).isActive = true
                PXLayout.pinLeft(view: rowView, withMargin: 0).isActive = true
                PXLayout.pinRight(view: rowView, withMargin: 0).isActive = true

                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapRow(_:)))
                rowView.addGestureRecognizer(tap)
                rowView.isUserInteractionEnabled = true
            }

            self.pinLastSubviewToBottom(withMargin: PXLayout.S_MARGIN)?.isActive = true
    }

    func getRowMargin(data: OneTapHeaderSummaryData) -> CGFloat {
        return data.isTotal ? PXLayout.S_MARGIN : PXLayout.XXS_MARGIN
    }

    func render() {
        self.removeAllSubviews()
        self.pinContentViewToBottom()
        self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

        var offset: CGFloat = 0
        for row in self.data.reversed() {
            let margin = getRowMargin(data: row)
            let rowView = self.getSummaryRowView(with: row)

            offset += margin

//            let totalContainerView = UIView()
            self.addSubview(rowView)
            let rowViewConstraint = PXLayout.pinBottom(view: rowView, withMargin: offset)

            offset += rowView.getRowHeight()

            self.rows.append(Row(data: row, view: rowView, constraint: rowViewConstraint, rowHeight: rowView.getRowHeight() + margin))

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

            totalHeight += rowView.getRowHeight()
            totalHeight += margin
        }
//        self.pinLastSubviewToBottom(withMargin: PXLayout.S_MARGIN)?.isActive = true
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

    func removeSummaryRows(at indexesToRemove: [Int], animated: Bool) {
        var animator = PXAnimator(duration: animated ? 0.5 : 0.0, dampingRatio: 1)

        var distanceDelta: CGFloat = 0

        let notTotalRows = rows.filter({!$0.data.isTotal})

        for (index, row) in notTotalRows.enumerated() {
            if indexesToRemove.contains(index) {
                distanceDelta += row.rowHeight

                animator.addAnimation(animation: {
                    row.view.alpha = 0
                    self.layoutIfNeeded()
                })

                animator.addCompletion {
                    row.view.removeFromSuperview()
                    self.rows.remove(at: index)
                }
            }

            animator.addAnimation(animation: {
                row.constraint.constant += distanceDelta
                self.layoutIfNeeded()
            })
        }

        animator.animate()
    }

    func addSummaryRows(with data: [OneTapHeaderSummaryData], animated: Bool) {
        var animator = PXAnimator(duration: animated ? 0.5 : 0.0, dampingRatio: 1)

        var distanceDelta: CGFloat = 0

        var newRows: [Row] = []
        for rowData in data {
            let rowView = getSummaryRowView(with: rowData)
            let margin = getRowMargin(data: rowData)
            let height = rowView.getRowHeight()
            let totalHeight = height + margin
            distanceDelta += totalHeight
            rowView.alpha = 0

            guard var constraintConstant = rows.first?.constraint.constant else {
                return
            }

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
            rows.insert(newRow, at: 0)
        }

        for (index, row) in rows.enumerated() {
            animator.addAnimation(animation: {
                row.view.alpha = 1
                row.constraint.constant -= distanceDelta
                self.layoutIfNeeded()
            })
        }

        animator.animate()
    }

    func update(_ newData: [OneTapHeaderSummaryData], hideAnimatedView: Bool = false) {

        self.oldData = data
        self.data = newData

        var indexes: [Int] = []

        if data.count < oldData.count {
            let rowsToRemove = oldData.count - data.count

            for index in 0...rowsToRemove-1 {
                indexes.append(index)
            }

            removeSummaryRows(at: indexes, animated: true)
        } else if data.count > oldData.count {
            let rowsToAdd = data.count - oldData.count
            var newRowsData: [OneTapHeaderSummaryData] = []

            for index in 0...rowsToAdd-1 {
                indexes.append(index)
                newRowsData.append(data.reversed()[index])
            }

            addSummaryRows(with: newRowsData, animated: true)
        } else {
            for (index, row) in rows.enumerated() {
                row.view.update(data.reversed()[index])
            }
        }
    }

    func getSummaryRowView(with data: OneTapHeaderSummaryData) -> PXOneTapSummaryRowView {
        let rowView = PXOneTapSummaryRowView(data: data)
        return rowView
    }
}
