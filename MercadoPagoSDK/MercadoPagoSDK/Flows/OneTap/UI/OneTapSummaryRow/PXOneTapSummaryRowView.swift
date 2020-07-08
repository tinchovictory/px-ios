//
//  PXOneTapSummaryRowView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit

class PXOneTapSummaryRowView: UIView {

    typealias Handler = () -> Void

    enum RowType {
        case discount
        case charges
        case generic
    }

    private var data: PXOneTapSummaryRowData
    private var titleLabel: UILabel?
    private var iconImageView: UIImageView?
    private var valueLabel: UILabel?
    private var infoIcon: UIImageView?
    var overviewBrief: UILabel?
    var heightConstraint = NSLayoutConstraint()

    init(data: PXOneTapSummaryRowData) {
        self.data = data
        super.init(frame: CGRect.zero)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func getData() -> PXOneTapSummaryRowData {
        return data
    }

    func getTotalHeightNeeded() -> CGFloat {
        return getRowHeight() + getRowMargin()
    }

    open func getRowMargin() -> CGFloat {
        return data.isTotal ? PXLayout.ZERO_MARGIN : PXLayout.XXS_MARGIN
    }

    open func getRowHeight() -> CGFloat {
        if data.isTotal {
            return !UIDevice.isSmallDevice() ? 52 : 48
        } else {
            return data.rowHasBrief() ? 48 : 16
        }
    }

    func update(_ newData: PXOneTapSummaryRowData) {
        self.data = newData
        self.updateUI(animated: true)
    }

    private func updateUI(animated: Bool = false) {
        let duration = 0.5

        if animated {
            titleLabel?.fadeTransition(duration)
            iconImageView?.fadeTransition(duration)
            valueLabel?.fadeTransition(duration)
//            infoIcon?.fadeTransition(duration)
        }

        titleLabel?.alpha = data.alpha
        valueLabel?.alpha = data.alpha
        if data.overview == nil {
            titleLabel?.text = data.title
            titleLabel?.textColor = data.highlightedColor

            iconImageView?.image = data.image
            iconImageView?.isHidden = data.image == nil

            valueLabel?.text = data.value
            valueLabel?.textColor = data.highlightedColor
        } else {
            titleLabel?.attributedText = data.getDescriptionText()
            if let infoIcon = infoIcon {
//                Utils().loadImageFromURLWithCache(withUrl: data.getIconUrl(), targetView: infoIcon, placeholderView: nil, fallbackView: nil, fadeInEnabled: false) { [weak self] newImage in
//                    self?.infoIcon?.image = newImage
//                }
                infoIcon.isHidden = data.getIconUrl() == nil
            }
            valueLabel?.attributedText = data.getAmountText()
        }

        let rowValue = data.value.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ".", with: "")
        accessibilityLabel = "\(data.title)" + "\(rowValue)" + "pesos".localized
    }

