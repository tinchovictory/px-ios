//
//  PXSummaryComposer.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 13/05/2019.
//

import UIKit

struct PXSummaryComposer {

    //returns the composed summary items
    var summaryItems: [OneTapHeaderSummaryData] {
        return getSummaryItems()
    }

    //MARK: constants
    let isDefaultStatusBarStyle = ThemeManager.shared.statusBarStyle() == .default
    let currency = SiteManager.shared.getCurrency()
    let summaryAlpha: CGFloat = 0.45
    let discountAlpha: CGFloat = 1

    //MARK: initialization properties
    let amountHelper: PXAmountHelper
    let additionalInfoSummary: PXAdditionalInfoSummary?
    let selectedCard: PXCardSliderViewModel?

    init(amountHelper: PXAmountHelper,
         additionalInfoSummary: PXAdditionalInfoSummary?,
         selectedCard: PXCardSliderViewModel?) {
        self.amountHelper = amountHelper
        self.additionalInfoSummary = additionalInfoSummary
        self.selectedCard = selectedCard
    }

    private func getSummaryItems() -> [OneTapHeaderSummaryData] {
        let summaryItems = generateSummaryItems()
        return summaryItems
    }

    private func generateSummaryItems() -> [OneTapHeaderSummaryData] {
        var internalSummary = [OneTapHeaderSummaryData]()
        if shouldDisplayCharges() || shouldDisplayDiscount() {
            internalSummary.append(purchaseRow())
        }

        if shouldDisplayDiscount() {
            if isConsumedDiscount() {
                internalSummary.append(consumedDiscountRow())
            } else if let discRow = discountRow() {
                internalSummary.append(discRow)
            }
        }

        if shouldDisplayCharges() {
            internalSummary.append(chargesRow())
        }

        internalSummary.append(totalToPayRow())
        return internalSummary
    }
}
