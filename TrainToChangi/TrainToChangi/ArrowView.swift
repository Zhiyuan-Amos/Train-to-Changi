//
//  ArrowView.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 3/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

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
        let point = CGPoint(Constants.UI.ArrowView.originX,
                            Constants.UI.ArrowView.originY)

        let width = self.frame.width * Constants.UI.ArrowView.arrowWidthPercentage
        let length = self.frame.height - Constants.UI.ArrowView.arrowHeightPadding

        let arrowHead = CGMutablePath()
        arrowHead.addLines(between: getArrowHeadPoints(point: point))
        let arrowHeadBezier = UIBezierPath(cgPath: arrowHead)
        arrowHeadBezier.lineWidth = Constants.UI.ArrowView.strokeWidth
        arrowHeadBezier.stroke()

        let arrowTail = CGMutablePath()
        arrowTail.addLines(between: getArrowTailPoints(point: point, width: width))
        let arrowTailBezier = UIBezierPath(cgPath: arrowTail)
        arrowTailBezier.lineWidth = Constants.UI.ArrowView.strokeWidth
        arrowTailBezier.stroke()

        let arrowVert = CGMutablePath()
        arrowVert.addLines(between: getVerticalLinePoints(point: point, length: length,
                                                          width: width))
        let arrowVertBezier = UIBezierPath(cgPath: arrowVert)
        arrowVertBezier.lineWidth = Constants.UI.ArrowView.strokeWidth
        arrowVertBezier.stroke()

        let arrowBot = CGMutablePath()
        arrowBot.addLines(between: getHorizontalLinePoints(point: point, length: length,
                                                           width: width))
        let arrowBotBezier = UIBezierPath(cgPath: arrowBot)
        arrowBotBezier.lineWidth = Constants.UI.ArrowView.strokeWidth
        arrowBotBezier.stroke()

    }

    private func getArrowHeadPoints(point: CGPoint) -> [CGPoint] {
        let displacement = Constants.UI.ArrowView.arrowHeadDisplacement
        let topPoint = CGPoint(x: point.x + displacement,
                               y: point.y - displacement)
        let bottomPoint = CGPoint(x: point.x + displacement,
                                  y: point.y + displacement)

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
