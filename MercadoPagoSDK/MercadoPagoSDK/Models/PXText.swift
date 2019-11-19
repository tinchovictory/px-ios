//
//  PXText.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

public struct PXText: Codable {
    let message: String
    let backgroundColor: String?
    let textColor: String?
    let weight: String?

    enum CodingKeys: String, CodingKey {
        case message
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case weight
    }

    func getAttributedString(fontSize: CGFloat = PXLayout.XS_FONT) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: AnyObject] = [:]

        // Add text color attribute
        if let textColor = self.textColor {
            attributes[.foregroundColor] = UIColor.fromHex(textColor)
        }
        // Add background color attribute
        if let backgroundColor = self.backgroundColor {
            attributes[.backgroundColor] = UIColor.fromHex(backgroundColor)
        }

        // Add font attribute
        switch weight {
        case "regular":
            attributes[.font] = Utils.getFont(size: fontSize)
        case "semi_bold":
            attributes[.font] = Utils.getSemiBoldFont(size: fontSize)
        case "light":
            attributes[.font] = Utils.getLightFont(size: fontSize)
        default:
            attributes[.font] = Utils.getFont(size: fontSize)
        }

        return NSAttributedString(string: message, attributes: attributes)
    }
}
