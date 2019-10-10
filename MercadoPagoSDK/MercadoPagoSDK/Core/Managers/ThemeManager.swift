//
//  ThemeManager.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 10/1/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation
import MLUI

class ThemeManager {

    static let shared = ThemeManager()

    fileprivate var currentTheme: PXTheme = PXDefaultTheme(withPrimaryColor: #colorLiteral(red: 0.2196078431, green: 0.5411764706, blue: 0.8156862745, alpha: 1)) {
        didSet {
            initialize()
        }
    }
    private var currentTrait: UITraitCollection?

    fileprivate var currentStylesheet = MLStyleSheetManager.styleSheet
    fileprivate var fontName: String = ".SFUIDisplay-Regular"
    fileprivate var fontLightName: String = ".SFUIDisplay-Light"
    fileprivate var fontSemiBoldName: String = ".SFUIDisplay-SemiBold"

    private let secondaryDarkModeBackgroundColor: UIColor = #colorLiteral(red: 0.04408342391, green: 0.04382953793, blue: 0.04428381473, alpha: 1)

    var navigationControllerMemento: NavigationControllerMemento?
}

// MARK: - Public methods
extension ThemeManager {

    func initialize() {
        currentStylesheet = MLStyleSheetManager.styleSheet
        customizeNavigationBar(theme: currentTheme)
        customizeToolBar()
        PXMonospaceLabel.appearance().font = UIFont(name: "Courier-Bold", size: 50.0)
    }

    func setDefaultColor(color: UIColor) {
        let customTheme = PXDefaultTheme(withPrimaryColor: color)
        let customStyleSheet = PXDefaultMLStyleSheet(withPrimaryColor: color)
        MLStyleSheetManager.styleSheet = customStyleSheet
        self.currentTheme = customTheme
    }

    func setTheme(theme: PXTheme) {
        self.currentTheme = theme
        if let externalFont = theme.fontName?() {
            fontName = externalFont
        }
        if let externalLightFont = theme.lightFontName?() {
            fontLightName = externalLightFont
        }
        if let externalSemiBoldFont = theme.semiBoldFontName?() {
            fontSemiBoldName = externalSemiBoldFont
        }
    }

    func getCurrentTheme() -> PXTheme {
        return currentTheme
    }

    func getFontName() -> String {
        return fontName
    }

    func getLightFontName() -> String {
        return fontLightName
    }

    func getSemiBoldFontName() -> String {
        return fontSemiBoldName
    }

    func updateTraitCollection(_ trait: UITraitCollection?) {
        self.currentTrait = trait
    }

    func isDarkMode() -> Bool {
        guard let supportDark = currentTheme.shouldSupportDarkMode?() else { return false }
        if #available(iOS 13, *) {
            if let trait = currentTrait, trait.userInterfaceStyle == .dark {
                return supportDark
            }
        }
        return false
    }
}

extension ThemeManager {
    func boldLabelTintColor() -> UIColor {
        if isDarkMode() {
            return .white
        }
        return currentStylesheet.blackColor
    }

    func labelTintColor() -> UIColor {
        return currentStylesheet.darkGreyColor
    }

    func midLabelTintColor() -> UIColor {
        return currentStylesheet.midGreyColor
    }

    func lightTintColor() -> UIColor {
        return currentStylesheet.lightGreyColor
    }

    func greyColor() -> UIColor {
        return currentStylesheet.greyColor
    }

    func whiteColor() -> UIColor {
        if isDarkMode() {
            return .black
        }
        return .white
    }

    func successColor() -> UIColor {
        return currentStylesheet.successColor
    }

    func warningColor() -> UIColor {
        return currentStylesheet.warningColor
    }

    func rejectedColor() -> UIColor {
        return currentStylesheet.errorColor
    }

    func secondaryColor() -> UIColor {
        return currentStylesheet.secondaryColor
    }

