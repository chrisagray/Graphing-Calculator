//
//  CalculatorViewController.swift
//  GraphingCalculator
//
//  Created by Chris Gray on 9/28/16.
//  Copyright © 2016 Chris Gray. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var userIsInTheMiddleOfTyping = false
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var sequence: UILabel!
    
    
    private var brain = CalculatorBrain()
    
    @IBAction func clearEverything() {
        brain.clear()
        brain.clearVariables()
        displayValue = 0
        sequence.text = "0"
        userIsInTheMiddleOfTyping = false
        savedProgram = nil
    }
    
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTyping {
            if (display.text?.characters.count)! > 1 {
//                display.text?.remove(at: display.text!.characters.index(before: display.text!.endIndex))
                display.text?.removeAtIndex(display.text!.characters.endIndex)
            }
            else {
                displayValue = brain.result
                userIsInTheMiddleOfTyping = false
            }
        }
        else {
            brain.undo()
            displayValue = brain.result
        }

    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if !(digit == "." && display.text?.rangeOfString(".") != nil) {
                //only add digit if it's not a decimal when there's already one
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
            sequence.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
    
    var savedProgram : CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
        
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }

    
    @IBAction func storeVar() {
        brain.variableValues["M"] = displayValue
        displayValue = brain.result
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func getVar() {
        brain.setOperand("M")
        displayValue = brain.result
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if !brain.isPartialResult
        {
            var destinationVC = segue.destinationViewController
            if let navcon = destinationVC as? UINavigationController {
                //look inside the navigation controller to the GraphViewController
                destinationVC = navcon.visibleViewController ?? destinationVC
            }
            if let graphVC = destinationVC as? GraphViewController {
                graphVC.program = brain.program
                graphVC.navigationItem.title = brain.description
            }
        }
    }
    
    
}




















