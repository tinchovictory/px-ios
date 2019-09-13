//
//  RingViewDateDelegate.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 13/09/2019.
//

import UIKit
import MLBusinessComponents

class RingViewDateDelegate: NSObject, MLBusinessLoyaltyRingData {

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
