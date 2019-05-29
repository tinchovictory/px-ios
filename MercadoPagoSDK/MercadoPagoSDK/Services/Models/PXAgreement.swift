//
//  PXAgreement.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 28/05/2019.
//

import UIKit

public struct PXAgreement: Codable {
    let merchantAccounts: [PXMerchantAccount]
    enum CodingKeys: String, CodingKey {
        case merchantAccounts = "merchant_accounts"
    }
}
