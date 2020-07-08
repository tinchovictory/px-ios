//
//  PXOneTapSummaryRowData.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 26/08/2019.
//

import UIKit

class PXOneTapSummaryRowData: Equatable {
    let title: String
    let value: String
    let highlightedColor: UIColor
    let alpha: CGFloat
    let isTotal: Bool
    let image: UIImage?
    let type: PXOneTapSummaryRowView.RowType?
    let overview: PXOverview?
    var splitMoney = false

    init(title: String, value: String, highlightedColor: UIColor, alpha: CGFloat, isTotal: Bool, image: UIImage?, type: PXOneTapSummaryRowView.RowType?, overview: PXOverview? = nil) {
        self.title = title
        self.value = value
        self.highlightedColor = highlightedColor
        self.alpha = alpha
        self.isTotal = isTotal
        self.image = image
        self.type = type
        self.overview = overview
    }

    static func == (lhs: PXOneTapSummaryRowData, rhs: PXOneTapSummaryRowData) -> Bool {
        return lhs.title == rhs.title && lhs.value == rhs.value && lhs.highlightedColor == rhs.highlightedColor && lhs.alpha == rhs.alpha && lhs.isTotal == rhs.isTotal && lhs.image == rhs.image && lhs.type == rhs.type && lhs.overview == rhs.overview && lhs.splitMoney == rhs.splitMoney
    }
}

// MARK: PXOverview
extension PXOneTapSummaryRowData {
    func rowHasBrief() -> Bool {
        guard let brief = overview?.brief, !brief.isEmpty else { return false }
        return UIDevice.isSmallDevice() && splitMoney ? false : true
    }

    func rowHasInfoIcon() -> Bool {
        guard let url = overview?.iconUrl, !url.isEmpty else { return false }
        return true
    }

    func getAmountText() -> NSAttributedString? {
        return overview?.amount.getAttributedString(fontSize: PXLayout.XXS_FONT, textColor: highlightedColor, backgroundColor: .clear)
    }

    func getDescriptionText() -> NSAttributedString? {
        guard let description = overview?.description else { return nil }
        return getAttributedText(array: description, fontSize: PXLayout.XXS_FONT)
    }

    func getBriefText() -> NSAttributedString? {
        guard let brief = overview?.brief else { return nil }
        return getAttributedText(array: brief, fontSize: PXLayout.XXXS_FONT)
    }

    func getIconUrl() -> String? {
        return overview?.iconUrl
    }

    private func getAttributedText(array: [PXText], fontSize: CGFloat) -> NSAttributedString {
        var attributedString = NSAttributedString()
        for (index, text) in array.enumerated() {
            if let attrString = text.getAttributedString(fontSize: fontSize, textColor: highlightedColor, backgroundColor: .clear) {
                if index > 0 {
                    attributedString = attributedString + NSAttributedString(string: " ") + attrString
                } else {
                    attributedString = attributedString + attrString
                }
            }
        }
        return attributedString
    }
}
