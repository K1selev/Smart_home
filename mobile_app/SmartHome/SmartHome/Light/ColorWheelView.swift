//
//  ColorWheelView.swift
//  SmartHome
//
//  Created by Сергей Киселев on 14.05.2025.
//

import UIKit

class ColorWheelView: UIView {

    var selectedColor: UIColor?
    var onColorSelected: ((UIColor) -> Void)?
    
    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemCyan, .systemBlue, .systemPurple, .magenta
    ].flatMap { [$0] } // добавить больше секторов

    private let innerCircleRatio: CGFloat = 0.5  // соотношение внутреннего белого круга

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
        isUserInteractionEnabled = true
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2

        let segmentAngle = CGFloat.pi * 2 / CGFloat(colors.count)

        for (index, color) in colors.enumerated() {
            ctx.setFillColor(color.cgColor)
            let startAngle = CGFloat(index) * segmentAngle
            let endAngle = startAngle + segmentAngle

            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            path.close()
            path.fill()
        }

        let innerRadius = radius * innerCircleRatio
        let innerCircle = UIBezierPath(arcCenter: center, radius: innerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        UIColor.white.setFill()
        innerCircle.fill()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let point = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let radius = min(bounds.width, bounds.height) / 2
        let innerRadius = radius * innerCircleRatio

        guard distance <= radius && distance >= innerRadius else { return }

        let angle = atan2(dy, dx) < 0 ? atan2(dy, dx) + .pi * 2 : atan2(dy, dx)
        let segmentAngle = CGFloat.pi * 2 / CGFloat(colors.count)
        let index = Int(angle / segmentAngle)

        if index < colors.count {
            selectedColor = colors[index]
            onColorSelected?(colors[index])
        }
    }
}
