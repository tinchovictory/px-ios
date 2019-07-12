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
    var cardBackgroundColor: UIColor = #colorLiteral(red: 0.0431372549, green: 0.7065708517, blue: 0.7140994326, alpha: 1)
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = false
    var securityCodePattern = 3
    var fontType: String = "light"
    weak var delegate: PXTermsAndConditionViewDelegate?
    var ownOverlayImage: UIImage? = ResourceManager.shared.getImage("creditsOverlayMask")
    var ownGradient: CAGradientLayer = getCustomGradient()

    static func getCustomGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [#colorLiteral(red: 0.03361242613, green: 0.7578604493, blue: 0.6721206227, alpha: 1).cgColor, #colorLiteral(red: 0.0431372549, green: 0.5382275298, blue: 0.7933213932, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.6, y: 0.5)
        return gradient
    }
}

// MARK: Render
extension ConsumerCreditsCard {
    func render(containerView: UIView, creditsViewModel: CreditsViewModel, isDisabled: Bool) {
        let creditsImageHeight: CGFloat = 50
        let creditsImageWidth: CGFloat = 100
        let margins: CGFloat = 16
        let termsAndConditionsTextHeight: CGFloat = 40

        let consumerCreditsImage = getConsumerCreditsImageView(isDisabled: isDisabled)
        containerView.addSubview(consumerCreditsImage)
        NSLayoutConstraint.activate([
            PXLayout.setWidth(owner: consumerCreditsImage, width: creditsImageWidth),
            PXLayout.setHeight(owner: consumerCreditsImage, height: creditsImageHeight),
            PXLayout.centerHorizontally(view: consumerCreditsImage),
            PXLayout.centerVertically(view: consumerCreditsImage, to: containerView, withMargin: -creditsImageHeight/2)
        ])

        let titleLabel = getTitleLabel(creditsViewModel: creditsViewModel)
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            PXLayout.pinLeft(view: titleLabel, to: containerView, withMargin: margins),
            PXLayout.pinRight(view: titleLabel, to: containerView, withMargin: margins),
            PXLayout.put(view: titleLabel, onBottomOf: consumerCreditsImage)
        ])

        let termsAndConditionsText = getTermsAndConditionsTextView()
        containerView.addSubview(termsAndConditionsText)
        NSLayoutConstraint.activate([
            PXLayout.pinBottom(view: termsAndConditionsText, to: containerView, withMargin: margins),
            PXLayout.pinLeft(view: termsAndConditionsText, to: containerView, withMargin: margins),
            PXLayout.pinRight(view: termsAndConditionsText, to: containerView, withMargin: margins)
        ])

        PXLayout.setHeight(owner: termsAndConditionsText, height: termsAndConditionsTextHeight).isActive = true
        let tycText = creditsViewModel.text
        let phrases = creditsViewModel.linkablePhrases
        let attributedString = NSMutableAttributedString(string: tycText)

        for linkablePhrase in phrases {
            let tycLinkRange = (tycText as NSString).range(of: linkablePhrase.phrase)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: tycLinkRange)
            attributedString.addAttribute(NSAttributedString.Key.link, value: linkablePhrase.link, range: tycLinkRange)
        }
        termsAndConditionsText.attributedText = attributedString
        termsAndConditionsText.textAlignment = .center
        termsAndConditionsText.textColor = .white
    }
}

// MARK: UITextViewDelegate
extension ConsumerCreditsCard: UITextViewDelegate {
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if let range = Range(characterRange, in: textView.text),
                let text = textView.text?[range] {
                let title = String(text).capitalized
                delegate?.shouldOpenTermsCondition(title, url: URL)
            }
        return false
    }
}

// MARK: Privates
extension ConsumerCreditsCard {

    private func getConsumerCreditsImageView(isDisabled: Bool) -> UIImageView {
        let consumerCreditsImage = UIImageView()
        consumerCreditsImage.backgroundColor = .clear
        consumerCreditsImage.contentMode = .scaleAspectFit
        let consumerCreditsImageRaw = ResourceManager.shared.getImage("consumerCreditsOneTap")
        consumerCreditsImage.image = isDisabled ? consumerCreditsImageRaw?.imageGreyScale() : consumerCreditsImageRaw
        return consumerCreditsImage
    }

    private func getTitleLabel(creditsViewModel: CreditsViewModel) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = creditsViewModel.paymentMethodSideText
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = titleLabel.font.withSize(PXLayout.XXXS_FONT)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private func getTermsAndConditionsTextView() -> UITextView {
        let termsAndConditionsText = UITextView()
        termsAndConditionsText.linkTextAttributes = [.foregroundColor: UIColor.white]
        termsAndConditionsText.delegate = self
        termsAndConditionsText.isUserInteractionEnabled = true
        termsAndConditionsText.isEditable = false
        termsAndConditionsText.backgroundColor = .clear
        termsAndConditionsText.translatesAutoresizingMaskIntoConstraints = false
        return termsAndConditionsText
    }
}
