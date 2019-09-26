//
//  Points.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct Points: Decodable {

    let progress: PXPointsProgress
    let title: String
    let action: PointsAndDiscountsAction

    enum CodingKeys: String, CodingKey {
        case progress
        case title
        case action
    }
}

