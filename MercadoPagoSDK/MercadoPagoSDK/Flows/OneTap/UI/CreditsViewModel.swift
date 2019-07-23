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

extension CreditsViewModel {
    func getCardColors() -> [CGColor] {
        var arrayColors: [CGColor] = [CGColor]()
        for color in displayInfo.gradientColors {
            arrayColors.append(color.hexToUIColor().cgColor)
        }
        return arrayColors
    }
}
