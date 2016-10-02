//
//  SettingsViewController.swift
//  tippy
//
//  Created by Mike Lam on 9/27/16.
//  Copyright © 2016 CodePath Assignment #1. All rights reserved.
//

import UIKit
class SettingsViewController: UIViewController {
    
    // Refers to the default tip input
    @IBOutlet weak var defaultTipIndex: UISegmentedControl!
    
    @IBOutlet weak var lowDefault: UITextField!
    @IBOutlet weak var mediumDefault: UITextField!
    @IBOutlet weak var highDefault: UITextField!
    
    // Default tip percentages
    var tipPercentages: [Double] = [0.18,0.2,0.25]
    
    // Before view loads
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Set default tip to be whatever's stored in UserDefault
        let defaults = UserDefaults.standard
        defaultTipIndex.selectedSegmentIndex = defaults.integer(forKey:"defaultTipIndex")
        
        // If user changed default tips, update tipPercentages
        tipPercentages = defaults.array(forKey:"tipDefault") as? [Double] ?? tipPercentages
        
        // Set text values for custom tip fields
        lowDefault.text = String(Int(tipPercentages[0]*100))
        mediumDefault.text = String(Int(tipPercentages[1]*100))
        highDefault.text = String(Int(tipPercentages[2]*100))
        
        updateDefaultTipIndex()
    }
    
    // After view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Invoked whenever default tip is changed
    @IBAction func changeDefaultTip(_ sender: AnyObject) {
        
        // Store the new value in UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(defaultTipIndex.selectedSegmentIndex, forKey: "defaultTipIndex")
    }
    
    
    @IBAction func onChangeLowValue(_ sender: AnyObject) {

        changeDefaultTipValue(0)
    }
    
    @IBAction func onChangeMediumValue(_ sender: AnyObject) {

        changeDefaultTipValue(1)
    }
    
    @IBAction func onChangeHighValue(_ sender: AnyObject) {
        
        changeDefaultTipValue(2)
    }
    
    @IBAction func resetDefaults(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        tipPercentages = [0.18,0.2,0.25]
        defaults.set(tipPercentages,forKey:"tipDefault")
        lowDefault.text = String(Int(tipPercentages[0]*100))
        mediumDefault.text = String(Int(tipPercentages[1]*100))
        highDefault.text = String(Int(tipPercentages[2]*100))
        changeDefaultTipValue(0)
        changeDefaultTipValue(1)
        changeDefaultTipValue(2)
        
    }
    // Close the keyboard when user taps on view
    @IBAction func onTap(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    func changeDefaultTipValue(_ index: Int) {
        var newVal: Double? = nil
        switch index {
        case 0:
            newVal = Double(lowDefault.text!) ?? 0
        case 1:
            newVal = Double(mediumDefault.text!) ?? 0
        case 2:
            newVal = Double(highDefault.text!) ?? 0
        default:
            newVal = Double(lowDefault.text!) ?? 0
        }
        
        print(newVal)
        // Change settings view
        let percentage:String = "\(Int(newVal!))%"
        defaultTipIndex.setTitle(percentage, forSegmentAt: Int(index))
        
        // Change default settings
        let defaults = UserDefaults.standard
        
        
        var temp = defaults.array(forKey:"tipDefault") as? [Double] ?? tipPercentages
        temp[index] = newVal!/100
        defaults.set(temp,forKey:"tipDefault")
    }
    
    func updateDefaultTipIndex() {
        // Update defaultTipIndex view
        for (i,v) in tipPercentages.enumerated() {
            
            let percentage:String = "\(Int(v*100))%"
            
            defaultTipIndex.setTitle(percentage, forSegmentAt: Int(i))
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   
    
}
