//
//  PXDiscountOverview.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 01/07/2020.
//

import Foundation

public struct PXDiscountOverview: Codable, Equatable {

    let description: [PXText]
    let amount: PXText
    let brief: [PXText]?
    let url: String?
}
