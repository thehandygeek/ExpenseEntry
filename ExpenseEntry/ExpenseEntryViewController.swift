//
//  ExpenseEntryViewController.swift
//  ExpenseEntry
//
//  Created by Scott on 2016-12-20.
//  Copyright © 2016 Touch Sciences. All rights reserved.
//

import UIKit
import CoreData

class ExpenseEntryViewController: UIViewController, UITextFieldDelegate {
    
    static let kExpenseTypeKey = "type"
    
    @IBOutlet weak var selectedDate: UIDatePicker!
    @IBOutlet weak var typeText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var recieptImageView: UIImageView!
    
    private var expensesModel: ExpensesModel? = nil
    private var recieptImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        expensesModel = ExpensesModel(eventTarget: self)
        
        self.typeText.text = UserDefaults.standard.object(forKey: ExpenseEntryViewController.kExpenseTypeKey) as! String?
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateCountLabel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCamera" {
            if let cameraViewController = segue.destination as? CameraViewController {
                cameraViewController.delegate = self
            }
        }
        else if segue.identifier == "ShowReport" {
            if let reportController = segue.destination as? ExpenseReportTableViewController {
                reportController.set(expensesModel: expensesModel!)
            }
        }
    }
    
    
    @objc
    func applicationDidBecomeActive(_ notification: NSNotification) {
        selectedDate.date = Date(timeIntervalSinceNow: 0)
    }
    
    @IBAction func submitButtonClicked(sender: UIButton) {
        guard let amountTextValue = amountText.text,
            let typeTextValue = typeText.text,
            let image = recieptImage,
            let imageData = UIImageJPEGRepresentation(image, 0.6) else {
            return
        }

        let dateValue = selectedDate.date
        let successTitle = "Expense Added"
        let successMessage = "You successfully added your expense"
        let failureTitle = "Expense Not Added"
        let failureMessage = "Request to add expense failed"
        let spinner = displaySpinner()
        expensesModel!.addExpense(type: typeTextValue, date: dateValue, amount: amountTextValue, reciept: imageData) { expenseResult in
            self.removeSpinner(spinner: spinner)
            let title = expenseResult ? successTitle : failureTitle
            let message = expenseResult ? successMessage : failureMessage
            self.showAlert(title: title, message: message)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == typeText) {
            amountText.becomeFirstResponder()
        } else if (textField == amountText) {
            amountText.resignFirstResponder()
        }
        return true;
    }
    
    func updateCountLabel() {
        countLabel.text = String(format: "Record count: %d", expensesModel!.expenses.count)
    }
    
    private func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {(alert: UIAlertAction!) in
            self.amountText.text = ""
            self.recieptImageView.image = nil
            self.recieptImage = nil
        }
        alertViewController.addAction(alertAction)
        self.present(alertViewController, animated: true, completion: nil)
    }
}

extension ExpenseEntryViewController: CameraViewContollerDelegate {
    func dismiss(viewController: CameraViewController, image: UIImage) {
        recieptImageView.image = image
        recieptImage = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ExpenseEntryViewController: ExpensesModelEvents {
    func expensesChanged(expenses: [ExpenseEntry]) {
        updateCountLabel()
    }
}

