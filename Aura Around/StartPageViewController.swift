//
//  StartPageViewController.swift
//  Aura Around
//
//  Created by Artem Kirichek on 6/5/17.
//  Copyright © 2017 Artem Kirichek. All rights reserved.
//

import UIKit

class StartPageViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateOfBirthTextField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: UIBarButtonItemStyle.done,
                                         target: dateOfBirthTextField,
                                         action: #selector(UIResponder.resignFirstResponder))
        doneButton.tintColor = UIColor(red: 159/255.0, green: 80/255.0, blue: 137/255.0, alpha: 1.0)
        
        toolbar.setItems([doneButton], animated: true)
        dateOfBirthTextField.inputAccessoryView = toolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.AuraIntro, sender: self)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateOfBirthTextField.text = dateFormatter.string(from: sender.date)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
