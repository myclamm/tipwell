//
//  TipViewController.swift
//  tippy
//
//  Created by Mike Lam on 9/27/16.
//  Copyright © 2016 CodePath Assignment #1. All rights reserved.
//

import UIKit
extension Double {
    func string(fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        
        return formatter.string(from: NSNumber.init( value: self)) ?? "\(self)"
    }
}

let locale = Locale.current
let currencySymbol = locale.currencySymbol
class TipViewController: UIViewController {
    
    
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    // Default tip percentages
    var tipPercentages: [Double] = [0.18,0.2,0.25]
    let white = UIColor(red:0.97, green:1.00, blue:0.97, alpha:1.0)
    

    let green = UIColor(red:0.17, green:0.92, blue:0.64, alpha:1.0)

    // Before view loads
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Add cursor to bill field
        billField.becomeFirstResponder()
        
        var billString: String = billField.text!
        if(billString.characters.first == nil) {
            billField.text = currencySymbol
        }
        
        let defaults = UserDefaults.standard
        print("billField.text2")
        print(billField.text)
        // Check for previously stored bill value
        let storedBill = defaults.string(forKey:"billField")
        
        let now = NSDate()
        print("now \(now)")
        var difference: TimeInterval = 0
        
        if let lastChanged = defaults.object(forKey:Const.DefaultsKeys.lastChanged) as? Date {
            difference = now.timeIntervalSince(lastChanged)
        }
        
        if (storedBill != "0") && (difference <= 600) {
            billField.text = storedBill
        }
        
        
        // If user changed default tips in settings, update tipPercentages
        tipPercentages = defaults.array(forKey:"tipDefault") as? [Double] ?? tipPercentages
        
