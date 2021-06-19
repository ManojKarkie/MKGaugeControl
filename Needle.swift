//
//  Needle.swift
//  MKGaugeControl
//
//  Created by Manoj Karki on 3/13/21.
//

import UIKit

public final class Needle: UIView {

    public var fillColor = UIColor(red: 14.0/255.0, green:  14.0/255.0, blue: 15.0/255.0, alpha: 1.0)

    var needleShapeLayer: CAShapeLayer?
    let animationKey = "needleHikeAnimation"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setupLayer()
    }

    private func setupLayer() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        let needlePath = UIBezierPath()
        let center = CGPoint.init(x: self.bounds.width - 8.0, y: self.bounds.height/2.0)
        let startAngle = (3 * CGFloat.pi) / 2.0
        let endAngle = CGFloat.pi / 2.0
    
        needlePath.addArc(withCenter: center, radius: 8.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let leftArcRadius: CGFloat = 2.0
        let arcCenterLeft = CGPoint(x: self.bounds.origin.x + leftArcRadius, y: self.bounds.height/2.0)
        needlePath.addLine(to: CGPoint(x: self.bounds.origin.x + leftArcRadius, y: self.bounds.height/2.0 + leftArcRadius))
        needlePath.addArc(withCenter: arcCenterLeft, radius: leftArcRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        needlePath.close()
    
        shapeLayer.path = needlePath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        self.layer.addSublayer(shapeLayer)
        self.needleShapeLayer = shapeLayer
        
    }
}

extension Needle {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = needleShapeLayer?.position

        position?.x -= oldPoint.x
        position?.x += newPoint.x

        position?.y -= oldPoint.y
        position?.y += newPoint.y

        self.needleShapeLayer?.position = position ?? .zero
        self.needleShapeLayer?.anchorPoint = point
    }
}

