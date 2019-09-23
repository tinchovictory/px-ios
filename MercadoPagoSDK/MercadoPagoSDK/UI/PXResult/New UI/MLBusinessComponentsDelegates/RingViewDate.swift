//
//  RingViewDate.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 13/09/2019.
//

import UIKit
import MLBusinessComponents

class RingViewDate: NSObject, MLBusinessLoyaltyRingData {

    let points: Points

    init(points: Points) {
        self.points = points
    }

    func getRingNumber() -> Int {
        return points.progress.levelNumber
    }

    func getRingHexaColor() -> String {
        return points.progress.levelColor
    }

    func getRingPercentage() -> Float {
        return Float(points.progress.percentage)
    }

    func getTitle() -> String {
        return points.title
    }

    func getButtonTitle() -> String {
        return points.action.label
    }

    func getButtonDeepLink() -> String {
        return points.action.target
    }
}

class LoyaltyRingData: NSObject, MLBusinessLoyaltyRingData {

    func getRingNumber() -> Int {
        return 3
    }

    func getRingHexaColor() -> String {
        return "#17aad6"
    }

    func getRingPercentage() -> Float {
        return 0.80
    }

    func getTitle() -> String {
        return "Ganaste 100 Puntos"
    }

    func getButtonTitle() -> String {
        return "Mis beneficios"
    }

    func getButtonDeepLink() -> String {
        return "mercadopago://home"
    }
}
