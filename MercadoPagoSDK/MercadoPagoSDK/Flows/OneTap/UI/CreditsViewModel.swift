//
//  CreditsViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 10/07/2019.
//

import Foundation

struct CreditsViewModel {

    let displayInfo: PXDisplayInfoDto
//    let paymentMethodSideText: String
//    let text: String
//    let linkablePhrases: [LinkablePhraseViewModel]

    init(_ withModel: PXOneTapCreditsDto) {
        self.displayInfo = withModel.displayInfo
//        self.paymentMethodSideText = withModel.paymentMethodSideText
//        self.text = withModel.termsAndConditions.text
//        self.linkablePhrases = LinkablePhraseViewModel.create(withModel.termsAndConditions.linkablePhrases)
    }
}
