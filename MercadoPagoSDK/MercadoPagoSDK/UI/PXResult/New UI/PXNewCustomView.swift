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

    init(title: NSMutableAttributedString?, subtitle: NSMutableAttributedString?, icon: UIImage?, iconURL: String?, action: PXAction?) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconURL = iconURL
        self.action = action
    }
}

class PXNewCustomView: UITableViewCell {

    //Row Settings
    let ROW_HEIGHT: CGFloat = 75
//    let CONTENT_WIDTH_PERCENTAGE: CGFloat = 86.0

    //Icon
    let IMAGE_WIDTH: CGFloat = 48.0
    let IMAGE_HEIGHT: CGFloat = 48.0

    var iconImageView: PXUIImageView?

    var data: PXNewCustomViewData? {
        didSet {
            render()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        // Initialization code
    }

    func setData(data: PXNewCustomViewData) {
        self.data = data
    }

    func render() {
        removeAllSubviews()
        selectionStyle = .none
        let pxContentView = UIView()
        pxContentView.backgroundColor = .clear
        addSubview(pxContentView)
        PXLayout.pinAllEdges(view: pxContentView, withMargin: PXLayout.ZERO_MARGIN)
        PXLayout.setHeight(owner: pxContentView, height: ROW_HEIGHT).isActive = true

        // Icon
        if let imageURL = data?.iconURL, imageURL.isNotEmpty {
            let pximage = PXUIImage(url: imageURL)
            iconImageView = buildCircleImage(with: pximage)
        } else {
            iconImageView = buildCircleImage(with: data?.icon)
        }

        let labelsView = PXComponentView()
        pxContentView.addSubview(labelsView)

        if let circleImage = iconImageView {
            pxContentView.addSubview(circleImage)
            PXLayout.centerVertically(view: circleImage, withMargin: PXLayout.ZERO_MARGIN)
            PXLayout.pinLeft(view: circleImage, withMargin: PXLayout.M_MARGIN)

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
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail

            title.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: title.length))

            let label = UILabel()
            label.font = Utils.getSemiBoldFont(size: PXLayout.XS_FONT)
            label.attributedText = title
            labelsView.addSubviewToBottom(label)
        }

        // Subtitle Label
        if let subtitle = data?.subtitle {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail

            subtitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: subtitle.length))

            let label = UILabel()
            label.font = Utils.getFont(size: PXLayout.XXS_FONT)
            label.numberOfLines = 2
            label.lineBreakMode = .byTruncatingTail
            label.alpha = 0.45
            label.attributedText = subtitle
            labelsView.addSubviewToBottom(label)
        }

        //Action Label
        if let action = data?.action {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false

            button.contentHorizontalAlignment = .left
            button.setTitle(action.label, for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.add(for: .touchUpInside, action.action)
            labelsView.addSubviewToBottom(button)
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
        circleImage.backgroundColor = .clear
        PXLayout.setHeight(owner: circleImage, height: IMAGE_WIDTH).isActive = true
        PXLayout.setWidth(owner: circleImage, width: IMAGE_HEIGHT).isActive = true
        return circleImage
    }
}
