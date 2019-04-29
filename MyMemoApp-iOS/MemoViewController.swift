//
//  MemoViewController.swift
//  MyMemoApp-iOS
//
//  Created by Lee Varnerin on 4/24/19.
//  Copyright © 2019 Learning Mobile Apps. All rights reserved.
//

import UIKit
import CoreData

class MemoViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate{

    var currentMemo: Memo?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let priorityItems: Array<String> = ["High", "Medium", "Low"]
    
    @IBOutlet weak var pckPriority: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeEditMode: UISegmentedControl!
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    @IBOutlet weak var txtMemoName: UITextField!
    @IBOutlet weak var txtMemo: UITextField!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnChange: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentMemo != nil {
            txtMemoName.text = currentMemo!.memoName
            txtMemo.text = currentMemo!.memoText
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentMemo!.memoDate != nil {
                lblDate.text = formatter.string(from: currentMemo!.memoDate as! Date)
            }
        }
        //Do any additional setup after loading the view.
        changeEditMode(self)
        let textField: [UITextField] = [txtMemo, txtMemoName]
        
        for textfield in textField {
            textfield.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControl.Event.editingDidEnd)
        }
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        currentMemo?.memoText = txtMemo.text
        return true
    }
    
    @objc func saveMemo() {
        if currentMemo == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentMemo = Memo(context: context)
        }
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtMemo, txtMemoName]
        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = UITextField.BorderStyle.none
            }
            btnChange.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
        else if sgmtEditMode.selectedSegmentIndex == 1{
            for textField in textFields {
                textField.isEnabled = true
                textField.borderStyle = UITextField.BorderStyle.roundedRect
            }
            btnChange.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(self.saveMemo))
        }
    }
    func dateChanged(date: Date) {
        if currentMemo != nil {
            currentMemo?.memoDate = date as Date?
            appDelegate.saveContext()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            lblDate.text = formatter.string(from: date)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(<#T##animated: Bool##Bool#>)
        self.unregisterKeyboardNotifications()
    }
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        // Get the existing contentInset for the scrollView and set the bottom property to be the height of the keyboard
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueMemoDate") {
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }
    // MARK: UIPickerViewDelegate Methods
    
    // Returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Returns the # of rows in the picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorityItems.count
    }
    
    //Sets the value that is shown for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int)
        -> String? {
            return priorityItems[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent: Int) {
        print("Chosen item: \(priorityItems[row])")
        let pickPriority = priorityItems[row]
        let settings = UserDefaults.standard
        settings.set(pickPriority, forKey: Constants.kpickPriority)
        settings.synchronize()
    }
    override func viewWillAppear(_ animated: Bool) {
        //set the UI based on values in UserDefaults
        
        let settings = UserDefaults.standard
        let pickPriority = settings.string(forKey: Constants.kpickPriority)
        var i = 0
        for priority in priorityItems {
            if(priority == pickPriority){
            priorityItems.selectRow(i, inComponent: 0, animated: false)
            }
            i += 1
        }
        priorityItems.reloadComponent(0)
        
    }

}
