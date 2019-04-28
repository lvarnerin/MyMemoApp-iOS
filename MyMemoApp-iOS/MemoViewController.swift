//
//  MemoViewController.swift
//  MyMemoApp-iOS
//
//  Created by Lee Varnerin on 4/24/19.
//  Copyright © 2019 Learning Mobile Apps. All rights reserved.
//

import UIKit
import CoreData

class MemoViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {

    var currentMemo: Memo?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeEditMode: UISegmentedControl!
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!
    @IBOutlet weak var txtMemo: UITextField!
    @IBOutlet weak var swHighPriority: UISwitch!
    @IBOutlet weak var swMediumPriority: UISwitch!
    @IBOutlet weak var swLowPriority: UISwitch!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnChange: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentMemo != nil {
            txtMemo.text = currentMemo!.memoText
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentMemo!.memoDate != nil {
                lblDate.text = formatter.string(from: currentMemo!.memoDate as! Date)
            }
        }
        //Do any additional setup after loading the view.
        changeEditMode(self)
        let textField: [UITextField] = [txtMemo]
        
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
            currentMemo = txtMemo(context: context)
        }
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [txtMemo]
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
    

}
