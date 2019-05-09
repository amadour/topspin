//
//  TopSpinButton.swift
//  TopSpin
//
//  Created by Amadour Griffais on 23/04/2019.
//  Copyright © 2019 Amadour Griffais. All rights reserved.
//

import UIKit

class TopSpinButton: UIButton {
    ///Layout
    override class var layerClass: AnyClass {
        return TopSpinLayer.self
    }
    var topSpinLayer: TopSpinLayer {
        return layer as! TopSpinLayer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topSpinLayer.lineWidth = 2
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        //make a square button if selected
        if isSelected {
            return CGSize(width:superSize.height, height:superSize.height)
        } else {
            return superSize
        }
    }
    
    ///Configuration properties
    override var isSelected: Bool {
        didSet {
            topSpinLayer.isLoading = isSelected
            invalidateIntrinsicContentSize()
        }
    }

    override var backgroundColor: UIColor? {
        set {
            topSpinLayer.strokeColor = newValue?.cgColor
        }
        get {
            return topSpinLayer.strokeColor == nil ? nil : UIColor(cgColor: topSpinLayer.strokeColor!)
        }
    }
}

class TopSpinLayer: CAShapeLayer {
    
    var isLoading = false {
        didSet {
            spinnerGap = isLoading ? 0.2 : 0
            if isLoading {
                startSpinning()
            } else {
                stopSpinning()
            }
            fillColor = isLoading ? UIColor.clear.cgColor : strokeColor
            add(CABasicAnimation(keyPath:"fillColor"), forKey: "fillColor")
        }
    }
    
    override var strokeColor: CGColor? {
        didSet {
            fillColor = isLoading ? UIColor.clear.cgColor : strokeColor
        }
    }
    
    override var bounds: CGRect {
        didSet {
            let radius = min(bounds.width, bounds.height) / 2
            let roundedPath = CGPath.roundedPath(rect: bounds, radius: radius)
            let doublePath = CGMutablePath()
            doublePath.addPath(roundedPath)
            doublePath.addPath(roundedPath)
            self.path = doublePath
            applySizeAnimation()
        }
    }
    
    func applySizeAnimation() {
        guard let sizeAnim = animation(forKey: "bounds.size")
            else { return }
        guard let pathAnim = sizeAnim.copy() as? CABasicAnimation
            else { return }
        pathAnim.fromValue = nil
        pathAnim.toValue = nil
        pathAnim.isAdditive = false
        pathAnim.delegate = nil
        pathAnim.setValue("path", forKey:"keyPath")
        add(pathAnim, forKey: "path")
    }
    
    var spinnerGap: CGFloat {
        set {
            let previousStrokeStart = self.strokeStart
            self.strokeStart = newValue / 4
            let anim = CABasicAnimation(keyPath: "strokeStart")
            anim.isAdditive = true
            anim.fromValue = previousStrokeStart - self.strokeStart
            anim.toValue = 0
            self.add(anim, forKey: "gapStart")
            let previousStrokeEnd = self.strokeEnd
            self.strokeEnd = 0.5 - self.strokeStart
            let anim2 = CABasicAnimation(keyPath: "strokeEnd")
            anim2.isAdditive = true
            anim2.fromValue = previousStrokeEnd - self.strokeEnd
            anim2.toValue = 0
            self.add(anim2, forKey: "gapEnd")
            self.lineCap = newValue > 0 ? .round : .butt
        }
        get {
            return strokeStart * 4.0
        }
    }
    
    func startSpinning() {
        let spin = CABasicAnimation(keyPath: "strokeStart")
        spin.isAdditive = true
        spin.fromValue = 0
        spin.toValue = 0.5
        let spin2 = spin.copy() as! CABasicAnimation
        spin2.setValue("strokeEnd", forKey: "keyPath")
        let group = CAAnimationGroup()
        group.animations = [spin, spin2]
        group.repeatCount = Float.greatestFiniteMagnitude
        group.duration = 1
        self.add(group, forKey: "spin")
    }
    
    func stopSpinning() {
        guard let spin = animation(forKey: "spin")
            else { return }
        let newSpin = spin.copy() as! CAAnimation
        let elapsed = CACurrentMediaTime() - spin.beginTime
        let repeatCount = ceil(elapsed / spin.duration)
        newSpin.repeatCount = Float(repeatCount + 1)
        add(newSpin, forKey: "spin")
    }
}

extension CGPath {
    class func roundedPath(rect: CGRect, radius: CGFloat) -> CGPath {
        let insetRect = rect.insetBy(dx: radius, dy: radius)
        let path = CGMutablePath()
        path.move(to: CGPoint(x:rect.midX, y:rect.minY))
        path.addArc(center: CGPoint(x: insetRect.maxX, y: insetRect.minY),
                    radius: radius,
                    startAngle: -CGFloat.pi / 2.0,
                    endAngle: 0,
                    clockwise: false)
        path.addArc(center: CGPoint(x: insetRect.maxX, y: insetRect.maxY),
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat.pi / 2,
                    clockwise: false)
        path.addArc(center: CGPoint(x: insetRect.minX, y: insetRect.maxY),
                    radius: radius,
                    startAngle: CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: false)
        path.addArc(center: CGPoint(x: insetRect.minX, y: insetRect.minY),
                    radius: radius,
                    startAngle: CGFloat.pi,
                    endAngle: CGFloat.pi * 3.0 / 2.0,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}
