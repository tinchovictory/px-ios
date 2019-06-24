//
//  PXPaymentMethodSearch+Business.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 03/09/2018.
//

import Foundation

internal extension PXPaymentMethodSearch {
    func getPaymentOptionsCount() -> Int {
        let customOptionsCount = customOptionSearchItems.count
        let groupsOptionsCount = paymentMethodSearchItem.count
        return customOptionsCount + groupsOptionsCount
    }
}

// MARK: Express checkout.
internal extension PXPaymentMethodSearch {
    func hasCheckoutDefaultOption() -> Bool {
        return expressCho != nil
    }

    func deleteCheckoutDefaultOption() {
        expressCho = nil
    }

    func getPaymentMethodInExpressCheckout(targetId: String) -> (found: Bool, expressNode: PXOneTapDto?) {
        guard let expressResponse = expressCho else { return (false, nil) }
        for expressNode in expressResponse {
            if let expressCard = expressNode.oneTapCard, expressCard.cardId == targetId {

                return (true, expressNode)
            }
            if expressNode.paymentMethodId == "consumer_credits" {
                return (true, expressNode)
            }
        }
        return (false, nil)
    }
}
