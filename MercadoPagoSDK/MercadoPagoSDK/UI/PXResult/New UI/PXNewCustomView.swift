//
//  PXNewCustomView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 29/08/2019.
//

import UIKit

open class PXNewCustomViewData {
    let title: String?
    let subtitle: String?
    let icon: UIImage?
    let iconURL: String?
    let action: PXAction?

    init(title: String?, subtitle: String?, icon: UIImage?, iconURL: String?, action: PXAction?) {
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
    let IMAGE_WIDTH: CGFloat = 30.0
    let IMAGE_HEIGHT: CGFloat = 30.0

    var iconImageView: PXUIImageView?

    var data: PXNewCustomViewData? {
        didSet {
            render()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
            PXLayout.pinLeft(view: circleImage, withMargin: PXLayout.XS_MARGIN)

            // Put labels view next to the icon
            PXLayout.put(view: labelsView, rightOf: circleImage, withMargin: PXLayout.S_MARGIN)
        } else {
            // Pin labels view next to the left
            PXLayout.pinLeft(view: labelsView, withMargin: PXLayout.XS_MARGIN)
            
        }
        PXLayout.centerVertically(view: labelsView)
        PXLayout.matchHeight(ofView: labelsView, relation: .lessThanOrEqual)


        // Title Label
        if let title = data?.title {
            let label = UILabel()
            label.text = title
            labelsView.addSubviewToBottom(label)
        }

        if let subtitle = data?.subtitle {
            let label = UILabel()
            label.text = subtitle
            labelsView.addSubviewToBottom(label)
        }

        if let action = data?.action {
            let label = UILabel()
            label.text = action.label
            labelsView.addSubviewToBottom(label)
        }

        labelsView.pinLastSubviewToBottom()
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
