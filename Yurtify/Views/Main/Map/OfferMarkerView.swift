//
//  OfferMarkerView.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import MapKit
import SwiftUI

class OfferMarkerView: MKAnnotationView {
    private let containerView = UIView()
    private let priceLabel = UILabel()
    private let periodLabel = UILabel()
    private let pointerView = UIView()
    
    private var isPerformingLayout = false
    
    private var lastPrice: String = ""
    private var lastPeriod: String = ""
    private var calculatedWidth: CGFloat = 70
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        clusteringIdentifier = "offers"
        
        frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        
        priceLabel.textAlignment = .center
        priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        priceLabel.textColor = UIColor(Color.app.accentLight)
        priceLabel.lineBreakMode = .byClipping
        
        periodLabel.textAlignment = .center
        periodLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        periodLabel.textColor = UIColor(Color.app.accentLight)
        periodLabel.lineBreakMode = .byClipping
        
        let stackView = UIStackView(arrangedSubviews: [priceLabel, periodLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.frame = CGRect(x: 8, y: 6, width: 54, height: 28)
        
        containerView.backgroundColor = UIColor(Color.app.primaryVariant)
        containerView.layer.cornerRadius = 10
        containerView.frame = CGRect(x: 0, y: 0, width: 70, height: 40)
        containerView.addSubview(stackView)
        
        pointerView.backgroundColor = UIColor(Color.app.primaryVariant)
        pointerView.transform = CGAffineTransform(rotationAngle: .pi / 4)
        pointerView.frame = CGRect(x: 30, y: 35, width: 10, height: 10)
        
        addSubview(containerView)
        addSubview(pointerView)
        
        centerOffset = CGPoint(x: 0, y: -25)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let offerAnnotation = annotation as? OfferAnnotation else { return }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        let priceString = numberFormatter.string(from: NSNumber(value: offerAnnotation.price)) ?? "\(offerAnnotation.price)"
        let periodString = offerAnnotation.period.localized
        
        priceLabel.text = priceString
        periodLabel.text = periodString
        
        if priceString != lastPrice || periodString != lastPeriod {
            lastPrice = priceString
            lastPeriod = periodString
            
            calculateOptimalSize()
        }
        
        let backgroundColor = offerAnnotation.isSelected ?
            UIColor(Color.app.accentDark) : UIColor(Color.app.primaryVariant)
        containerView.backgroundColor = backgroundColor
        pointerView.backgroundColor = backgroundColor
    }
    
    private func calculateOptimalSize() {
        let priceSize = priceLabel.sizeThatFits(CGSize(width: 200, height: 20))
        
        let periodSize = periodLabel.sizeThatFits(CGSize(width: 200, height: 20))
        
        let textWidth = max(priceSize.width, periodSize.width)
        calculatedWidth = max(textWidth + 24, 70)
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        if isPerformingLayout { return }
        isPerformingLayout = true
        
        super.layoutSubviews()
        
        let containerWidth = calculatedWidth
        let containerHeight: CGFloat = 40
        
        if let stackView = containerView.subviews.first as? UIStackView {
            stackView.frame = CGRect(
                x: 8,
                y: 6,
                width: containerWidth - 16,
                height: 28
            )
        }
        
        containerView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight)
        
        let pointerSize: CGFloat = 10
        pointerView.frame = CGRect(
            x: containerWidth / 2 - pointerSize / 2,
            y: containerHeight - pointerSize / 2,
            width: pointerSize,
            height: pointerSize
        )
        
        frame = CGRect(
            x: 0,
            y: 0,
            width: containerWidth,
            height: containerHeight + pointerSize / 2
        )
        
        centerOffset = CGPoint(x: 0, y: -containerHeight / 2 - pointerSize / 2)
        
        isPerformingLayout = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        
        if let offerAnnotation = annotation as? OfferAnnotation {
            offerAnnotation.isSelected = selected
            
            let backgroundColor = selected ?
                UIColor(Color.app.accentDark) : UIColor(Color.app.primaryVariant)
            
            containerView.backgroundColor = backgroundColor
            pointerView.backgroundColor = backgroundColor
        }
    }
}
