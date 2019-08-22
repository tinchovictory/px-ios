//
//  PXOneTapHeaderViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/11/18.
//

import UIKit

class OneTapHeaderSummaryData: Equatable {
    let title: String
    let value: String
    let highlightedColor: UIColor
    let alpha: CGFloat
    let isTotal: Bool
    let image: UIImage?
    let type: PXOneTapSummaryRowView.RowType?

    init(title: String, value: String, highlightedColor: UIColor, alpha: CGFloat, isTotal: Bool, image: UIImage?, type: PXOneTapSummaryRowView.RowType?) {
        self.title = title
        self.value = value
        self.highlightedColor = highlightedColor
        self.alpha = alpha
        self.isTotal = isTotal
        self.image = image
        self.type = type
    }

    static func == (lhs: OneTapHeaderSummaryData, rhs: OneTapHeaderSummaryData) -> Bool {
        return lhs.title == rhs.title && lhs.value == rhs.value && lhs.highlightedColor == rhs.highlightedColor && lhs.alpha == rhs.alpha && lhs.isTotal == rhs.isTotal && lhs.image == rhs.image && lhs.type == rhs.type
    }
}

class PXOneTapHeaderViewModel {
    let icon: UIImage
    let title: String
    let subTitle: String?
    let data: [OneTapHeaderSummaryData]
    let splitConfiguration: PXSplitConfiguration?

    init(icon: UIImage, title: String, subTitle: String?, data: [OneTapHeaderSummaryData], splitConfiguration: PXSplitConfiguration?) {
        self.icon = icon
        self.title = title
        self.subTitle = subTitle
        self.data = data
        self.splitConfiguration = splitConfiguration
    }

    internal func hasLargeHeaderOrLarger() -> Bool {
        return self.splitConfiguration != nil && self.isLargeSummaryOrLarger()
    }

    internal func hasMediumHeaderOrLarger() -> Bool {
        let splitCondition = self.splitConfiguration != nil && self.isMediumSummaryOrLarger()
        let noSplitCondition = self.isLargeSummaryOrLarger()
        let hasMediumHeader = splitCondition || noSplitCondition
        return hasMediumHeader
    }

    private func isLargeSummaryOrLarger() -> Bool {
        var chargeFound = false
        var discountFound = false
        for item in data {
            if item.type == .charges {
                chargeFound = true
            }

            if item.type == .discount {
                discountFound = true
            }
        }
        return chargeFound && discountFound
    }

    private func isMediumSummaryOrLarger() -> Bool {
        for item in data {
            if item.type == .charges || item.type == .discount {
                return true
            }
        }
        return false
    }
}