        // Update tipControl view
        for (i,v) in tipPercentages.enumerated() {
            
            let percentage:String = "\(Int(v*100))%"
            
            tipControl.setTitle(percentage, forSegmentAt: Int(i))
        }
        // Set the tip control to be whatever's stored in UserDefaults
        tipControl.selectedSegmentIndex = defaults.integer(forKey:"defaultTipIndex")
        // Recalculate tip
        let text = String(describing: billField.text!)
        let nums = onlyNums(str: text)
        let bill = Double(nums) ?? 0
        calculateTip(bill: bill)
        animateBackground()
        
    }
    

    // After view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        billField.textColor = self.white
        billField.font = UIFont(name: "chalkduster", size: 50)
        
        tipLabel.textColor = self.white
        totalLabel.textColor = self.white
        label1.textColor = self.green
        label2.textColor = self.green
        
        tipControl.tintColor = self.green
        bar.backgroundColor = self.green
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Close the keyboard when user taps on view
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    // Because we need to recalculate tip when tip percent changes
    @IBAction func onTipChange(_ sender: AnyObject) {
        let text = String(describing: billField.text!)
        let nums = onlyNums(str: text)
        let bill = Double(nums) ?? 0
        calculateTip(bill: bill)
        animateBackground()
    }
    
    // Because we need to recalculate tip when bill changes
    @IBAction func onBillChange(_ sender: AnyObject) {
        print("onBillChange function invoked")
        let defaults = UserDefaults.standard
        defaults.set(NSDate(), forKey: Const.DefaultsKeys.lastChanged)
        
        // Always prefix with dollar symbol
        if (billField.text?.characters.first == nil) {
            billField.text = currencySymbol
        }
        var input = String(describing: billField.text!)
        // strip input of nonNumeric characters, but retain "."'s
        let numString = onlyNums(str: input)
        
        // Enforce two decimals
        if (numberOfDecimalPlaces(str: billField.text!) > 2){
            billField.text = String(input.characters.dropLast())
            defaults.set(billField.text,forKey:"billField")
            return
        }
        
        print("setting billfield \(billField.text)")
        
        // Edge case: Prevent ".0" from being translated into 0
        if Float(numString) == 0 {
            print("equals 0")
            return
        }
        
        // Edge case: Prevent "." from being translated into 0
        if (input == "." ) {
            defaults.set(billField.text,forKey:"billField")
            return
        }
        
        // Edge case: Prevent user from inputting multiple decimals
        if input.characters.last == "." {
            if (Float(numString)==nil) {
                billField.text = String(input.characters.dropLast())
                defaults.set(billField.text,forKey:"billField")
                return
            }
            return
        }
        
        // HACK: to avoid converting x.0 to x while user is typing
        if input.range(of: "\(currencySymbol!).") == nil {
            if input.range(of:".") != nil {
                let last = input.characters.last
                if last == "0" {
                    let bill: Double = Double(numString)!
                    let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
                    let total = bill + tip
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = NSLocale.current
                    self.tipLabel.text = formatter.string(from:  NSNumber.init( value: Float64(tip)))
                    self.totalLabel.text = formatter.string(from:  NSNumber.init( value: Float64(total)))
                    defaults.set(billField.text,forKey:"billField")
                    return
                }
            }
        }
        
        // Store bill in case user turns off app
        defaults.set(billField.text,forKey:"billField")
        
        // Convert input to a number and default to 0 in case of empty input
        let billVal = Double(numString) ?? 0
        
        // Calculate tip and transform bill & tip views
        calculateTip(bill: billVal)

    }
    
    func animateBackground () {
        let tipIndex = self.tipControl.selectedSegmentIndex
        UIView.animate(withDuration:
            1.0, animations: {
                
                switch tipIndex {
                case 2:
                    self.mainView.backgroundColor = UIColor(red:0.13, green:0.67, blue:0.63, alpha:1.0)
                    
                case 1:
                    self.mainView.backgroundColor = UIColor(red:0.27, green:0.41, blue:0.56, alpha:1.0)
                case 0:
                    self.mainView.backgroundColor = UIColor(red:0.02, green:0.11, blue:0.08, alpha:1.0)

                default:
                    self.mainView.backgroundColor = UIColor(red:0.02, green:0.11, blue:0.08, alpha:1.0)
                    
                }
                
                
        })
    }
    
    // Calculate tip and render view changes
    func calculateTip (bill: Double) {
        let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
        let total = bill + tip
        print("bill \(bill)")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        
        // Format tip and total views to look like currency
        tipLabel.text = formatter.string(from:  NSNumber.init( value: Float64(tip)))
        totalLabel.text = formatter.string(from:  NSNumber.init( value: Float64(total)))
        
        
        formatter.numberStyle = NumberFormatter.Style.decimal
        let shortenedBill: Double = Double(bill.string(fractionDigits: 2))!
        print("shortenedBill \(shortenedBill)")
        
//        let commas = formatter.string(from: NSNumber(value: Double(bill)))
        let commas = formatter.string(from: NSNumber.init( value: shortenedBill))
        print("commas \(commas)")
//        billField.text = "\(currencySymbol!)\(String(commas!)!)"
        if let commas = commas {
            if( commas != "0") {
                billField.text = "\(currencySymbol!)\(commas)"
            } else {
                billField.text = "\(currencySymbol!)\("")"
            }
        }
        print("billfield \(billField.text)")

    }
    
    func onlyNums(str: String) -> String{
        var nums = ""
        for k in str.characters {
            let num = Int(String(k))
            
            if num != nil {
                nums = "\(nums)\(String(k))"
            }
            
            if(String(k) == "."){
                nums = "\(nums)\(String(k))"
            }
            
        }
        
        return nums
    }
    
    func numberOfDecimalPlaces(str: String) -> Float{
        var decimalFound = false
        var decimalCount: Float = 0
        for k in str.characters {
            if(decimalFound == true){
                decimalCount += 1
            }
            if k == "." {
                decimalFound = true;
            }
            
        }
        return decimalCount
    }
    
}

