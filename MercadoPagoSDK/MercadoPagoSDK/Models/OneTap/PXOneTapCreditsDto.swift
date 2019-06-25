//
//  PXOneTapCreditsDto.swift
//  Bugsnag
//
//  Created by Federico Bustos Fierro on 24/06/2019.
//

import UIKit

public struct PXOneTapCreditsDto: Codable {
    let paymentMethodIcon: String
    enum CodingKeys: String, CodingKey {
        case paymentMethodIcon = "payment_method_icon"
    }
}
