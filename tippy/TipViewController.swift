//
//  TipViewController.swift
//  tippy
//
//  Created by Mike Lam on 9/27/16.
//  Copyright © 2016 CodePath Assignment #1. All rights reserved.
//

import UIKit

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
        let defaults = UserDefaults.standard
        
        // Check for previously stored bill value
        let storedBill = defaults.integer(forKey:"billField")

        let now = NSDate()
        var difference: TimeInterval = 0
        
        if let lastChanged = defaults.object(forKey:"lastChanged") as? Date {
            difference = now.timeIntervalSince(lastChanged)
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
        
        defaults.set(billField.text,forKey:"billField")
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
        
        let bill = Double(billField.text!) ?? 0
        let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
        let total = bill + tip
        
        tipLabel.text = String(format: "$%.2f",tip)
        totalLabel.text = String(format: "$%.2f",total)
    }

    
}

