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
        return lhs.title == rhs.title && lhs.value == rhs.value && lhs.highlightedColor == rhs.highlightedColor && lhs.alpha == rhs.alpha && lhs.isTotal == rhs.isTotal && lhs.image == rhs.image && lhs.type == rhs.type && lhs.overview == rhs.overview
    }
}
