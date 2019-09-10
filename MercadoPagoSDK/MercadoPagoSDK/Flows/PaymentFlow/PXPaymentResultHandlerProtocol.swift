//
//  PXPaymentResultHandlerProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 03/07/2018.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

internal protocol PXPaymentResultHandlerProtocol: NSObjectProtocol {
    func finishPaymentFlow(paymentResult: PaymentResult, instructionsInfo: PXInstructions?, pointsAndDiscounts: PointsAndDiscounts?)
    func finishPaymentFlow(businessResult: PXBusinessResult, pointsAndDiscounts: PointsAndDiscounts?)
    func finishPaymentFlow(error: MPSDKError)
}
