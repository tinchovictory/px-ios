//
//  PXOneTapDisabledViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 04/12/2019.
//

import UIKit

class PXOneTapDisabledViewController: UIViewController {

    init(text: String, primaryButton: PXAction?, secondaryButton: PXAction?) {
        super.init(nibName: nil, bundle: nil)

        let containerView = PXComponentView()

        let description = UILabel()
        description.text = text
        description.font = Utils.getFont(size: PXLayout.XS_FONT)
        description.textColor = ThemeManager.shared.labelTintColor()
        description.textAlignment = .center
        description.numberOfLines = 0
        PXLayout.setHeight(owner: description, height: 150).isActive = true
        containerView.addSubviewToBottom(description, withMargin: PXLayout.M_MARGIN)
        PXLayout.pinLeft(view: description, withMargin: PXLayout.S_MARGIN).isActive = true
        PXLayout.pinRight(view: description, withMargin: PXLayout.S_MARGIN).isActive = true

        if let primaryAction = primaryButton {
            addNewButton(containerView: containerView, action: primaryAction)
        }

        if let secondaryAction = secondaryButton {
            addNewButton(containerView: containerView, action: secondaryAction)
        }

        containerView.pinLastSubviewToBottom(withMargin: 20)

        view.addSubviewAtFullSize(with: containerView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    func addNewButton(containerView: PXComponentView, action: PXAction) -> UIButton {
        let button = UIButton()
        button.setTitle(action.label, for: .normal)
        button.backgroundColor = .blue

        containerView.addSubviewToBottom(button, withMargin: PXLayout.M_MARGIN)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 30),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
            ])

        button.add(for: .touchUpInside) {
            action.action()
        }
        return button
    }
}
