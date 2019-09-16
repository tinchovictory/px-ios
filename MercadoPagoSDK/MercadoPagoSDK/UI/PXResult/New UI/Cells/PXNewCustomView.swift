//
//  PXNewCustomView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 29/08/2019.
//

import UIKit

open class PXNewCustomViewData {
    let firstString: NSAttributedString?
    let secondString: NSAttributedString?
    let thirdString: NSAttributedString?
    let icon: UIImage?
    let iconURL: String?
    let action: PXAction?
    let color: UIColor?

    init(firstString: NSAttributedString?, secondString: NSAttributedString?, thirdString: NSAttributedString?, icon: UIImage?, iconURL: String?, action: PXAction?, color: UIColor?) {
        self.firstString = firstString
        self.secondString = secondString
        self.thirdString = thirdString
        self.icon = icon
        self.iconURL = iconURL
        self.action = action
        self.color = color
    }

}

// MARK: Get data from payment data
extension PXNewCustomViewData {
    class func getPaymentMethodIcon(paymentMethod: PXPaymentMethod) -> UIImage? {
        let defaultColor = paymentMethod.paymentTypeId == PXPaymentTypes.ACCOUNT_MONEY.rawValue && paymentMethod.paymentTypeId != PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue
        var paymentMethodImage: UIImage? =  ResourceManager.shared.getImageForPaymentMethod(withDescription: paymentMethod.id, defaultColor: defaultColor)
        // Retrieve image for payment plugin or any external payment method.
        if paymentMethod.paymentTypeId == PXPaymentTypes.PAYMENT_METHOD_PLUGIN.rawValue {
            paymentMethodImage = paymentMethod.getImageForExtenalPaymentMethod()
        }
        return paymentMethodImage
    }

    class func getDataFromPaymentData(_ paymentData: PXPaymentData, amountHelper: PXAmountHelper) -> PXNewCustomViewData? {
        guard let paymentMethod = paymentData.paymentMethod else {
            return nil
        }

        let totalAmountAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
            NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45)
        ]

        let interestRateAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()
        ]

        let discountAmountAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
            NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45),
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]

        let image = getPaymentMethodIcon(paymentMethod: paymentMethod)
        let currency = SiteManager.shared.getCurrency()

        let firstString: NSMutableAttributedString = NSMutableAttributedString()
        let secondString: NSAttributedString?
        var thirdString: NSAttributedString?

        // First String
        if let payerCost = paymentData.payerCost {
            if payerCost.installments > 1 {
                let titleString = String(payerCost.installments) + "x " + Utils.getAmountFormated(amount: payerCost.installmentAmount, forCurrency: currency)
                let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)

                // Installment Rate
                if payerCost.installmentRate == 0.0 {
                    let interestRateString = " Sin interés".localized.lowercased()
                    let attributedInsterest = NSAttributedString(string: interestRateString, attributes: interestRateAttributes)
                    firstString.appendWithSpace(attributedInsterest)
                }

                // Total Amount
                let totalString = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency, addingParenthesis: true)
                let attributedTotal = NSAttributedString(string: totalString, attributes: totalAmountAttributes)
                firstString.appendWithSpace(attributedTotal)
            } else {
                let titleString = Utils.getAmountFormated(amount: payerCost.totalAmount, forCurrency: currency)
                let attributedTitle = NSAttributedString(string: titleString, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributedTitle)
            }
        } else {
            // Caso account money

            if let splitAccountMoneyAmount = paymentData.getTransactionAmountWithDiscount() {
                let string = Utils.getAmountFormated(amount: splitAccountMoneyAmount, forCurrency: currency)
                let attributed = NSAttributedString(string: string, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributed)
            } else {
                let string = Utils.getAmountFormated(amount: amountHelper.amountToPay, forCurrency: currency)
                let attributed = NSAttributedString(string: string, attributes: PXNewCustomView.titleAttributes)
                firstString.append(attributed)
            }
        }

        // Discount
        if let discount = paymentData.getDiscount(), let transactionAmount = paymentData.transactionAmount {
            let transactionAmount = Utils.getAmountFormated(amount: transactionAmount.doubleValue, forCurrency: currency)
            let attributedAmount = NSAttributedString(string: transactionAmount, attributes: discountAmountAttributes)

            firstString.appendWithSpace(attributedAmount)

            let discountString = discount.getDiscountDescription()
            let attributedString = NSAttributedString(string: discountString, attributes: interestRateAttributes)

            firstString.appendWithSpace(attributedString)
        }

        // Second String
        var pmDescription: String = ""
        let paymentMethodName = paymentMethod.name ?? ""

        if paymentMethod.isCard {
            if let lastFourDigits = (paymentData.token?.lastFourDigits) {
                pmDescription = paymentMethodName + " " + "terminada en ".localized + lastFourDigits
            }
        } else {
            pmDescription = paymentMethodName
        }

        let attributedSecond = NSMutableAttributedString(string: pmDescription, attributes: PXNewCustomView.subtitleAttributes)
        secondString = attributedSecond

        // Third String
        if let issuer = paymentData.getIssuer(), let issuerName = issuer.name, !issuerName.isEmpty, issuerName.lowercased() != paymentMethodName.lowercased() {

            let issuerAttributedString = NSMutableAttributedString(string: issuerName, attributes: PXNewCustomView.subtitleAttributes)

            thirdString = issuerAttributedString
        }

        let data = PXNewCustomViewData(firstString: firstString, secondString: secondString, thirdString: thirdString, icon: image, iconURL: nil, action: nil, color: .pxWhite)
        return data
    }
}

