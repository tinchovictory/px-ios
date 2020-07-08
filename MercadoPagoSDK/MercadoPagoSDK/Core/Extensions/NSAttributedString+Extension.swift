//
//  NSAttributedString+Extension.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 07/07/2020.
//

import Foundation

extension NSAttributedString {
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}
