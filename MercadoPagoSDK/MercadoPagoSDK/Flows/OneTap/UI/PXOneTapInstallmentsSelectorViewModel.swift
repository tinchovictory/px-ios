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
    var selectedRowHeight: CGFloat?

    init(installmentData: PXInstallment, selectedPayerCost: PXPayerCost?) {
        self.installmentData = installmentData
        self.selectedPayerCost = selectedPayerCost
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
            let hasReimbursementText = payerCost.reimbursementText != nil
            let hasInterestText = payerCost.interestText != nil

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
        let topValue = payerCost.interestText?.getAttributedString(fontSize: PXLayout.XS_FONT)
        let bottomValue = payerCost.reimbursementText?.getAttributedString(fontSize: PXLayout.XS_FONT)

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
}
