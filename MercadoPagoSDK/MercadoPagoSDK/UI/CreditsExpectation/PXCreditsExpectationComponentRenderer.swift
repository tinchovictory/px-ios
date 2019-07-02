//
//  PXCreditsExpectationComponentRenderer.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 24/11/17.
//  Copyright © 2019 MercadoPago. All rights reserved.
//

import UIKit

class PXCreditsExpectationComponentRenderer: NSObject {
    let TITLE_FONT_SIZE: CGFloat = PXLayout.M_FONT
    let SUBTITLE_FONT_SIZE: CGFloat = PXLayout.XS_FONT

    func render(component: PXCreditsExpectationComponent) -> PXCreditsExpectationView {
        let pmBodyView = PXCreditsExpectationView()
        pmBodyView.backgroundColor = .white
        pmBodyView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        pmBodyView.titleLabel = title
        pmBodyView.addSubview(title)
        title.font = Utils.getLightFont(size: TITLE_FONT_SIZE)
        title.text = component.props.title
        title.textColor = .px_grayDark()
        title.textAlignment = .center
        title.numberOfLines = 0
        pmBodyView.pinFirstSubviewToTop(withMargin: PXLayout.L_MARGIN)?.isActive = true
        PXLayout.matchWidth(ofView: title, toView: pmBodyView, withPercentage: CGFloat(60), relation: .equal).isActive = true
        PXLayout.centerHorizontally(view: title).isActive = true

        //Subtitle
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        pmBodyView.addSubview(detailLabel)
        pmBodyView.subtitleLabel = detailLabel
        detailLabel.font = Utils.getLightFont(size: SUBTITLE_FONT_SIZE)
        detailLabel.text = component.props.subtitle
        detailLabel.textColor = .px_grayDark()
        detailLabel.textAlignment = .center
        pmBodyView.putOnBottomOfLastView(view: detailLabel, withMargin: PXLayout.S_MARGIN)?.isActive = true
        PXLayout.matchWidth(ofView: detailLabel, toView: pmBodyView, withPercentage: CGFloat(80), relation: .equal).isActive = true
        PXLayout.centerHorizontally(view: detailLabel).isActive = true
        pmBodyView.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true

        return pmBodyView
    }
}
