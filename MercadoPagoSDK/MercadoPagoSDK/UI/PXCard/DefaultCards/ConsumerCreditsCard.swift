//
//  ConsumerCreditsCard.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 03/07/2019.
//

import Foundation
import MLCardDrawer

class ConsumerCreditsCard: NSObject, CustomCardDrawerUI {
    var placeholderName = ""
    var placeholderExpiration = ""
    var bankImage: UIImage?
    var cardPattern = [0]
    var cardFontColor: UIColor = .white
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor = #colorLiteral(red: 0.0431372549, green: 0.7231055264, blue: 0.6548635593, alpha: 1)
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = false
    var securityCodePattern = 3
    var fontType: String = "light"
}

extension ConsumerCreditsCard {

    static func render(containerView: UIView, balanceText: String, isDisabled: Bool) {
        let amImage = UIImageView()
        amImage.backgroundColor = .clear
        amImage.contentMode = .scaleAspectFit
        let amImageRaw = ResourceManager.shared.getImage("consumerCreditsOneTap")
        amImage.image = isDisabled ? amImageRaw?.imageGreyScale() : amImageRaw
        containerView.addSubview(amImage)
        NSLayoutConstraint.activate([
            PXLayout.setWidth(owner: amImage, width: 100),
            PXLayout.setHeight(owner: amImage, height: 50),
            PXLayout.centerHorizontally(view: amImage),
            PXLayout.centerVertically(view: amImage, to: containerView, withMargin: -40)
        ])

        let titleLabel = UILabel()
        containerView.addSubview(titleLabel)
        titleLabel.text = "Pagá en hasta 12 cuotas sin usar tarjeta"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = titleLabel.font.withSize(PXLayout.XXXS_FONT)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            PXLayout.pinLeft(view: titleLabel, to: containerView, withMargin: 16),
            PXLayout.pinRight(view: titleLabel, to: containerView, withMargin: 16),
            PXLayout.put(view: titleLabel, onBottomOf: amImage, withMargin: 2)
        ])

        let termsLabel = UILabel()
        containerView.addSubview(termsLabel)
        termsLabel.text = "Al pagar, aceptás las condiciones generales y particulares de este préstamo."
        termsLabel.textColor = .white
        termsLabel.textAlignment = .center
        termsLabel.font = termsLabel.font.withSize(11)
        termsLabel.numberOfLines = 3
        termsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            PXLayout.pinBottom(view: termsLabel, to: containerView, withMargin: 27),
            PXLayout.pinLeft(view: termsLabel, to: containerView, withMargin: 16),
            PXLayout.pinRight(view: termsLabel, to: containerView, withMargin: 16)
        ])
    }
}
