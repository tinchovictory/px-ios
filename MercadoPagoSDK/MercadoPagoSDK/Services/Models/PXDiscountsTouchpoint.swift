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
    let content: [String:String] //TODO: CHANGE THIS
    let tracking: [String:String]? //TODO: CHANGE THIS
    let additionalEdgeInsets: [String:String]? //TODO: CHANGE THIS

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case tracking
        case additionalEdgeInsets = "additional_edge_insets"
    }
}

