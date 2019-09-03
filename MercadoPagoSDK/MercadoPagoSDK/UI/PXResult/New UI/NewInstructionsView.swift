//
//  NewInstructionsView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 03/09/2019.
//

import UIKit

class NewInstructionsView: UITableViewCell {

    var instructionsView: UIView?

    func setInstructionsView(view: UIView) {
        self.instructionsView = view
        render(with: view)
    }

    func render(with view: UIView) {
        removeAllSubviews()
        selectionStyle = .none
        addSubview(view)
        PXLayout.pinAllEdges(view: view, withMargin: PXLayout.ZERO_MARGIN)

        self.layoutIfNeeded()
    }
}
