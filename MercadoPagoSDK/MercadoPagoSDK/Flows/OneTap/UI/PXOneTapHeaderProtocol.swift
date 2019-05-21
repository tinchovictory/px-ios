//
//  PXOneTapHeaderProtocol.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/11/18.
//

import Foundation

protocol PXOneTapSummaryProtocol: NSObjectProtocol {
    func didTapCharges()
    func didTapDiscount()
}

protocol PXOneTapHeaderProtocol: PXOneTapSummaryProtocol {
    func didTapMerchantHeader()
    func splitPaymentSwitchChangedValue(isOn: Bool, isUserSelection: Bool)
}
