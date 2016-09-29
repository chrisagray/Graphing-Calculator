//
//  GraphView.swift
//  Calculator
//
//  Created by Chris Gray on 9/28/16.
//  Copyright © 2016 Chris Gray. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func getYValue(x: Double) -> Double
}

//@IBDesignable
class GraphView: UIView {
    
    weak var dataSource: GraphViewDataSource?
    
    private let brain = CalculatorBrain()
    
//    @IBInspectable
    var graphPointsPerUnit: CGFloat = 100 { didSet { setNeedsDisplay() } }
    
    private var resetOrigin = true {
        didSet {
            if resetOrigin {
                setNeedsDisplay()
            }
        }
    }
    
    var graphOrigin = CGPoint() {
        didSet {
            resetOrigin = false
            setNeedsDisplay()
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            graphPointsPerUnit *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func panGraph(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            fallthrough
        case .Changed:
            let translation = recognizer.translationInView(self)
            graphOrigin.x += translation.x
            graphOrigin.y += translation.y
            recognizer.setTranslation(CGPoint.zero, inView: self)
        default:
            break
        }
    }
    
    func moveOrigin(recognizer: UITapGestureRecognizer) {
//        let location = recognizer.location(in: self)
        let location = recognizer.locationInView(self)
        if recognizer.state == .Ended {
            graphOrigin = location
        }
    }
    
    func graphPath() -> UIBezierPath {
        let path = UIBezierPath()
        let maxX = bounds.size.width
        var x = -maxX
        var graphStarted = false
        
        while x*graphPointsPerUnit < maxX {
            let y = CGFloat(dataSource!.getYValue(Double(x)))
            let xToGraph = graphOrigin.x + x*graphPointsPerUnit
            let yToGraph = graphOrigin.y - y*graphPointsPerUnit
            let pointToGraph = CGPoint(x: xToGraph, y: yToGraph)
            
            if graphStarted {
                if y.isNormal {
                    path.addLineToPoint(pointToGraph)
                }
                else {
                    path.moveToPoint(pointToGraph)
                }
            }
            else {
//                path.move(to: pointToGraph)
                path.moveToPoint(pointToGraph)
                graphStarted = true
            }
            x += 1/graphPointsPerUnit
        }
        return path
    }
    
    override func drawRect(rect: CGRect) {
        if resetOrigin {
            graphOrigin = center
        }
        AxesDrawer(contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: graphOrigin, pointsPerUnit: graphPointsPerUnit)
        graphPath().stroke()
    }
    
    
}
