//
//  CreditsViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 10/07/2019.
//

import Foundation

struct CreditsViewModel {

    let displayInfo: PXDisplayInfoDto

    init(_ withModel: PXOneTapCreditsDto) {
        self.displayInfo = withModel.displayInfo
    }
}
