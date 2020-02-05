//
//  PXCreditsExpectationView.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 16/5/18.
//  Copyright © 2019 MercadoPago. All rights reserved.
//

import Foundation

final class PXCreditsExpectationView: PXBodyView {

    // Constants
    let TITLE_FONT_SIZE: CGFloat = PXLayout.XS_FONT
    let SUBTITLE_FONT_SIZE: CGFloat = PXLayout.XXS_FONT
    let props: PXCreditsExpectationProps

    // Variables
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?

    init(props: PXCreditsExpectationProps) {
        self.props = props
        super.init()
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Privates
private extension PXCreditsExpectationView {
    func createSubviews() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        // Title
        let title = buildTitle()
        addSubview(title)
        pinFirstSubviewToTop(withMargin: PXLayout.ZERO_MARGIN)?.isActive = true
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        // Subtitle
        let detailLabel = buildSubtitle()
        addSubview(detailLabel)
        putOnBottomOfLastView(view: detailLabel, withMargin: PXLayout.XXXS_MARGIN)?.isActive = true
        NSLayoutConstraint.activate([
            detailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        pinLastSubviewToBottom(withMargin: PXLayout.ZERO_MARGIN)?.isActive = true
    }

    func buildTitle() -> UILabel {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        titleLabel = title
        title.font = UIFont.ml_regularSystemFont(ofSize: TITLE_FONT_SIZE)
        title.text = props.title
        title.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        title.textAlignment = .left
        title.numberOfLines = 0
        return title
    }

    func buildSubtitle() -> UILabel {
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel = detailLabel
        detailLabel.font = UIFont.ml_regularSystemFont(ofSize: SUBTITLE_FONT_SIZE)
        detailLabel.text = props.subtitle
        detailLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        detailLabel.textAlignment = .left
        return detailLabel
    }
}
