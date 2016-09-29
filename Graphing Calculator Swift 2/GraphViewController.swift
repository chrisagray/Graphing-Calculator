//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Chris Gray on 9/28/16.
//  Copyright © 2016 Chris Gray. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    private let brain = CalculatorBrain()
    
    var program : CalculatorBrain.PropertyList? {
        didSet {
            brain.program = program!
        }
    }
    
    func getYValue(xValue: Double) -> Double {
        brain.variableValues["M"] = xValue
        return brain.result
    }
    
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            
            graphView.dataSource = self
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(GraphView.changeScale(_:))
            ))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.panGraph(_:))
            ))
            
            let doubleTapGesture = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.moveOrigin(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapGesture)
        }
    }
}