class PXNewCustomView: UIView {

    //Row Settings
    let ROW_HEIGHT: CGFloat = 80

    //Icon
    let IMAGE_WIDTH: CGFloat = 48.0
    let IMAGE_HEIGHT: CGFloat = 48.0

    var iconImageView: PXUIImageView?

    let data: PXNewCustomViewData

    class func getData() -> PXNewCustomViewData {
        return PXNewCustomViewData(firstString: nil, secondString: nil, thirdString: nil, icon: nil, iconURL: nil, action: nil, color: nil)
    }

    init(data: PXNewCustomViewData) {
        self.data = data
        super.init(frame: .zero)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Attributes
    static let titleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.8)
    ]

    static let subtitleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XXS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45)
    ]

    func render() {
        removeAllSubviews()
        let pxContentView = UIView()
        pxContentView.backgroundColor = .clear
        addSubview(pxContentView)
        PXLayout.pinAllEdges(view: pxContentView, withMargin: PXLayout.ZERO_MARGIN)
        PXLayout.setHeight(owner: pxContentView, height: ROW_HEIGHT, relation: .greaterThanOrEqual).isActive = true

        //Background Color
        if let color = data.color {
            self.backgroundColor = color
        }

        // Icon
        if let imageURL = data.iconURL, imageURL.isNotEmpty {
            let pximage = PXUIImage(url: imageURL)
            iconImageView = buildCircleImage(with: pximage)
        } else {
            iconImageView = buildCircleImage(with: data.icon)
        }

        let labelsView = PXComponentView()
        labelsView.clipsToBounds = true
        pxContentView.addSubview(labelsView)

        if let circleImage = iconImageView {
            pxContentView.addSubview(circleImage)
            PXLayout.pinTop(view: circleImage, withMargin: PXLayout.S_MARGIN)
            PXLayout.pinLeft(view: circleImage, withMargin: PXLayout.L_MARGIN)

            // Put labels view next to the icon
            PXLayout.put(view: labelsView, rightOf: circleImage, withMargin: PXLayout.S_MARGIN)
        } else {
            // Pin labels view next to the left
            PXLayout.pinLeft(view: labelsView, withMargin: PXLayout.L_MARGIN)
        }
        PXLayout.pinRight(view: labelsView, withMargin: PXLayout.L_MARGIN)
        PXLayout.pinTop(view: labelsView, withMargin: PXLayout.S_MARGIN)
        PXLayout.pinBottom(view: labelsView, withMargin: PXLayout.S_MARGIN)

        // First Label
        if let firstString = data.firstString {
            let label = buildLabel(firstString)
            labelsView.addSubviewToBottom(label)
            PXLayout.pinLeft(view: label)
            PXLayout.pinRight(view: label)
        }

        // Second Label
        if let secondString = data.secondString {
            let label = buildLabel(secondString)
            labelsView.addSubviewToBottom(label, withMargin: PXLayout.XXXS_MARGIN)
            PXLayout.pinLeft(view: label)
            PXLayout.pinRight(view: label)
        }

        // Third Label
        if let thirdString = data.thirdString {
            let label = buildLabel(thirdString)
            labelsView.addSubviewToBottom(label, withMargin: PXLayout.XXXS_MARGIN)
            PXLayout.pinLeft(view: label)
            PXLayout.pinRight(view: label)
        }

        //Action Label
        if let action = data.action {
            let button = buildButton(action)
            labelsView.addSubviewToBottom(button, withMargin: PXLayout.XXXS_MARGIN)
            PXLayout.setHeight(owner: button, height: 20)
            PXLayout.pinLeft(view: button)
            PXLayout.pinRight(view: button)
        }

        labelsView.pinLastSubviewToBottom()
    }

    @objc func actionTapped() {
        guard let action = data.action else {
            return
        }
        action.action()
    }
}

// MARK: UI Builders
extension PXNewCustomView {
    func buildCircleImage(with image: UIImage?) -> PXUIImageView {
        let circleImage = PXUIImageView(frame: CGRect(x: 0, y: 0, width: IMAGE_WIDTH, height: IMAGE_HEIGHT))
        circleImage.layer.masksToBounds = false
        circleImage.layer.cornerRadius = circleImage.frame.height / 2
        circleImage.clipsToBounds = true
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        circleImage.enableFadeIn()
        circleImage.contentMode = .scaleAspectFill
        circleImage.image = image
        circleImage.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        circleImage.layer.borderWidth = 1
        circleImage.layer.borderColor = UIColor.black.withAlphaComponent(0.08).cgColor
        PXLayout.setHeight(owner: circleImage, height: IMAGE_WIDTH).isActive = true
        PXLayout.setWidth(owner: circleImage, width: IMAGE_HEIGHT).isActive = true
        return circleImage
    }

    func buildLabel(_ string: NSAttributedString) -> UILabel {
        let label = UILabel()
        label.attributedText = string
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }

    func buildButton(_ action: PXAction) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.setTitle(action.label, for: .normal)
        button.titleLabel?.font = Utils.getFont(size: PXLayout.XXS_FONT)
        button.setTitleColor(ThemeManager.shared.secondaryColor(), for: .normal)
        button.add(for: .touchUpInside, action.action)
        return button
    }
}
