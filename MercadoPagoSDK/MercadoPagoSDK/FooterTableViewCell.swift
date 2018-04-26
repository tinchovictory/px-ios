//
//  FooterTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/26/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class FooterTableViewCell: CallbackCancelTableViewCell {

    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.button.addTarget(self, action: #selector(invokeCallback), for: .touchUpInside)
        self.button.titleLabel?.font = Utils.getFont(size: 16)
    }

    func fillCell(payment: Payment){
        if payment.statusDetail.contains("cc_rejected_bad_filled"){
            self.button.setTitle("Cancelar pago".localized, for: UIControlState.normal)
        } else{
            self.button.setTitle("Continuar".localized, for: UIControlState.normal)
        }
    }

    func hideButton() {
        button.isHidden = true
    }
}
