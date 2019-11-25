//
//  PXStatus.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

public struct PXStatus: Codable {
    let mainMessage: PXText?
    let secondaryMessage: PXText?
    let enabled: Bool

    enum CodingKeys: String, CodingKey {
        case mainMessage = "main_message"
        case secondaryMessage = "secondary_message"
        case enabled
    }

    static func getStatusFor(statusDetail: String) -> PXStatus? {
        let mainText = PXText(message: "disabled_main_message".localized_beta, backgroundColor: nil, textColor: nil, weight: nil)

        switch statusDetail {
        case PXPayment.StatusDetails.REJECTED_CARD_HIGH_RISK:
            let secondaryText = PXText(message: "disabled_CC_REJECTED_HIGH_RISK".localized_beta, backgroundColor: nil, textColor: nil, weight: nil)
            return PXStatus(mainMessage: mainText, secondaryMessage: secondaryText, enabled: false)
        case PXPayment.StatusDetails.REJECTED_BLACKLIST:
            let secondaryText = PXText(message: "disabled_CC_REJECTED_BLACKLIST".localized_beta, backgroundColor: nil, textColor: nil, weight: nil)
            return PXStatus(mainMessage: mainText, secondaryMessage: secondaryText, enabled: false)
        case PXPayment.StatusDetails.REJECTED_INSUFFICIENT_AMOUNT:
            let secondaryText = PXText(message: "disabled_CC_REJECTED_INSUFFICIENT_AMOUNT".localized_beta, backgroundColor: nil, textColor: nil, weight: nil)
            return PXStatus(mainMessage: mainText, secondaryMessage: secondaryText, enabled: false)
        default:
            return nil
        }
    }
}
