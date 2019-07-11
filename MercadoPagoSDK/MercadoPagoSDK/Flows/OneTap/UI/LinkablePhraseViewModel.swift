//
//  LinkablePhraseViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 11/07/2019.
//

import Foundation

struct LinkablePhraseViewModel {
    let phrase: String
    let link: String

    init(_ withModel: PXLinkablePhraseDto) {
        self.phrase = withModel.phrase
        self.link = withModel.link
    }

    static func create(_ withArray: [PXLinkablePhraseDto]) -> [LinkablePhraseViewModel] {
        var resultModel: [LinkablePhraseViewModel] = [LinkablePhraseViewModel]()
        for element in withArray {
            resultModel.append(LinkablePhraseViewModel(element))
        }
        return resultModel
    }
}
