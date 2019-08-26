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
        let shouldDisplayHelper = shouldDisplayChargesHelp
        let helperImage = shouldDisplayHelper ? helpIcon(color: summaryColor()) : nil
        let amountToShow = Utils.getAmountFormated(amount: amount, forCurrency: currency)
        let defaultChargeText = "onetap_purchase_summary_charges".localized_beta
        let chargeText = additionalInfoSummary?.charges ?? defaultChargeText
        let row = OneTapHeaderSummaryData(title: chargeText, value: amountToShow, highlightedColor: summaryColor(), alpha: textTransparency, isTotal: false, image: helperImage, type: .charges)
        return row
    }

    func consumedDiscountRow() -> OneTapHeaderSummaryData {
        let helperImage = helpIcon(color: summaryColor())
        let row = OneTapHeaderSummaryData(title: "total_row_consumed_discount".localized_beta, value: "", highlightedColor: summaryColor(), alpha: textTransparency, isTotal: false, image: helperImage, type: .discount)
        return row
    }

    func discountRow() -> OneTapHeaderSummaryData? {
        guard let discount = getDiscount() else {
            printError("Discount is required to add the discount row")
            return nil
        }

        let discountToShow = Utils.getAmountFormated(amount: discount.couponAmount, forCurrency: currency)
        let helperImage = helpIcon(color: discountColor())
        let row = OneTapHeaderSummaryData(title: discount.getDiscountDescription(),
                                          value: "- \(discountToShow)",
            highlightedColor: discountColor(),
            alpha: textTransparency,
            isTotal: false,
            image: helperImage,
            type: .discount)
        return row
    }

    func purchaseRow() -> OneTapHeaderSummaryData {
        let row = OneTapHeaderSummaryData( title: yourPurchaseSummaryTitle(),
                                           value: yourPurchaseToShow(),
                                           highlightedColor: summaryColor(),
                                           alpha: textTransparency,
                                           isTotal: false,
                                           image: nil,
                                           type: .generic)
        return row
    }

    func totalToPayRow() -> OneTapHeaderSummaryData {
        let totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
        let text = "onetap_purchase_summary_total".localized_beta
        let row = OneTapHeaderSummaryData(title: text,
                                          value: totalAmountToShow,
                                          highlightedColor: summaryColor(),
                                          alpha: textTransparency,
                                          isTotal: true,
                                          image: nil,
                                          type: .generic)
        return row
    }

}
