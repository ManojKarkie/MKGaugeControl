//
//  MKGaugeView.swift
//  MKGaugeControl
//
//  Created by Manoj Karki on 3/13/21.
//

import UIKit
import CoreGraphics

fileprivate protocol MKGaugeDrawingProtocol {
    func drawTopArc()
    func drawSegments()
}

public class MKGaugeView: UIView {
    
    //MARK:- API
    public var maxGaugeLimit: Double =  0
    public var needleValue: Double = 0

    public var leftGradientColor  = UIColor.init(red: 229.0/255.0, green: 35.0/255.0, blue: 41.0/255.0, alpha: 1.0)
    public var rightGradientColor  = UIColor.init(red: 61.0/255.0, green: 203.0/255.0, blue: 156.0/255.0, alpha: 1.0)

    var pathBackgroundColor = UIColor.init(red: 224.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
    var topArchWidth: CGFloat = 15.0
    fileprivate var numberOfSegments = 3
    var segmentWidth: CGFloat = 60.0

    // SubViews
    fileprivate unowned var needle: Needle?
    fileprivate var outerGaugeLayer: CAShapeLayer?
    fileprivate var innerGaugeLayer: CAShapeLayer?
    
    fileprivate weak var innerGradientLayer: CAGradientLayer?

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    public override func draw(_ rect: CGRect) {
        // Drawing code
        drawTopArc()
        drawSegments()

        if self.outerGaugeLayer == nil {
            setupOuterGaugeLayer()
        }
        
        if self.innerGaugeLayer == nil {
            setupInnerGaugeLayer()
        }
    
        if self.needle == nil {
           setupNeedle()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    private func setupNeedle() {
        let originX = segmentWidth + (topArchWidth * 0.5)
        let width = bounds.width/2.0 - originX
        let needleView = Needle(frame: CGRect.init(x: originX, y: self.bounds.height - 8.0, width: width, height: 16.0))
        self.addSubview(needleView)
        self.needle = needleView
        self.needle?.setAnchorPoint(CGPoint.init(x: 1.0, y: 0.5))
    }

    private func setupOuterGaugeLayer() {

        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.main.scale
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .butt
        shapeLayer.lineJoin = .bevel
        shapeLayer.strokeEnd = 0
       
        let center = CGPoint.init(x: self.bounds.width/2.0, y: self.bounds.height)
        let radius = self.bounds.width / 2.0 - topArchWidth
        let startAngle = CGFloat.pi
        let endAngle =  CGFloat.pi  * 2
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 7.0
        self.outerGaugeLayer = shapeLayer
        shapeLayer.strokeColor = pathBackgroundColor.cgColor

        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [leftGradientColor, rightGradientColor].map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = outerGaugeLayer
        self.layer.masksToBounds = false
        self.layer.addSublayer(gradient)
    }
    
    private func setupInnerGaugeLayer() {

        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.main.scale
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0.0

        let center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height)
        let radius = self.bounds.width / 2.0 - (segmentWidth + 5.0)
        
        var startAngle = CGFloat.pi
        var endAngle = CGFloat.pi

        let shapeLayerPath = UIBezierPath()
    
        for i in 1...numberOfSegments {
            
            endAngle = startAngle + (CGFloat.pi) * (i == 2 ? 0.31 : 0.33)
            if getMaxEndAngleForInnerGauge() < endAngle {
                endAngle =  getMaxEndAngleForInnerGauge()
            }
    
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            shapeLayerPath.append(path)
            startAngle = endAngle + (CGFloat.pi * 0.015)

            if endAngle >=  getMaxEndAngleForInnerGauge() || getMaxEndAngleForInnerGauge() < startAngle {
                break
            }
        }

        shapeLayer.path = shapeLayerPath.cgPath
        shapeLayer.lineWidth = segmentWidth
        shapeLayer.strokeColor = pathBackgroundColor.cgColor
        self.innerGaugeLayer = shapeLayer
    
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [leftGradientColor, rightGradientColor].map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
    
        gradient.mask = innerGaugeLayer
        self.layer.masksToBounds = false
        self.layer.insertSublayer(gradient, at: 0)
        self.innerGradientLayer = gradient
    }
}

extension MKGaugeView: MKGaugeDrawingProtocol {

   fileprivate func drawTopArc() {

        let center = CGPoint.init(x: self.bounds.width/2.0, y: self.bounds.height)
        let radius = self.bounds.width / 2.0
        
        let startAngle = CGFloat.pi
        let endAngle = 2.0 * CGFloat.pi
        
        let path = UIBezierPath(arcCenter: center, radius: radius - topArchWidth, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = topArchWidth
        path.lineCapStyle = .round
        pathBackgroundColor.setStroke()
        path.stroke()
    }

    fileprivate func drawSegments() {
        let center = CGPoint.init(x: self.bounds.width/2.0, y: self.bounds.height)
        let radius = self.bounds.width / 2.0 - (segmentWidth + 5.0)
        
        var startAngle = CGFloat.pi
        var endAngle = CGFloat.pi

        for i in 1...numberOfSegments {
            endAngle = startAngle + (CGFloat.pi) * (i == 2 ? 0.31 : 0.33)
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.lineWidth = segmentWidth
            pathBackgroundColor.setStroke()
            path.stroke()
            path.close()
            startAngle = endAngle + (CGFloat.pi * 0.015)
        }
    }
}

// Animations
extension MKGaugeView {

    public func animateNeedle() {

        guard let needleLayer = self.needle?.needleShapeLayer else {
            return
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // On completion closure called here
        }
        self.animateInnerGauge()
        animateNeedleHandle(layer: needleLayer)
        animateOuterGauge()
        CATransaction.commit()
    }

    func animateNeedleHandle(layer: CAShapeLayer) {

        let needleAnimation = CABasicAnimation()
        needleAnimation.valueFunction = CAValueFunction(name: CAValueFunctionName.rotateZ)
        needleAnimation.fromValue =  0
        needleAnimation.toValue = getRotateZForNeedle()
        needleAnimation.fillMode = .forwards
        needleAnimation.duration = 0.8
        needleAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        needleAnimation.isRemovedOnCompletion = false
        layer.add(needleAnimation, forKey: "transform")
    }

    func animateOuterGauge() {
        
        self.outerGaugeLayer?.strokeStart = 0.0
        self.outerGaugeLayer?.strokeEnd = 0.0

        let strokeAnimmation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeAnimmation.toValue = getStrokeEndForOuterGauge()
        strokeAnimmation.duration = 0.8
        strokeAnimmation.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeAnimmation.fillMode = .forwards
        strokeAnimmation.isRemovedOnCompletion = false
        self.outerGaugeLayer?.add(strokeAnimmation, forKey: "topArcStrokeAnimation")
    }

    func animateInnerGauge() {

        self.innerGaugeLayer?.strokeStart = 0.0
        self.innerGaugeLayer?.strokeEnd = 0.0

        let strokeAnimmation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeAnimmation.toValue =   getStrokeEndForOuterGauge()
        strokeAnimmation.duration = 0.8
        strokeAnimmation.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeAnimmation.fillMode = .forwards
        strokeAnimmation.isRemovedOnCompletion = false
        self.innerGaugeLayer?.add(strokeAnimmation, forKey: "innerGaugeStrokeAnimation")

    }

}

private extension MKGaugeView {

    func getStrokeEndForOuterGauge() -> CGFloat {
        let strokePerUnit =  1.0 / CGFloat(maxGaugeLimit)
        return CGFloat(needleValue) * strokePerUnit
    }

    func getMaxEndAngleForInnerGauge() -> CGFloat {
        let radianPerUnit =  CGFloat.pi / CGFloat(maxGaugeLimit)
        return CGFloat(needleValue) * radianPerUnit + CGFloat.pi
    }

    func getRotateZForNeedle() -> CGFloat {
        let radianPerUnit =  CGFloat.pi / CGFloat(maxGaugeLimit)
        return CGFloat(needleValue) * radianPerUnit
    }
    
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }

}
