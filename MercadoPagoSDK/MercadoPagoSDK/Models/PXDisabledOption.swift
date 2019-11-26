//
//  PXDisabledOption.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 27/08/2018.
//

import Foundation

internal struct PXDisabledOption {

    private var disabledPaymentMethodId: String?
    private var disabledCardId: String?
    private var status: PXStatus?
    private let disabledStatusDetails: [String] = [PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK,
                                                   PXPayment.StatusDetails.REJECTED_HIGH_RISK,
                                                   PXPayment.StatusDetails.REJECTED_BLACKLIST,
                                                   PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT]

    init(paymentResult: PaymentResult?) {
        if let paymentResult = paymentResult {
            status = PXStatus.getStatusFor(statusDetail: paymentResult.statusDetail)

            guard let paymentMethod = paymentResult.paymentData?.getPaymentMethod() else {return}
            guard disabledStatusDetails.contains(paymentResult.statusDetail) else {return}

            if !paymentMethod.isCard {
                disabledPaymentMethodId = paymentMethod.getId()
            } else if let cardId = paymentResult.paymentData?.token?.cardId {
                disabledCardId = cardId
            }
        }
    }

    public func isPMDisabled(paymentMethodId: String?) -> Bool {
        guard let disabledPaymentMethodId = disabledPaymentMethodId, let paymentMethodId = paymentMethodId else {return false}
        return disabledPaymentMethodId == paymentMethodId
    }

    public func isCardIdDisabled(cardId: String?) -> Bool {
        guard let disabledCardId = disabledCardId, let cardId = cardId else {return false}
        return disabledCardId == cardId
    }

    public func getDisabledPaymentMethodId() -> String? {
        return disabledPaymentMethodId
    }

    public func getDisabledCardId() -> String? {
        return disabledCardId
    }

    public func getStatus() -> PXStatus? {
        return status
    }
}
