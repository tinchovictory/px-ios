//
//  PXOneTapInstallmentsSelectorViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 30/10/18.
//

import Foundation

typealias PXOneTapInstallmentsSelectorData = (title: NSAttributedString, topValue: NSAttributedString?, bottomValue: NSAttributedString?, isSelected: Bool)

final class PXOneTapInstallmentsSelectorViewModel {
    let installmentData: PXInstallment
    let selectedPayerCost: PXPayerCost?
    let interestConfiguration: PXIntallmentsConfiguration?
    let reimbursementConfiguration: PXIntallmentsConfiguration?

    var selectedRowHeight: CGFloat?

    init(installmentData: PXInstallment, selectedPayerCost: PXPayerCost?, interestConfiguration: PXIntallmentsConfiguration?, reimbursementConfiguration: PXIntallmentsConfiguration?) {
        self.installmentData = installmentData
        self.selectedPayerCost = selectedPayerCost
        self.interestConfiguration = interestConfiguration
        self.reimbursementConfiguration = reimbursementConfiguration
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return installmentData.payerCosts.count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = PXOneTapInstallmentsSelectorCell()
        if let payerCost = getPayerCostForRowAt(indexPath) {
            var isSelected = false
            if let selectedPayerCost = selectedPayerCost, selectedPayerCost == payerCost {
                isSelected = true
            }
            let data = getDataFor(payerCost: payerCost, isSelected: isSelected)
            cell.updateData(data)
            cell.backgroundColor = .white
            return cell
        }
        return cell
    }

    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat {
        if let selectedRowHeight = selectedRowHeight {
            return selectedRowHeight
        }
        let filteredPayerCosts = installmentData.payerCosts.filter { (payerCost) -> Bool in
            let hasReimbursementText = getReimbursementText(payerCost: payerCost) != nil
            let hasInterestText = getInterestText(payerCost: payerCost) != nil

            return hasReimbursementText && hasInterestText
        }
        if filteredPayerCosts.first != nil {
            selectedRowHeight = PXOneTapInstallmentInfoView.HIGH_ROW_HEIGHT
            return PXOneTapInstallmentInfoView.HIGH_ROW_HEIGHT
        } else {
            selectedRowHeight = PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT
            return PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT
        }
    }

    func getDataFor(payerCost: PXPayerCost, isSelected: Bool) -> PXOneTapInstallmentsSelectorData {
        let currency = SiteManager.shared.getCurrency()

        var title: NSAttributedString = NSAttributedString(string: "")
        let topValue = getInterestText(payerCost: payerCost)?.getAttributedString(fontSize: PXLayout.XS_FONT)
        let bottomValue = getReimbursementText(payerCost: payerCost)?.getAttributedString(fontSize: PXLayout.XS_FONT)

        var installmentNumber = String(format: "%i", payerCost.installments)
        installmentNumber = "\(installmentNumber) x "
        let totalAmount = Utils.getAttributedAmount(payerCost.installmentAmount, thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), currencySymbol: currency.getCurrencySymbolOrDefault(), color: UIColor.black, centsFontSize: 14, baselineOffset: 5)

        let atribute = [NSAttributedString.Key.font: Utils.getFont(size: 20), NSAttributedString.Key.foregroundColor: UIColor.black]
        let installmentLabel = NSMutableAttributedString(string: installmentNumber, attributes: atribute)

        installmentLabel.append(totalAmount)
        title = installmentLabel

        return PXOneTapInstallmentsSelectorData(title, topValue, bottomValue, isSelected)
    }

    func getPayerCostForRowAt(_ indexPath: IndexPath) -> PXPayerCost? {
        return installmentData.payerCosts[indexPath.row]
    }

    func getReimbursementText(payerCost: PXPayerCost) -> PXText? {
        guard let reimbursementConfiguration = reimbursementConfiguration else {
            return nil
        }

        if reimbursementConfiguration.appliedInstallments.contains(payerCost.installments) {
            return reimbursementConfiguration.installmentRow
        }
        return nil
    }

    func getInterestText(payerCost: PXPayerCost) -> PXText? {
        guard let interestConfiguration = interestConfiguration else {
            return nil
        }

        if interestConfiguration.appliedInstallments.contains(payerCost.installments) {
            return interestConfiguration.installmentRow
        }
        return nil
    }
}
