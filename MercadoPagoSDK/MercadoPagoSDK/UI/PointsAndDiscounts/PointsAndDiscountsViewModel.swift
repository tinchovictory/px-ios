//
//  PointsAndDiscountsViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 23/08/2019.
//

import Foundation

struct PointsAndDiscountsViewModel {

    let pointsAndDiscounts: PointsAndDiscounts

    init(_ withModel: PointsAndDiscounts) {
        self.pointsAndDiscounts = withModel
    }
}
