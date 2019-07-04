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
    var cardFontColor: UIColor = #colorLiteral(red: 0.0431372549, green: 0.7725490196, blue: 0.631372549, alpha: 1)
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor = UIColor(red: 0.00, green: 0.64, blue: 0.85, alpha: 1.0)
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
        let amImageRaw = ResourceManager.shared.getImage("consumerCredits")
        amImage.image = isDisabled ? amImageRaw?.imageGreyScale() : amImageRaw
        amImage.alpha = 0.6
        containerView.addSubview(amImage)
        PXLayout.setWidth(owner: amImage, width: PXCardSliderSizeManager.getItemContainerSize().height * 0.65).isActive = true
        PXLayout.setHeight(owner: amImage, height: PXCardSliderSizeManager.getItemContainerSize().height * 0.65).isActive = true
        PXLayout.pinTop(view: amImage).isActive = true
        PXLayout.pinRight(view: amImage).isActive = true
    }
}
