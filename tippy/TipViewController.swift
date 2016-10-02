//
//  TipViewController.swift
//  tippy
//
//  Created by Mike Lam on 9/27/16.
//  Copyright © 2016 CodePath Assignment #1. All rights reserved.
//

import UIKit

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
        let storedBill = defaults.integer(forKey:"billField")
        
        let now = NSDate()
        print("now \(now)")
        var difference: TimeInterval = 0
        
        if let lastChanged = defaults.object(forKey:"lastChanged") as? Date {
            print("lastChanged \(lastChanged)")
            difference = now.timeIntervalSince(lastChanged)
            print("difference \(difference)")
        }
        
        if (storedBill != 0) && (difference <= 600) {
            print("billField.text3")
            print(billField.text)
            billField.text = String(storedBill)
            print("billField.text4")
            print(billField.text)
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
        // Always prefix with dollar symbol
        if (billField.text?.characters.first == nil) {
            billField.text = currencySymbol
        }
        var text = String(describing: billField.text!)
        let nums = onlyNums(str: text)
        
        // Edge case: If user starts by typing ".0"
        if Float(nums) == 0 {
            print("equals 0")
            return
        }
        
        // Edge case: If last digit is a decimal
        if text.characters.last == "." {
            if (text == "." ) {
                return
            }
            if (Float(nums)==nil) {
                billField.text = String(text.characters.dropLast())
                return
            }
            return
        }
        
        // HACK: to avoid converting x.0 to x while user is typing
        if text.range(of: "\(currencySymbol!).") == nil {
            if text.range(of:".") != nil {
                let last = text.characters.last
                if last == "0" {
                    let bill: Double = Double(nums)!
                    let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
                    let total = bill + tip
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = NSLocale.current
                    self.tipLabel.text = formatter.string(from:  NSNumber.init( value: Float64(tip)))
                    self.totalLabel.text = formatter.string(from:  NSNumber.init( value: Float64(total)))
                    return
                }
            }
        }
        let billVal = Double(nums) ?? 0
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        tipLabel.text = formatter.string(from:  NSNumber.init( value: Float64(tip)))
        totalLabel.text = formatter.string(from:  NSNumber.init( value: Float64(total)))
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let commas = numberFormatter.string(from: NSNumber(value: Double(bill)))
        if let commas = commas {
            if( commas != "0") {
                billField.text = "\(currencySymbol!)\(commas)"
            }
        }

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
    
}

