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
    
    fileprivate var expensesAPI: ExpensesAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        self.expensesAPI = ExpensesAPI(context: managedContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.typeText.text = UserDefaults.standard.object(forKey: ExpenseEntryViewController.kExpenseTypeKey) as! String?
        
        self.updateCountLabel()
    }


    @IBAction func submitButtonClicked(sender: UIButton) {
        self.expensesAPI!.addExpense(date: selectedDate.date, type: typeText.text!, amount: NSDecimalNumber(string: amountText.text))
        self.updateCountLabel()
        UserDefaults.standard.setValue(self.typeText.text, forKey: ExpenseEntryViewController.kExpenseTypeKey)
        
        let alertViewController = UIAlertController(title: "Expense Added", message: "You successfully added your expense", preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertViewController.addAction(alertAction)
        self.present(alertViewController, animated: true, completion: nil)
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
        countLabel.text = String(format: "Record count: %@", (self.expensesAPI!.getExpenseCount().description))
    }
}

