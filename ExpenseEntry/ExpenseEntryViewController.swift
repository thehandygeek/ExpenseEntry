//
//  ExpenseEntryViewController.swift
//  ExpenseEntry
//
//  Created by Scott on 2016-12-20.
//  Copyright © 2016 Touch Sciences. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices

class ExpenseEntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var selectedDate: UIDatePicker!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var recieptImageView: UIImageView!
    
    private var expensesModel: ExpensesModel? = nil
    private var recieptImage: UIImage?
    private var expenseTypes = ["Meal", "Travel", "Supplies", "Auto"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        expensesModel = ExpensesModel(eventTarget: self)
        
        typePicker.dataSource = self
        typePicker.delegate = self
        
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
            let image = recieptImage,
            let imageData = UIImageJPEGRepresentation(image, 0.6) else {
            return
        }

        let selectedType = expenseTypes[typePicker.selectedRow(inComponent: 0)]
        let dateValue = selectedDate.date
        let successTitle = "Expense Added"
        let successMessage = "You successfully added your expense"
        let failureTitle = "Expense Not Added"
        let failureMessage = "Request to add expense failed"
        let spinner = displaySpinner()
        expensesModel!.addExpense(type: selectedType, date: dateValue, amount: amountTextValue, companyId: ExpensesModel.companyId.rawValue, reciept: imageData) { success in
            self.removeSpinner(spinner: spinner)
            let title = success ? successTitle : failureTitle
            let message = success ? successMessage : failureMessage
            self.showAlert(title: title, message: message)
            if success {
                self.amountText.text = ""
                self.recieptImageView.image = nil
                self.recieptImage = nil
            }
        }
    }
    
    @IBAction func selectJPEG(sender: UIButton) {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypeJPEG)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == amountText) {
            amountText.resignFirstResponder()
        }
        return true;
    }
    
    func updateCountLabel() {
        countLabel.text = String(format: "Record count: %d", expensesModel!.expenses.count)
    }
    
    private func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
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

extension ExpenseEntryViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return expenseTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return expenseTypes[row]
    }
}

extension ExpenseEntryViewController: UIDocumentMenuDelegate,UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        let fileManager = FileManager.default
        guard let imageData = fileManager.contents(atPath: myURL.path),
            let image = UIImage.init(data: imageData , scale: 1.0) else { return }
        recieptImageView.image = image
        recieptImage = image
    }
    
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
}

