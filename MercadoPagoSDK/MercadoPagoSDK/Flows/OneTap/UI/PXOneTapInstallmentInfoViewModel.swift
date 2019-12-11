//
//  PXOneTapInstallmentInfoViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 16/10/18.
//

import Foundation

final class PXOneTapInstallmentInfoViewModel {
    var text: NSAttributedString
    var headerText: NSAttributedString?
    var installmentData: PXInstallment?
    var selectedPayerCost: PXPayerCost?
    var shouldShowArrow: Bool
    var status: PXStatus
    let interestConfiguration: PXInstallmentsConfiguration?
    let reimbursementConfiguration: PXInstallmentsConfiguration?

    init(text: NSAttributedString, headerText: NSAttributedString?, installmentData: PXInstallment?, selectedPayerCost: PXPayerCost?, shouldShowArrow: Bool, status: PXStatus, interestConfiguration: PXInstallmentsConfiguration?, reimbursementConfiguration: PXInstallmentsConfiguration?) {
        self.text = text
        self.headerText = headerText
        self.installmentData = installmentData
        self.selectedPayerCost = selectedPayerCost
        self.shouldShowArrow = shouldShowArrow
        self.status = status
        self.interestConfiguration = interestConfiguration
        self.reimbursementConfiguration = reimbursementConfiguration
    }
}
