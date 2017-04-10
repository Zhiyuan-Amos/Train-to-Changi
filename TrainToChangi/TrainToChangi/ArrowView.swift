//
//  ArrowView.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 3/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

// TODO - refactor magic numbers
@IBDesignable class ArrowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        let point = CGPoint(Constants.UI.arrowView.originX,
                            Constants.UI.arrowView.originY)

        let arrowHead = CGMutablePath()
        arrowHead.addLines(between: getArrowHeadPoints(point: point))
        let arrowHeadBezier = UIBezierPath(cgPath: arrowHead)
        arrowHeadBezier.lineWidth = 2.5
        arrowHeadBezier.stroke()

        let arrowTail = CGMutablePath()
        arrowTail.addLines(between: getArrowTailPoints(point: point, width: self.frame.width * 0.5))
        let arrowTailBezier = UIBezierPath(cgPath: arrowTail)
        arrowTailBezier.lineWidth = 2.5
        arrowTailBezier.stroke()

        let arrowVert = CGMutablePath()
        arrowVert.addLines(between: getVerticalLinePoints(point: point, length: self.frame.height - 10,
                                                          width: self.frame.width * 0.5))
        let arrowVertBezier = UIBezierPath(cgPath: arrowVert)
        arrowVertBezier.lineWidth = 2.5
        arrowVertBezier.stroke()

        let arrowBot = CGMutablePath()
        arrowBot.addLines(between: getHorizontalLinePoints(point: point, length: self.frame.height - 10,
                                                           width: self.frame.width * 0.5))
        let arrowBotBezier = UIBezierPath(cgPath: arrowBot)
        arrowBotBezier.lineWidth = 2.5
        arrowBotBezier.stroke()

    }

    private func getArrowHeadPoints(point: CGPoint) -> [CGPoint] {
        let topPoint = CGPoint(x: point.x + 5,
                               y: point.y - 5)
        let bottomPoint = CGPoint(x: point.x + 5,
                                  y: point.y + 5)

        return [topPoint, point, bottomPoint]
    }

    private func getArrowTailPoints(point: CGPoint, width: CGFloat) -> [CGPoint] {
        let tailPoint = CGPoint(x: point.x + width, y: point.y)
        return [point, tailPoint]
    }

    private func getVerticalLinePoints(point: CGPoint, length: CGFloat, width: CGFloat) -> [CGPoint] {
        let topPoint = CGPoint(x: point.x + width, y: point.y)
        let bottomPoint = CGPoint(x: point.x + width, y: point.y + length)
        return [topPoint, bottomPoint]
    }

    private func getHorizontalLinePoints(point: CGPoint, length: CGFloat, width: CGFloat) -> [CGPoint] {
        let endPoint = CGPoint(x: point.x, y: point.y + length)
        let vertBottomPoint = CGPoint(x: point.x + width, y: point.y + length)
        return [endPoint, vertBottomPoint]
    }

}
