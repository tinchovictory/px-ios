//
//  PXOneTapDisabledViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 04/12/2019.
//

import UIKit

class PXOneTapDisabledViewController: UIViewController {

    init(title: PXText?, description: PXText?, primaryButton: PXAction?, secondaryButton: PXAction?) {
        super.init(nibName: nil, bundle: nil)

        let containerView = PXComponentView()

        if let title = title {
            let label = UILabel()
            label.attributedText = title.getAttributedString(fontSize: PXLayout.XS_FONT, textColor: ThemeManager.shared.labelTintColor(), backgroundColor: .clear)
            label.textAlignment = .center
            label.numberOfLines = 0
            containerView.addSubviewToBottom(label, withMargin: PXLayout.M_MARGIN)
            PXLayout.pinLeft(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        }

        if let description = description {
            let label = UILabel()
            label.attributedText = description.getAttributedString(fontSize: PXLayout.XS_FONT, textColor: ThemeManager.shared.labelTintColor(), backgroundColor: .clear)
            label.textAlignment = .center
            label.numberOfLines = 0
            containerView.addSubviewToBottom(label, withMargin: PXLayout.M_MARGIN)
            PXLayout.pinLeft(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
            PXLayout.pinRight(view: label, withMargin: PXLayout.S_MARGIN).isActive = true
        }

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
        button.layer.cornerRadius = 10

        containerView.addSubviewToBottom(button, withMargin: PXLayout.M_MARGIN)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
            ])

        button.add(for: .touchUpInside) {
            action.action()
        }
        return button
    }
}
