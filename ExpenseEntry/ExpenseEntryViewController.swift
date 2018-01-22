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
    
    private var expensesModel = ExpensesModel()
    private var recieptImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.typeText.text = UserDefaults.standard.object(forKey: ExpenseEntryViewController.kExpenseTypeKey) as! String?
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
                reportController.set(expensesModel: expensesModel)
            }
        }
    }

    @IBAction func submitButtonClicked(sender: UIButton) {
        guard let amountTextValue = amountText.text,
            let amount = Decimal(string: amountTextValue),
            let image = recieptImage,
            let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            return
        }
        let newEntry = ExpenseEntry(amount: amount, date: selectedDate.date, type: typeText.text!, recieptImage:imageData)
        expensesModel.expenses.append(newEntry)
        try? expensesModel.save()
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
        countLabel.text = String(format: "Record count: %d", expensesModel.expenses.count)
    }
    
    
}

extension ExpenseEntryViewController: CameraViewContollerDelegate {
    func dismiss(viewController: CameraViewController, image: UIImage) {
        recieptImageView.image = image
        recieptImage = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

