//
//  PXOneTapInstallmentInfoViewProtocol.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/11/18.
//

import Foundation

protocol PXOneTapInstallmentInfoViewProtocol: NSObjectProtocol {
    func hideInstallments()
    func showInstallments(installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?, interest: PXIntallmentsConfiguration?, reimbursement: PXIntallmentsConfiguration?)
    func disabledCardTapped(status: PXStatus)
}
