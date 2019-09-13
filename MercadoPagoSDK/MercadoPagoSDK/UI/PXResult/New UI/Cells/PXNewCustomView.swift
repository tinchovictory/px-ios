//
//  PXNewCustomView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 29/08/2019.
//

import UIKit

open class PXNewCustomViewData {
    let title: NSMutableAttributedString?
    let subtitle: NSMutableAttributedString?
    let icon: UIImage?
    let iconURL: String?
    let action: PXAction?
    let color: UIColor?

    init(title: NSMutableAttributedString?, subtitle: NSMutableAttributedString?, icon: UIImage?, iconURL: String?, action: PXAction?, color: UIColor?) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconURL = iconURL
        self.action = action
        self.color = color
    }
}

class PXNewCustomView: UIView {

    //Row Settings
    let ROW_HEIGHT: CGFloat = 75

    //Icon
    let IMAGE_WIDTH: CGFloat = 48.0
    let IMAGE_HEIGHT: CGFloat = 48.0

    var iconImageView: PXUIImageView?

    var data: PXNewCustomViewData? {
        didSet {
            render()
        }
    }

    //Attributes
    private let titleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getSemiBoldFont(size: PXLayout.XS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.8)
    ]

    private let subtitleAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: Utils.getFont(size: PXLayout.XXS_FONT),
        NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.45)
    ]

    func setData(data: PXNewCustomViewData) {
        self.data = data
    }

    func render() {
        removeAllSubviews()
        let pxContentView = UIView()
        pxContentView.backgroundColor = .clear
        addSubview(pxContentView)
        PXLayout.pinAllEdges(view: pxContentView, withMargin: PXLayout.ZERO_MARGIN)
        PXLayout.setHeight(owner: pxContentView, height: ROW_HEIGHT).isActive = true

        //Background Color
        if let color = data?.color {
            self.backgroundColor = color
        }

        // Icon
        if let imageURL = data?.iconURL, imageURL.isNotEmpty {
            let pximage = PXUIImage(url: imageURL)
            iconImageView = buildCircleImage(with: pximage)
        } else {
            iconImageView = buildCircleImage(with: data?.icon)
        }

        let labelsView = PXComponentView()
        labelsView.clipsToBounds = true
        pxContentView.addSubview(labelsView)

        if let circleImage = iconImageView {
            pxContentView.addSubview(circleImage)
            PXLayout.centerVertically(view: circleImage, withMargin: PXLayout.ZERO_MARGIN)
            PXLayout.pinLeft(view: circleImage, withMargin: PXLayout.L_MARGIN)

            // Put labels view next to the icon
            PXLayout.put(view: labelsView, rightOf: circleImage, withMargin: PXLayout.S_MARGIN)
        } else {
            // Pin labels view next to the left
            PXLayout.pinLeft(view: labelsView, withMargin: PXLayout.XS_MARGIN)
        }
        PXLayout.pinRight(view: labelsView, withMargin: PXLayout.XS_MARGIN)
        PXLayout.centerVertically(view: labelsView)
        PXLayout.matchHeight(ofView: labelsView, relation: .lessThanOrEqual)

        // Title Label
        if let title = data?.title {
            title.addAttributes(titleAttributes, range: NSRange(location: 0, length: title.length))

            let label = UILabel()
            label.font = Utils.getSemiBoldFont(size: PXLayout.XS_FONT)
            label.attributedText = title
            labelsView.addSubviewToBottom(label)
        }

        // Subtitle Label
        if let subtitle = data?.subtitle {
            subtitle.addAttributes(subtitleAttributes, range: NSRange(location: 0, length: subtitle.length))

            let label = UILabel()
            label.font = Utils.getFont(size: PXLayout.XXS_FONT)
            label.numberOfLines = 2
            label.lineBreakMode = .byTruncatingTail
            label.attributedText = subtitle
            labelsView.addSubviewToBottom(label, withMargin: PXLayout.XXXS_MARGIN)
        }

        //Action Label
        if let action = data?.action {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false

            button.contentHorizontalAlignment = .left
            button.setTitle(action.label, for: .normal)
            button.titleLabel?.font = Utils.getFont(size: 14)
            button.setTitleColor(ThemeManager.shared.secondaryColor(), for: .normal)
            button.add(for: .touchUpInside, action.action)
            labelsView.addSubviewToBottom(button, withMargin: PXLayout.XXXS_MARGIN)
            PXLayout.setHeight(owner: button, height: 20)
            PXLayout.pinLeft(view: button)
            PXLayout.pinRight(view: button)
        }

        labelsView.pinLastSubviewToBottom()
    }

    @objc func actionTapped() {
        guard let action = data?.action else {
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
}