    func placeHolderColor() -> UIColor {
        return #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }

    func iconBackgroundColor() -> UIColor {
        return #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    }

    func noTaxAndDiscountLabelTintColor() -> UIColor {
        return #colorLiteral(red: 0, green: 0.6509803922, blue: 0.3137254902, alpha: 1)
    }

    func disabledCardGray() -> UIColor {
        return #colorLiteral(red: 0.2862745098, green: 0.2862745098, blue: 0.2862745098, alpha: 1)
    }

    func selectionHoverColor() -> UIColor {
        if isDarkMode() {
            return secondaryDarkModeBackgroundColor
        }
        return #colorLiteral(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }

    func dividingLineColor() -> UIColor {
        if isDarkMode() {
            return #colorLiteral(red: 0.172208488, green: 0.1730124652, blue: 0.174952805, alpha: 1)
        }
        return currentStylesheet.midGreyColor
    }
}

// MARK: - UI design exceptions
extension ThemeManager: PXTheme {
    func navigationBar() -> PXThemeProperty {
        if isDarkMode() {
            return PXThemeProperty(backgroundColor: secondaryDarkModeBackgroundColor, tintColor: .white)
        }
        return currentTheme.navigationBar()
    }

    func loadingComponent() -> PXThemeProperty {
        if isDarkMode() {
            return PXThemeProperty(backgroundColor: .black, tintColor: .white)
        }
        return currentTheme.loadingComponent()
    }

    func statusBarStyle() -> UIStatusBarStyle {
        if isDarkMode() {
            return .lightContent
         }
        return currentTheme.statusBarStyle()
    }

    func getMainColor() -> UIColor {
        if isDarkMode() {
            return secondaryDarkModeBackgroundColor
        }
        if let theme = currentTheme as? PXDefaultTheme {
            return theme.primaryColor
        }
        return currentTheme.navigationBar().backgroundColor
    }

    func getAccentColor() -> UIColor {
        if let theme = currentTheme as? PXDefaultTheme {
            return theme.primaryColor
        }
        return currentStylesheet.secondaryColor
    }

    func getTintColorForIcons() -> UIColor? {
        if currentTheme is PXDefaultTheme {
            return getMainColor()
        }
        return nil
    }

    func getTitleColorForReviewConfirmNavigation() -> UIColor {
        if isDarkMode() {
            return .white
        }

        if currentTheme is PXDefaultTheme {
            return getMainColor()
        }

        if let highlightNavigationTint = currentTheme.highlightNavigationTintColor?() {
            return highlightNavigationTint
        }
        return boldLabelTintColor()
    }

    func modalComponent() -> PXThemeProperty {
        if isDarkMode() {
            return PXThemeProperty(backgroundColor: UIColor.black, tintColor: .white)
        }
        return PXThemeProperty(backgroundColor: currentStylesheet.modalBackgroundColor, tintColor: currentStylesheet.modalTintColor)
    }

    func secondaryBackgroundColor() -> UIColor {
        if isDarkMode() {
            return secondaryDarkModeBackgroundColor
        }
        return .white
    }

    func highlightBackgroundColor() -> UIColor {
        if isDarkMode() {
            return secondaryDarkModeBackgroundColor
        }
        return currentTheme.highlightBackgroundColor()
    }

    func detailedBackgroundColor() -> UIColor {
        if isDarkMode() {
            return .black
        }
        return currentTheme.detailedBackgroundColor()
    }
}

// MARK: - Keyboard & Toolbar
extension ThemeManager {
    func getKeyboardAppearance() -> UIKeyboardAppearance {
        return isDarkMode() ? UIKeyboardAppearance.dark : UIKeyboardAppearance.light
    }

    func getToolbarStyle() -> UIBarStyle {
        return isDarkMode() ? UIBarStyle.black : UIBarStyle.default
    }
}

// MARK: - UI Theme customization
extension ThemeManager {
    fileprivate func customizeNavigationBar(theme: PXTheme) {
        UINavigationBar.appearance(whenContainedInInstancesOf: [MercadoPagoUIViewController.self]).tintColor = theme.navigationBar().tintColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [MercadoPagoUIViewController.self]).backgroundColor = theme.navigationBar().backgroundColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [MercadoPagoUIViewController.self]).tintColor = theme.navigationBar().tintColor
        PXNavigationHeaderLabel.appearance().textColor = theme.navigationBar().tintColor
    }

    fileprivate func customizeToolBar() {
        PXToolbar.appearance().tintColor = getAccentColor()
        PXToolbar.appearance().backgroundColor = isDarkMode() ? secondaryDarkModeBackgroundColor : lightTintColor()
        PXToolbar.appearance().alpha = 1
    }
}
