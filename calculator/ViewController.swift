//
//  ViewController.swift
//  calculator
//
//  Created by Long Tran on 3/26/16.
//  Copyright © 2016 Long Tran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var answerLabel = UILabel();
    var boldedButton:UIButton = UIButton();
    var finishCalc = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Constants
        let screenSize:CGRect = UIScreen.mainScreen().bounds;
        let screenWidth = screenSize.width;
        let screenHeight = screenSize.height;
        let buttonWidth = screenWidth / 4;
        let buttonHeight = screenHeight * 0.72 / 5;
        let buttonStart = screenHeight * 0.28;
        let buttonTitles = ["Del", "(", ")", "÷",
                            "7", "8", "9", "×",
                            "4", "5", "6", "-",
                            "1", "2", "3", "+",
                            "0", "Clear", "·", "="];
        let darkGray:UIColor = UIColor(red:CGFloat(215.0/255.0),
                                       green:CGFloat(215.0/255.0),
                                       blue:CGFloat(215.0/255.0),
                                       alpha:CGFloat(1.0));
        let lightGray:UIColor = UIColor(red:CGFloat(247.0/255.0),
                                        green:CGFloat(247.0/255.0),
                                        blue:CGFloat(247.0/255.0),
                                        alpha:CGFloat(1.0));
        let lightOrange:UIColor = UIColor(red:CGFloat(255.0/255.0),
                                          green:CGFloat(149.0/255.0),
                                          blue:CGFloat(0),
                                          alpha:CGFloat(1.0));
        
        //Answer label
        answerLabel = UILabel(frame: CGRectMake(0, 0, screenWidth, screenHeight * 0.28));
        answerLabel.backgroundColor = UIColor.blackColor();
        answerLabel.text = "0";
        answerLabel.textAlignment = NSTextAlignment.Right;
        answerLabel.adjustsFontSizeToFitWidth = true;
        answerLabel.font = UIFont.systemFontOfSize(90, weight: UIFontWeightUltraLight)
        answerLabel.textColor = UIColor.whiteColor();
        self.view.addSubview(answerLabel)
        
        //Adding buttons
        var currentX = CGFloat(0);
        var currentY = buttonStart;
        var index = 0;
        for _ in 0 ... 4 {
            for _ in 0 ... 3 {
                //Create button and set its appreance
                let button = UIButton(type: UIButtonType.System) as UIButton
                button.frame = CGRectMake(currentX, currentY, buttonWidth, buttonHeight);
                
                button.layer.borderWidth = 0.5;
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
                button.titleLabel?.font = UIFont.systemFontOfSize(60, weight: UIFontWeightUltraLight)
                button.backgroundColor = lightGray;
                
                //Update next starting x position
                currentX += buttonWidth;
                if(buttonTitles[index] == " ") {
                    index += 1;
                    continue;
                }
                else if(index < 3) {
                    button.backgroundColor = darkGray;
                }
                else if((index + 1) % 4 == 0) {
                    button.backgroundColor = lightOrange;
                    button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
                }
                else {
                    
                }
                //Add button handler
                button.addTarget(self, action: #selector(ViewController.buttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                button.setTitle(buttonTitles[index], forState: UIControlState.Normal);
                index += 1;
                
                self.view.addSubview(button)
            }
            currentX = CGFloat(0);
            currentY += buttonHeight;
        }
    }
    
    func buttonAction(sender:UIButton!) {
        var buttonValue:String = (sender.titleLabel?.text)!;
        let currentAnswer = answerLabel.text;
        let lastIndex = (currentAnswer?.characters.count)! - 1;
        
        boldedButton.layer.borderWidth = 0.5;
        
        if(!isSpecialOp(buttonValue)) {
            //UI
            sender.layer.borderWidth = 2;
            boldedButton = sender;
            
            // If answer label is currently at starting state, reset it.
            if(answerLabel.text == "0" && !isBasicOp(buttonValue)) {
                answerLabel.text = "";
            }
            
            //If the previous key and current key are both operators, use the latter only
            if(isBasicOp((currentAnswer! as NSString).substringFromIndex(lastIndex)) &&
                isBasicOp(buttonValue)) {
                let deleted = (answerLabel.text! as NSString).substringToIndex(lastIndex);
                answerLabel.text = deleted + buttonValue;
                return;
            }
        
            //If a calculation is finished and key pressed is not an operator, reset label to start new
            if(finishCalc && !isBasicOp(buttonValue)) {
                answerLabel.text = "";
                finishCalc = false;
            }
            else if(finishCalc) {
                finishCalc = false;
            }
            
            //Check if decimal point or negate sign
            if(buttonValue == "·") {
                buttonValue = ".";
            }
            else if(buttonValue == "Clear") {
                answerLabel.text = "0";
                buttonValue = "";
            }
            answerLabel.text = answerLabel.text! + buttonValue;
        }
        else {
            switch(buttonValue) {
                case "Del":
                    let labelLength = answerLabel.text?.characters.count;
                    var deleted = (answerLabel.text! as NSString).substringToIndex(labelLength! - 1);
                    if(deleted == "") {
                        deleted = "0";
                    }
                    answerLabel.text = deleted;
                    break;
                case "=":
                    let expr = NSExpression(format: sanitize(answerLabel.text!));
                    answerLabel.text = String(evaluate(expr));
                    finishCalc = true;
                    break;
                default:
                    break;
            }
        }
    }
    
    func sanitize(dirty:String) -> String {
        //Replace with proper mul and div signs
        var result = dirty.stringByReplacingOccurrencesOfString("÷", withString: "/");
        result = result.stringByReplacingOccurrencesOfString("×", withString: "*");
        
        //Parse each value as a double
        let delimiters:String = "+-*/()";
        let digits:String = "0123456789.";
        
        var onlyDigits = result.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: delimiters));
        var onlyOperators = result.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: digits));
        
        onlyDigits = onlyDigits.filter({$0 != ""});
        onlyOperators = onlyOperators.filter({$0 != ""});
        
        var finalResult = [String](count: onlyDigits.count + onlyOperators.count, repeatedValue: "");
        
        var digitIndex = 0;
        var opIndex = 1;
        
        if(onlyOperators.first == "(") {
            digitIndex = 1;
            opIndex = 0;
        }
        
        for i in 0 ... onlyDigits.count {
            if(digitIndex < finalResult.count) {
                finalResult[digitIndex] = String(Double(onlyDigits[i])!);
                digitIndex = digitIndex + 2;
            }
        }
        for i in 0 ... onlyDigits.count {
            if(opIndex < finalResult.count) {
                finalResult[opIndex] = String(UTF8String: onlyOperators[i])!;
                opIndex = opIndex + 2;
            }
        }
        return finalResult.joinWithSeparator("");
    }
    
    func evaluate(expr:NSExpression) -> NSNumber{
        return expr.expressionValueWithObject(nil, context: nil) as! NSNumber
    }
    
    func isBasicOp(op:String) -> Bool {
        return op == "+" || op == "-" || op == "×" || op == "÷";
    }
    
    func isSpecialOp(op:String) -> Bool {
        return op == "=" || op == "Del";
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}