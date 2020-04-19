//
//  ViewController.swift
//  FoodTracker
//
//  Created by Cody King on 4/18/20.
//  Copyright © 2020 Cody J. King. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    // Objects whose values may change
    
    @IBOutlet weak var nameTextField: UITextField!  // ! indicates there will be a value (crashes if not)
    
    @IBOutlet weak var mealNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self  // self: this ViewController
    }

    //MARK: UITextFieldDelegate
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        mealNameLabel.text = textField.text
        textField.text = ""
    }


    // MARK: Actions
    
    @IBAction func setDefaultLabelText(_ sender: Any) {
        mealNameLabel.text = "Default Text"
    }
    
}

