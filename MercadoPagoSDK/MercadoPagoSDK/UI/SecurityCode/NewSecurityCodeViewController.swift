//
//  NewSecurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 04/08/2020.
//

import Foundation
import UIKit
import MLUI

class NewSecurityCodeViewController: MercadoPagoUIViewController {

    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var cardContainerTopConstraint: NSLayoutConstraint!
    var titleLabel = UILabel()

    override func viewDidLoad() {
        cardContainerView.backgroundColor = .orange

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Ingresa el código de seguridad"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        cardContainerTopConstraint.isActive = false
        cardContainerTopConstraint = cardContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32)
        cardContainerTopConstraint.isActive = true

        let fieldTitleLabel = UILabel()
        fieldTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldTitleLabel.text = "Código de seguridad"
        fieldTitleLabel.textAlignment = .center
        fieldTitleLabel.font = UIFont.ml_regularSystemFont(ofSize: 16)
        fieldTitleLabel.textColor = .black
        fieldTitleLabel.numberOfLines = 2
        view.addSubview(fieldTitleLabel)
        NSLayoutConstraint.activate([
            fieldTitleLabel.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 40),
            fieldTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fieldTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let cvvTextField = UITextField()
        cvvTextField.translatesAutoresizingMaskIntoConstraints = false
        cvvTextField.becomeFirstResponder()
        cvvTextField.keyboardType = .numberPad
        cvvTextField.keyboardAppearance = .light
        cvvTextField.backgroundColor = .lightBlue()
        view.addSubview(cvvTextField)
        NSLayoutConstraint.activate([
            cvvTextField.topAnchor.constraint(equalTo: fieldTitleLabel.bottomAnchor, constant: 16),
            cvvTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cvvTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cvvTextField.heightAnchor.constraint(equalToConstant: 24)
        ])

        let fieldSubtitleLabel = UILabel()
        fieldSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldSubtitleLabel.text = "Válido por 20 minutos"
        fieldSubtitleLabel.textAlignment = .center
        fieldSubtitleLabel.font = UIFont.ml_regularSystemFont(ofSize: 14)
        fieldSubtitleLabel.textColor = .black
        fieldSubtitleLabel.numberOfLines = 2
        view.addSubview(fieldSubtitleLabel)
        NSLayoutConstraint.activate([
            fieldSubtitleLabel.topAnchor.constraint(equalTo: cvvTextField.bottomAnchor, constant: 10),
            fieldSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fieldSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

//    init() {
////        self.prueba = prueba
////        super.init(nibName: nil, bundle: nil)
////        super.init(nibName: "SecurityCodeViewController", bundle: ResourceManager.shared.getBundle())
//    }

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