    private func render() {
        removeAllSubviews()
        let rowHeight = getRowHeight()
        let titleFont = data.isTotal ? UIFont.ml_regularSystemFont(ofSize: PXLayout.S_FONT) : UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
        let valueFont = data.isTotal ? UIFont.ml_semiboldSystemFont(ofSize: PXLayout.S_FONT) : UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
        let shouldAnimate = data.isTotal ? false : true

        if data.isTotal {
            self.backgroundColor = ThemeManager.shared.navigationBar().backgroundColor
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.pxShouldAnimatedOneTapRow = shouldAnimate

        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.textAlignment = .left
        let verStackView = UIStackView()
        if data.overview == nil {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = data.title
            titleLabel.font = titleFont
            addSubview(titleLabel)
            PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
            PXLayout.centerVertically(view: titleLabel).isActive = true
        } else {
            // Overview description
            titleLabel.attributedText = data.getDescriptionText()
            verStackView.translatesAutoresizingMaskIntoConstraints = false
            verStackView.axis = .vertical
            addSubview(verStackView)
            NSLayoutConstraint.activate([
                titleLabel.heightAnchor.constraint(equalToConstant: 16),
                verStackView.topAnchor.constraint(equalTo: topAnchor),
                verStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PXLayout.L_MARGIN),
                verStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100),
                verStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            let horStackview = UIStackView()
            horStackview.translatesAutoresizingMaskIntoConstraints = false
            horStackview.axis = .horizontal
            horStackview.addArrangedSubview(titleLabel)

            // Overview Info icon
            if data.rowHasInfoIcon() {
                let icon = buildInfoIcon()
                let iconContainer = UIView()
                iconContainer.addSubview(icon)
                NSLayoutConstraint.activate([
                    icon.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: 2),
                    icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                    icon.heightAnchor.constraint(equalToConstant: 16),
                    icon.widthAnchor.constraint(equalToConstant: 16)
                ])
                horStackview.addArrangedSubview(iconContainer)
            }
            verStackView.addArrangedSubview(horStackview)
        }

        // Overview brief
        if data.rowHasBrief() {
            let brief = UILabel()
            overviewBrief = brief
            brief.translatesAutoresizingMaskIntoConstraints = false
            brief.textAlignment = .left
            brief.numberOfLines = 2
            brief.attributedText = data.getBriefText()

            let containerView = UIView()
            containerView.addSubview(brief)
            verStackView.addArrangedSubview(containerView)
            NSLayoutConstraint.activate([
                brief.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                brief.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                brief.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2)
            ])
        }

        if data.overview == nil {
            let imageView: UIImageView = UIImageView()
            self.iconImageView = imageView
            let imageSize: CGFloat = 16
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            PXLayout.setWidth(owner: imageView, width: imageSize).isActive = true
            PXLayout.setHeight(owner: imageView, height: imageSize).isActive = true
            PXLayout.centerVertically(view: imageView, to: titleLabel).isActive = true
            PXLayout.put(view: imageView, rightOf: titleLabel, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        }

        let valueLabel = UILabel()
        self.valueLabel = valueLabel
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .right
        addSubview(valueLabel)
        PXLayout.pinRight(view: valueLabel, withMargin: PXLayout.L_MARGIN).isActive = true
        if data.overview == nil {
            valueLabel.text = data.value
            valueLabel.font = valueFont
            PXLayout.centerVertically(view: valueLabel).isActive = true
        } else {
            // Overview amount
            valueLabel.attributedText = data.overview?.amount.getAttributedString(fontSize: PXLayout.XXS_FONT, backgroundColor: .clear)
            valueLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }

        if overviewBrief == nil {
            PXLayout.setHeight(owner: self, height: rowHeight).isActive = true
        } else {
            heightConstraint = PXLayout.setHeight(owner: self, height: rowHeight)
        }

        isAccessibilityElement = true
        let rowValue = valueLabel.text?.replacingOccurrences(of: "$", with: "") ?? ""
        accessibilityLabel = "\(titleLabel.text ?? "")" + "\(rowValue)" + "pesos".localized
        updateUI()
    }
}

// MARK: Publics
extension PXOneTapSummaryRowView {
    func briefHasOneLine() -> Bool {
        guard let brief = overviewBrief else { return false }
        return brief.intrinsicContentSize.height < CGFloat(16) ? true : false
    }
}

// MARK: Privates
private extension PXOneTapSummaryRowView {
    func buildInfoIcon() -> UIImageView {
        let icon = UIImageView()
        infoIcon = icon
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.backgroundColor = .clear
        icon.clipsToBounds = true
        if let infoIcon = infoIcon {
            Utils().loadImageFromURLWithCache(withUrl: data.getIconUrl(), targetView: infoIcon, placeholderView: nil, fallbackView: nil, fadeInEnabled: true) { [weak self] newImage in
                self?.infoIcon?.image = newImage
            }
        }
        return icon
    }
}
