//
//  ProgressView.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 25.04.2023.
//

import Foundation
import UIKit

class CircleProgressView: UIView {
    var progressLayer = CAShapeLayer()
    var backgroundLayer = CAShapeLayer()
    var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }

    private func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width / 2
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2),
                                      radius: (frame.size.width - 1.5) / 2,
                                      startAngle: CGFloat(-0.5 * Double.pi),
                                      endAngle: CGFloat(1.5 * Double.pi),
                                      clockwise: true)
        
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = 1.5
        backgroundLayer.strokeEnd = 1.0
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.lineWidth = 1.5
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
}

