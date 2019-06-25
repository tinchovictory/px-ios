//
//  PXOneTapCreditsDto.swift
//  Bugsnag
//
//  Created by Federico Bustos Fierro on 24/06/2019.
//

import UIKit

public struct PXOneTapCreditsDto: Codable {
    let paymentMethodIcon: String
    let paymentMethodSideText: String
    let termsAndConditions: PXTermsDto
    enum CodingKeys: String, CodingKey {
        case paymentMethodIcon = "payment_method_icon"
        case paymentMethodSideText = "payment_method_side_text"
        case termsAndConditions = "bottom_text"
    }
}
