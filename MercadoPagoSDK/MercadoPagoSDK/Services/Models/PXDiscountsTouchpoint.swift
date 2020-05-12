//
//  PXDiscountsTouchpoint.swift
//  MercadoPagoSDK
//
//  Created by Vicente Veltri on 09/05/2020.
//

import Foundation

struct PXDiscountsTouchpoint: Decodable {

    let id: String
    let type: String
    let content: PXCodableDictionary
    let tracking: PXCodableDictionary?
    let additionalEdgeInsets: PXCodableDictionary?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case tracking
        case additionalEdgeInsets = "additional_edge_insets"
    }
}

