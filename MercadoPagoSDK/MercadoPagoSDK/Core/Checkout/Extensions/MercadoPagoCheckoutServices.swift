//
//  MercadoPagoCheckoutServices.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 7/18/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation

extension MercadoPagoCheckout {

    func createPayment() {
        viewModel.invalidESCReason = nil
        let paymentFlow = viewModel.createPaymentFlow(paymentErrorHandler: self)
        paymentFlow.setData(amountHelper: viewModel.amountHelper, checkoutPreference: viewModel.checkoutPreference, resultHandler: self)
        paymentFlow.start()
    }

    func getIdentificationTypes() {
        viewModel.pxNavigationHandler.presentLoading()
        viewModel.mercadoPagoServices.getIdentificationTypes(callback: { [weak self] (identificationTypes) in
            guard let self = self else { return }
            self.viewModel.updateCheckoutModel(identificationTypes: identificationTypes)
            self.executeNextStep()
            }, failure: { [weak self] (error) in
                guard let self = self else { return }
                self.viewModel.errorInputs(error: MPSDKError.convertFrom(error, requestOrigin: ApiUtil.RequestOrigin.GET_IDENTIFICATION_TYPES.rawValue), errorCallback: { [weak self] () in
                    self?.getIdentificationTypes()
                })
                self.executeNextStep()
        })
    }
}
