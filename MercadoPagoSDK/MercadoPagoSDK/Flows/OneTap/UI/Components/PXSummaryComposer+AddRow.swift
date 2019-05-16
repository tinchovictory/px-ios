//
//  PXSummaryComposer+AddRow.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 14/05/2019.
//

import Foundation

extension PXSummaryComposer {
    func chargesRow() -> OneTapHeaderSummaryData {
        let amount = getChargesAmount()
        let helperImage = helpIcon(color: summaryColor())
        let amountToShow = Utils.getAmountFormated(amount: amount, forCurrency: currency)
        let chargeText = "onetap_purchase_summary_charges".localized_beta
        let row = OneTapHeaderSummaryData(chargeText, amountToShow, summaryColor(), 1, false, helperImage)
        return row
    }

    func consumedDiscountRow() -> OneTapHeaderSummaryData {
        let helperImage = helpIcon(color: summaryColor(),
                                   alpha: discountDisclaimerAlpha())
        let row = OneTapHeaderSummaryData("total_row_consumed_discount".localized_beta, "", summaryColor(), discountDisclaimerAlpha(), false, helperImage)
        return row
    }

    func discountRow() -> OneTapHeaderSummaryData? {
        guard let discount = getDiscount() else {
            printError("Discount is required to add the discount row")
            return nil
        }

        let discountToShow = Utils.getAmountFormated(amount: discount.couponAmount, forCurrency: currency)
        let helperImage = helpIcon(color: discountColor())
        let row = OneTapHeaderSummaryData(discount.getDiscountDescription(),
                                          "- \(discountToShow)",
            discountColor(),
            discountAlpha,
            false,
            helperImage)
        return row
    }

    func purchaseRow() -> OneTapHeaderSummaryData {
        let isTransparent = shouldDisplayDiscount() && !shouldDisplayCharges()
        let alpha = isTransparent ? summaryAlpha : 1
        let row = OneTapHeaderSummaryData( yourPurchaseSummaryTitle(),
                                           yourPurchaseToShow(),
                                           summaryColor(),
                                           alpha,
                                           false,
                                           nil)
        return row
    }

    func totalToPayRow() -> OneTapHeaderSummaryData {
        let totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
        let totalAlpha: CGFloat = 1
        let totalColor = isDefaultStatusBarStyle ? UIColor.black : ThemeManager.shared.whiteColor()
        let text = "onetap_purchase_summary_total".localized_beta
        let row = OneTapHeaderSummaryData(text,
                                          totalAmountToShow,
                                          totalColor,
                                          totalAlpha,
                                          true,
                                          nil)
        return row
    }

}
