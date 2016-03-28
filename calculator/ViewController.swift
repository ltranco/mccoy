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
    var currentOperator = "";
    var answer = 0.0;
    var clearLabel = false;
    var boldedButton:UIButton = UIButton();
    var previouslyOp = false;
    var decimalPresent = false;
    
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
        let buttonTitles = ["AC", "+/-", "%", "÷",
                            "7", "8", "9", "x",
                            "4", "5", "6", "-",
                            "1", "2", "3", "+",
                            "0", " ", "·", "="];
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
                else if(buttonTitles[index] == "0") {
                    button.frame = CGRectMake(currentX - buttonWidth, currentY, buttonWidth * 2, buttonHeight);
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
    
    func isOperator(op:String) -> Bool {
        return op == "+" || op == "-" || op == "x" || op == "÷" ||
            op == "AC" || op == "=" || op == "+/-" || op == "%";
    }
    
    func truncate(str:String) -> String {
        var result = str;
        if(str.characters.count > 14) {
            result = (result as NSString).substringToIndex(14);
        }
        return result;
    }
    
    func solve(left:Double, op:String, right:Double) {
        switch(op) {
            case "+":
                answer = Double(left + right);
            case "-":
                answer = Double(left - right);
            case "x":
                answer = Double(left * right);
            case "÷":
                answer =  Double(left) / Double(right);
            default:
                answer = 0.0;
        }
        if(answer % 1 == 0) {
            answerLabel.text = truncate(String(Int(answer)));
        }
        else {
            answerLabel.text = truncate(String(answer));
        }
    }
    
    func buttonAction(sender:UIButton!)
    {
        let buttonValue:String = (sender.titleLabel?.text)!;
        var currentAnswer = answerLabel.text;
        
        
        boldedButton.layer.borderWidth = 0.5;
        
        if(!isOperator(buttonValue)) {
            if(clearLabel) {
                answerLabel.text = "";
                currentAnswer = "";
                clearLabel = false;
            }
            if(currentAnswer == "0" && buttonValue != "·") {
                currentAnswer = "";
            }
            if(buttonValue == "·" && decimalPresent) {
                return;
            }
            if(buttonValue == "·") {
                answerLabel.text = truncate(currentAnswer! + ".");
            }
            else {
                answerLabel.text = truncate(currentAnswer! + buttonValue);
            }
            if(buttonValue == "·") {
                decimalPresent = true;
            }
            else {
                decimalPresent = false;
            }
            previouslyOp = false;
        }
        else {
            decimalPresent = false;
            switch(buttonValue) {
            case "AC":
                answerLabel.text = "0";
                answer = 0;
                previouslyOp = false;
                break;
            case "+", "-", "x","÷":
                sender.layer.borderWidth = 2;
                boldedButton = sender;
            
                if(!previouslyOp) {
                    if(answer != 0) {
                        solve(answer, op: currentOperator, right: Double(currentAnswer!)!);
                    }
                    else {
                        answer = Double(currentAnswer!)!;
                    }
                }
                currentOperator = buttonValue;
                previouslyOp = true;
                clearLabel = true;
                break;
            case "+/-":
                let negate = Double(currentAnswer!)! * -1;
                if(negate % 1 == 0) {
                    answerLabel.text = truncate(String(Int(negate)));
                }
                else {
                    answerLabel.text = truncate(String(Double(negate)));
                }
                previouslyOp = false;
            case "%":
                solve(Double(currentAnswer!)!, op: "÷", right: 100);
                previouslyOp = true;
                break;
            case "=":
                solve(answer, op: currentOperator, right:Double(currentAnswer!)!);
                clearLabel = true;
                previouslyOp = false;
                break;
            default:
                break;
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}