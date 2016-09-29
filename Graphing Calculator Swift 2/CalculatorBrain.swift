//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Chris Gray on 9/28/16.
//  Copyright © 2016 Chris Gray. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    private var descriptionAccumulator = "0"
    private var internalProgram = [AnyObject]()
    var variableValues : Dictionary<String, Double> = [:] {
        didSet {
            //recalculate program with variable values
            program = internalProgram as CalculatorBrain.PropertyList
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format: "%g", operand)
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(variableName: String) {
        accumulator = variableValues[variableName] ?? 0
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    var description : String {
        get {
            if pending == nil {
                return descriptionAccumulator
            }
            else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult : Bool {
        get {
            return pending != nil
        }
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√" + "(" + $0 + ")"}),
        "×" : Operation.binaryOperation({ $0 * $1 }, {$0 + "×" + $1}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, {$0 + "÷" + $1}),
        "+" : Operation.binaryOperation({ $0 + $1 }, {$0 + "+" + $1}),
        "−" : Operation.binaryOperation({ $0 - $1 }, {$0 + "−" + $1}),
        "x²" : Operation.unaryOperation({ pow($0, 2) }, {"(" + $0 + ")" + "²"}),
        "ln" : Operation.unaryOperation({log($0)}, {"log(" + $0 + ")"}),
        "1/x" : Operation.unaryOperation({1/$0}, {"1/" + "(" + $0 + ")"}),
        "sin" : Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "=" : Operation.equals
    ]
    
    private enum Operation { //new type declaration
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value): //associated value
                accumulator = value
                descriptionAccumulator = symbol
                
            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                
            case .binaryOperation(let function, let descriptionFunction):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                
            case .equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let symbol = op as? String {
                        if operations[symbol] != nil {
                            performOperation(symbol)
                        }
                        else {
                            setOperand(symbol) //variable
                        }
                    }
                }
            }
        }
    }
    
    func undo() {
        if internalProgram.count != 0 {
            internalProgram.removeLast()
        }
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
    func clear() {
        accumulator = 0.0
        descriptionAccumulator = "0"
        pending = nil
        internalProgram.removeAll()
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    var result : Double {
        return accumulator
    }
}











