//
//  TipViewController.swift
//  tippy
//
//  Created by Mike Lam on 9/27/16.
//  Copyright © 2016 CodePath Assignment #1. All rights reserved.
//

import UIKit
extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
}
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
        var bill: String = billField.text!
        if(bill.characters.first == nil) {
            billField.text = "$"
        }
        
        let defaults = UserDefaults.standard
        
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
            billField.text = String(storedBill)
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
        calculateTip()
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
        calculateTip()
        animateBackground()
    }
    
    // Because we need to recalculate tip when bill changes
    @IBAction func onBillChange(_ sender: AnyObject) {
        calculateTip()
        let defaults = UserDefaults.standard
        let bill: String = String(billField.text!) ?? "0"

        if(bill.characters.first == nil) {
            billField.text = "$"
        }
        
        
        defaults.set(onlyNums(str:billField.text!),forKey:"billField")
        defaults.set(NSDate(), forKey:"lastChanged")
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
    func calculateTip () {
        let billNum = onlyNums(str: billField.text!)
        let bill = Double(billNum) ?? 0
        let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
        let total = bill + tip
        
        tipLabel.text = String(format: "$%.2f",tip)
        totalLabel.text = String(format: "$%.2f",total)
        
        // Add commas to billField
        
        var largeNumber :String = onlyNums(str: billField.text!)
        
        if(largeNumber == ""){
            largeNumber = "0"
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let commas = numberFormatter.string(from: NSNumber(value: Int(largeNumber)!))
        
        if let commas = commas {
            if( commas != "0"){
                billField.text = "$\(commas)"
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

