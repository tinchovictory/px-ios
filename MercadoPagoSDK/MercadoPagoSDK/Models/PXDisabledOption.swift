//
//  PXDisabledOption.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 27/08/2018.
//

import Foundation

internal struct PXDisabledOption {

    private var disabledCardId: String?
    private var disabledAccountMoney: Bool = false
    private var status: PXStatus?

    init(paymentResult: PaymentResult?) {
        if let paymentResult = paymentResult {
            status = PXStatus.getStatusFor(statusDetail: paymentResult.statusDetail)

            if let cardId = paymentResult.cardId,
                paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK ||
                    paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_BLACKLIST || paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT {
                disabledCardId = cardId
            }

            if paymentResult.paymentData?.getPaymentMethod()?.isAccountMoney ?? false,
                paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_HIGH_RISK || paymentResult.statusDetail == PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT {
                disabledAccountMoney = true
            }
        }
    }

    public func getDisabledCardId() -> String? {
        return disabledCardId
    }

    public func isAccountMoneyDisabled() -> Bool {
        return disabledAccountMoney
    }

    public func getStatus() -> PXStatus? {
        return status
    }
}
