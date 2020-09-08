//
//  AddCardFlowModel.swift
//  MercadoPagoSDK
//
//  Created by Diego Flores Domenech on 6/9/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

class AddCardFlowModel: NSObject, PXFlowModel {

    var paymentMethods: [PXPaymentMethod]?
    var identificationTypes: [PXIdentificationType]?
    var cardToken: PXCardToken?
    var selectedPaymentMethod: PXPaymentMethod?
    var tokenizedCard: PXToken?
    var associateCardResult: [String: Any]?
    var lastStepFailed = false
    var skipCongrats = false

    enum Steps: Int {
        case start
        case getPaymentMethods
        case getIdentificationTypes
        case createToken
        case associateTokenWithUser
        case showCongrats
        case finish
    }

    private var currentStep = Steps.start

    func nextStep() -> AddCardFlowModel.Steps {
        if lastStepFailed {
            lastStepFailed = false
            return currentStep
        }
        switch currentStep {
        case .start:
            currentStep = .getPaymentMethods
        case .getPaymentMethods:
            currentStep = .getIdentificationTypes
        case .getIdentificationTypes:
            break
        case .createToken:
            currentStep = .associateTokenWithUser
        case .associateTokenWithUser:
            currentStep = skipCongrats ? .finish : .showCongrats
        case .showCongrats:
            currentStep = .finish
        default:
            break
        }
        return currentStep
    }

    func reset() {
        self.cardToken = nil
        self.selectedPaymentMethod = nil
        self.tokenizedCard = nil
    }

    func supportedIdentificationTypes() -> [PXIdentificationType]? {
        return IdentificationTypeValidator().filterSupported(identificationTypes: self.identificationTypes)
    }
}
