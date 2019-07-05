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

    static func render(containerView: UIView, oneTapCreditsInfo: PXOneTapCreditsDto, isDisabled: Bool) {
        let consumerCreditsImage = UIImageView()
        consumerCreditsImage.backgroundColor = .clear
        consumerCreditsImage.contentMode = .scaleAspectFit
        let consumerCreditsImageRaw = ResourceManager.shared.getImage("consumerCreditsOneTap")
        consumerCreditsImage.image = isDisabled ? consumerCreditsImageRaw?.imageGreyScale() : consumerCreditsImageRaw
        containerView.addSubview(consumerCreditsImage)
        NSLayoutConstraint.activate([
            PXLayout.setWidth(owner: consumerCreditsImage, width: 100),
            PXLayout.setHeight(owner: consumerCreditsImage, height: 50),
            PXLayout.centerHorizontally(view: consumerCreditsImage),
            PXLayout.centerVertically(view: consumerCreditsImage, to: containerView, withMargin: -40)
        ])

        let titleLabel = UILabel()
        containerView.addSubview(titleLabel)
//        titleLabel.text = "Pagá en hasta 12 cuotas sin usar tarjeta"
        titleLabel.text = oneTapCreditsInfo.paymentMethodSideText
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = titleLabel.font.withSize(PXLayout.XXXS_FONT)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            PXLayout.pinLeft(view: titleLabel, to: containerView, withMargin: 16),
            PXLayout.pinRight(view: titleLabel, to: containerView, withMargin: 16),
            PXLayout.put(view: titleLabel, onBottomOf: consumerCreditsImage, withMargin: 2)
        ])

        let termsAndCondLabel = UILabel()
        containerView.addSubview(termsAndCondLabel)
        termsAndCondLabel.textColor = .white
        termsAndCondLabel.textAlignment = .center
        termsAndCondLabel.font = termsAndCondLabel.font.withSize(11)
        termsAndCondLabel.numberOfLines = 3
        termsAndCondLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        termsAndCondLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            PXLayout.pinBottom(view: termsAndCondLabel, to: containerView, withMargin: 27),
            PXLayout.pinLeft(view: termsAndCondLabel, to: containerView, withMargin: 16),
            PXLayout.pinRight(view: termsAndCondLabel, to: containerView, withMargin: 16)
        ])

        let tycText = oneTapCreditsInfo.termsAndConditions.text
        let phrases = oneTapCreditsInfo.termsAndConditions.linkablePhrases
        let attributedString = NSMutableAttributedString(string: tycText)

        for linkablePhrase in phrases {
            let tycLinkRange = (tycText as NSString).range(of: linkablePhrase.phrase)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: tycLinkRange)
        }
        termsAndCondLabel.attributedText = attributedString
    }
}
