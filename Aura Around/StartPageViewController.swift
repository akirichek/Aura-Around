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
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.view.removeGestureRecognizer(self.navigationController!.interactivePopGestureRecognizer!)
        
        dateOfBirthTextField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: UIBarButtonItemStyle.done,
                                         target: self,
                                         action: #selector(datePickerDoneButtonClicked))
        doneButton.tintColor = UIColor(red: 159/255.0, green: 80/255.0, blue: 137/255.0, alpha: 1.0)
        
        toolbar.setItems([doneButton], animated: true)
        dateOfBirthTextField.inputAccessoryView = toolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if let auraIntroViewController = destination as? AuraIntroViewController {
            auraIntroViewController.theNumber = calculateTheNumber()
        }
    }
    
    // MARK: - Private Methods
    
    func calculateTheNumber() -> Int {
        var dateComponents = Calendar.current.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year],
                                                             from: datePicker.date)
        dateComponents.calendar = Calendar.current
        let day = sumCharacters(ofNumber: dateComponents.day!)
        let month = sumCharacters(ofNumber: dateComponents.month!)
        let year = sumCharacters(ofNumber: dateComponents.year!)
        let result = sumCharacters(ofNumber: day + month + year)
        print("\(result)")
        return result
    }
    
    func sumCharacters(ofNumber number: Int) -> Int {
        if number != 11 && number != 22 {
            let string = "\(number)"
            var sum = string.characters.reduce(0) { $0 + Int(String($1))! }
            
            if sum > 9 {
                sum = sumCharacters(ofNumber: sum)
            }
            
            return sum
        } else {
            return number
        }
    }
    
    func adjustDateTextField() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateOfBirthTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    func datePickerDoneButtonClicked() {
        dateOfBirthTextField.resignFirstResponder()
        startButton.isEnabled = true
        adjustDateTextField()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.AuraIntro, sender: self)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        startButton.isEnabled = true
        adjustDateTextField()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
