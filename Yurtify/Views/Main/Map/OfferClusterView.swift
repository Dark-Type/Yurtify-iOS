//
//  OfferClusterView.swift
//  Yurtify
//
//  Created by dark type on 24.06.2025.
//

import MapKit
import SwiftUI

class OfferClusterView: MKAnnotationView {
    private let containerView = UIView()
    private let countLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pointerView = UIView()
    
    private var isPerformingLayout = false
    
    private var lastCount: Int = 0
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
        frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        countLabel.textColor = UIColor(Color.app.accentLight)
        countLabel.lineBreakMode = .byClipping
        
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textColor = UIColor(Color.app.accentLight)
        subtitleLabel.lineBreakMode = .byClipping
        subtitleLabel.text = "предложений"
        
        let stackView = UIStackView(arrangedSubviews: [countLabel, subtitleLabel])
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
        
        guard let clusterAnnotation = annotation as? MKClusterAnnotation else { return }
        
        let count = clusterAnnotation.memberAnnotations.count
        
        countLabel.text = "\(count)"
        
        if count != lastCount {
            lastCount = count
            calculateOptimalSize()
        }
        
        let hasSelectedMember = clusterAnnotation.memberAnnotations.contains {
            ($0 as? OfferAnnotation)?.isSelected == true
        }
        
        let backgroundColor = hasSelectedMember ?
            UIColor(Color.app.accentDark) : UIColor(Color.app.primaryVariant)
        containerView.backgroundColor = backgroundColor
        pointerView.backgroundColor = backgroundColor
    }
    
    private func calculateOptimalSize() {
        let countSize = countLabel.sizeThatFits(CGSize(width: 200, height: 20))
        
        let subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: 200, height: 20))
        
        let textWidth = max(countSize.width, subtitleSize.width)
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
}
