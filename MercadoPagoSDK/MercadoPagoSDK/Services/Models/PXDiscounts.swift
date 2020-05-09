//
//  PXDiscounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct PXDiscounts: Decodable {

    let title: String?
    let subtitle: String?
    let discountsAction: PXRemoteAction
    let downloadAction: PXDownloadAction
    let touchpoint: PXDiscountsTouchpoint
    let loyaltyDiscounts: Int?                  //TODO: Preguntar si va venir esto en la firma
    let totalDiscounts: Int?                    //TODO: Preguntar si va venir esto en la firma

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case discountsAction = "action"
        case downloadAction = "action_download"
        case touchpoint
        case loyaltyDiscounts = "loyalty_discounts"
        case totalDiscounts = "total_discounts"
    }
}
